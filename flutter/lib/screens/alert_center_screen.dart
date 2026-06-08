import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/flood_alert_coordinator.dart';

class AlertCenterScreen extends StatefulWidget {
  const AlertCenterScreen({super.key});

  @override
  State<AlertCenterScreen> createState() => _AlertCenterScreenState();
}

class _AlertCenterScreenState extends State<AlertCenterScreen> {
  final _coordinator = FloodAlertCoordinator();
  CoordinatorResult? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() { _loading = true; _error = null; });
    try {
      // Usa cache se disponível — evita refazer GPS + APIs
      final result = await _coordinator.run(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() { _result = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Erro ao carregar alertas: $e'; _loading = false; });
    }
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Alertas'),
        actions: [
          // Botão de refresh forçado (ignora cache)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar dados',
            onPressed: _loading ? null : () => _load(forceRefresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _load(forceRefresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _result == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey, size: 48),
                          const SizedBox(height: 12),
                          const Text('Nenhum dado carregado'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _load(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Atualizar'),
                          ),
                        ],
                      ),
                    )
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final r = _result!;
    final color = Color(r.colorValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Município
        Text(
          '${r.cityName} / ${r.uf}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Card de alerta principal — cor vinda da API
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(
                  r.shouldAlert ? Icons.warning_rounded : Icons.check_circle,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  r.severityTitle.isNotEmpty ? r.severityTitle : 'Nenhum risco',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
              ]),
              const SizedBox(height: 8),
              Text(r.reason),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Previsão de chuva
        Text(
          'Previsão: ${r.rainfallMm.toStringAsFixed(1)}mm/24h (${r.weatherSource})',
        ),
        const SizedBox(height: 6),

        // Nível de risco
        Text(
          'Risco: ${r.riskMessage.isNotEmpty ? r.riskMessage : "Nenhum risco mapeado"}',
          style: TextStyle(color: color),
        ),
        const SizedBox(height: 24),

        // Aviso de emergência
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Use os números abaixo apenas em situações de emergência.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        Text('Contatos de Emergência',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _callNumber('199'),
          icon: const Icon(Icons.phone, color: Colors.white),
          label: const Text('Defesa Civil (199)',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _callNumber('193'),
          icon: const Icon(Icons.local_fire_department, color: Colors.white),
          label: const Text('Bombeiros (193)',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _callNumber('192'),
          icon: const Icon(Icons.medical_services, color: Colors.white),
          label: const Text('SAMU (192)',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      ],
    );
  }
}
