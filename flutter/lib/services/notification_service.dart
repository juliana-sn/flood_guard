import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'flood_alert_coordinator.dart'; // para usar CoordinatorResult

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _available = false; // true só se o plugin nativo estiver ok

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final ok = await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );

      if (ok == true) {
        await _createChannels();
        _available = true;
      }
    } on MissingPluginException {
      debugPrint('[NotificationService] Plugin não disponível — notificações desativadas.');
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] Erro de plataforma: $e');
    } catch (e) {
      debugPrint('[NotificationService] Erro inesperado: $e');
    }
  }

  static Future<void> _createChannels() async {
    try {
      final androidPlugin = AndroidFlutterLocalNotificationsPlugin();

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'flood_critical',
          'Alertas críticos de enchente',
          description: 'Avisos de risco iminente de enchente ou deslizamento',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'flood_info',
          'Monitoramento de chuvas',
          description: 'Atualizações periódicas de nível de chuva',
          importance: Importance.low,
          playSound: false,
        ),
      );
    } on MissingPluginException {
      _available = false;
    }
  }

  /// Novo método: envia notificação direto a partir do CoordinatorResult
  static Future<void> sendCoordinatorResult(CoordinatorResult result) async {
    if (!_available) {
      debugPrint('[NotificationService] Notificação ignorada — plugin indisponível.');
      return;
    }

    try {
      final isCritical = result.severityTitle == 'Risco Muito Alto' || result.severityTitle == 'Risco Alto';

      final androidDetails = AndroidNotificationDetails(
        isCritical ? 'flood_critical' : 'flood_info',
        isCritical ? 'Alertas críticos de enchente' : 'Monitoramento de chuvas',
        channelDescription: 'Alertas de risco hidrológico',
        importance: isCritical ? Importance.max : Importance.defaultImportance,
        priority: isCritical ? Priority.max : Priority.defaultPriority,
        color: Color(result.colorValue),
      );

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        result.severityTitle.isNotEmpty
            ? result.severityTitle
            : 'Monitoramento ativo em ${result.cityName}',
        result.reason,
        NotificationDetails(android: androidDetails),
      );
    } on MissingPluginException {
      debugPrint('[NotificationService] Falha ao enviar notificação.');
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] PlatformException: $e');
    }
  }

  static bool get isAvailable => _available;
}
