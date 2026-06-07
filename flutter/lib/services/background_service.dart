import 'package:workmanager/workmanager.dart';
import 'flood_alert_coordinator.dart';
import 'notification_service.dart';

const _taskName = 'flood_guard_check';
const _taskUniqueName = 'flood_guard_periodic';

/// Ponto de entrada top-level obrigatório pelo workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      try {
        final coordinator = FloodAlertCoordinator();
        final result = await coordinator.run().timeout(
          const Duration(seconds: 30),
        );

        if (result.shouldAlert) {
          await NotificationService.initialize();
          await NotificationService.sendCoordinatorResult(result);
        }
      } catch (_) {
        // Falha silenciosa — não cancela o ciclo de tasks
      }
    }
    return true; // sempre retornar true para o workmanager não desistir
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // mude para true durante desenvolvimento
    );

    // Tarefa periódica a cada 30 minutos
    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  /// Cancela todas as tasks (ex: usuário faz logout)
  static Future<void> cancel() async {
    await Workmanager().cancelAll();
  }
}
