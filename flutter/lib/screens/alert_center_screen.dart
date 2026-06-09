import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/flood_alert_coordinator.dart';
import '../theme.dart';

class AlertCenterScreen extends StatefulWidget {
  const AlertCenterScreen({super.key});

  @override
  State<AlertCenterScreen> createState() => _AlertCenterScreenState();
}

class _AlertCenterScreenState extends State<AlertCenterScreen>
    with AutomaticKeepAliveClientMixin {

  // AutomaticKeepAliveClientMixin preserva o estado quando o usuário
  // muda de aba — evita reload desnecessário ao voltar para esta tela
  @override
  bool get wantKeepAlive => true;

  final _coordinator = FloodAlertCoordinator();
  CoordinatorResult? _result;
  bool _loading = false;
  bool _loaded = false; // flag: já carregou ao menos uma vez
  String? _error;

  @override
  void initState() {
    super.initState();
    // NÃO carrega no initState — o IndexedStack inicializa todas as telas
    // ao mesmo tempo, então carregar aqui causaria duas chamadas paralelas
    // ao backend (mapa + central de alertas) sem que o cache do mapa
    // pudesse ser aproveitado.
    // O carregamento acontece no didChangeDependencies apenas na primeira
    // vez que o widget é exibido na árvore.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega apenas uma vez, na primeira vez que a tela fica visível.
    // Nas vezes seguintes, AutomaticKeepAliveClientMixin mantém o estado.
    if (!_loaded) {
      _loaded = true;
      // Pequeno delay para garantir que o RiskMapScreen já disparou run()
      // e populou o cache antes desta tela tentar ler.
      Future.delayed(const Duration(milliseconds: 500), _load);
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _coordinator.run(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() { _result = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loading = false;
      });
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout')) return 'Tempo esgotado. Verifique sua conexão.';
    if (msg.contains('permission')) return 'Permissão de localização negada.';
    return 'Erro ao carregar dados. Tente novamente.';
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // obrigatório com AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Alertas'),
        actions: [
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
              ? _buildError()
              : _result == null
                  ? _buildEmpty()
                  : _buildContent(),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _load(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Center(
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
  );

  Widget _buildContent() {
    final r = _result!;
    final color = Color(r.colorValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Município
        Text(
          r.cityName.isNotEmpty ? '${r.cityName} / ${r.uf}' : 'Localização detectada',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Card principal de alerta
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
                Expanded(
                  child: Text(
                    r.severityTitle.isNotEmpty ? r.severityTitle : 'Sem risco mapeado',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: color),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(r.reason),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Previsão e risco
        Row(children: [
          const Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue),
          const SizedBox(width: 6),
          Text('${r.rainfallMm.toStringAsFixed(1)}mm/24h · ${r.weatherSource}'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.terrain, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              r.riskMessage.isNotEmpty ? r.riskMessage : 'Sem dados de risco',
              style: TextStyle(color: color),
            ),
          ),
        ]),

        const SizedBox(height: 24),

        // Aviso
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Use os números abaixo apenas em situações de emergência.',
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