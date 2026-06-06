import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/alert_result.dart';

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
      // Plugin nativo não encontrado (ex: emulador sem rebuild, web, desktop)
      // O app continua funcionando normalmente sem notificações
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

  static Future<void> sendAlert(AlertResult alert, String cityName) async {
    if (!_available) {
      debugPrint('[NotificationService] Notificação ignorada — plugin indisponível.');
      return;
    }

    try {
      final isCritical = alert.severity == AlertSeverity.danger ||
          alert.severity == AlertSeverity.emergency;

      final androidDetails = AndroidNotificationDetails(
        isCritical ? 'flood_critical' : 'flood_info',
        isCritical ? 'Alertas críticos de enchente' : 'Monitoramento de chuvas',
        channelDescription: 'Alertas de risco hidrológico',
        importance: isCritical ? Importance.max : Importance.defaultImportance,
        priority: isCritical ? Priority.max : Priority.defaultPriority,
        color: isCritical
            ? const Color(0xFFFF7E7B)
            : const Color(0xFF2196F3),
      );

      await _plugin.show(
        alert.severity.index,
        _titleFor(alert.severity, cityName),
        alert.reason,
        NotificationDetails(android: androidDetails),
      );
    } on MissingPluginException {
      debugPrint('[NotificationService] Falha ao enviar notificação.');
    } on PlatformException catch (e) {
      debugPrint('[NotificationService] PlatformException: $e');
    }
  }

  static String _titleFor(AlertSeverity s, String city) => switch (s) {
        AlertSeverity.watch     => 'Atenção: chuvas em $city',
        AlertSeverity.warning   => 'Alerta de chuva forte em $city',
        AlertSeverity.danger    => 'Risco de enchente em $city',
        AlertSeverity.emergency => 'Emergência: saia da área em $city',
        _                       => 'Monitoramento ativo em $city',
      };

  /// Retorna se as notificações estão disponíveis neste dispositivo
  static bool get isAvailable => _available;
}
