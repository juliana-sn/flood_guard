import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/flood_alert_coordinator.dart';

class AlertCenterScreen extends StatefulWidget {
  const AlertCenterScreen({super.key});

  @override
  State<AlertCenterScreen> createState() => _AlertCenterScreenState();
}

class _AlertCenterScreenState extends State<AlertCenterScreen> {
  late final FloodAlertCoordinator _coordinator;
  CoordinatorResult? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _coordinator = FloodAlertCoordinator();
    _runCoordinator(); // roda automaticamente ao abrir a tela
  }

  Future<void> _runCoordinator() async {
    setState(() => _loading = true);
    final result = await _coordinator.run();
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse("tel:$number");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Alertas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _result == null
              ? const Center(child: Text('Nenhum dado carregado'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Município: ${_result!.location.cityName} / ${_result!.location.uf}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Previsão: ${_result!.forecast.accumulatedMm24h.toStringAsFixed(1)}mm (${_result!.forecast.source})',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Risco: ${_result!.risk.displayTitle}',
                      style: TextStyle(color: _result!.alert.color),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: ${_result!.alert.displayTitle} — ${_result!.alert.reason}',
                      style: TextStyle(color: _result!.alert.color),
                    ),
                    const SizedBox(height: 24),

                    // Card explicativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use os números abaixo apenas em situações de emergência.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seção de contatos de emergência
                    Text('Contatos de Emergência',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _callNumber("199"),
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text('Defesa Civil (199)',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _callNumber("193"),
                      icon: const Icon(Icons.local_fire_department,
                          color: Colors.white),
                      label: const Text('Bombeiros (193)',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _callNumber("192"),
                      icon: const Icon(Icons.medical_services,
                          color: Colors.white),
                      label: const Text('SAMU (192)',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
    );
  }
}