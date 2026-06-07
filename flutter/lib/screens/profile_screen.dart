import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<dynamic> _addresses = [];
  List<dynamic> _history = [];
  bool _loadingAddresses = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadAddresses();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final data = await ApiClient.getAddresses();
      if (mounted) setState(() { _addresses = data; _loadingAddresses = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final data = await ApiClient.getHistory();
      if (mounted) setState(() { _history = data; _loadingHistory = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _addAddress() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddAddressDialog(),
    );
    if (result == null) return;
    try {
      await ApiClient.addAddress(result);
      await _loadAddresses();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteAddress(int id) async {
    try {
      await ApiClient.deleteAddress(id);
      await _loadAddresses();
    } catch (_) {}
  }

  Future<void> _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Deseja apagar todo o histórico de alertas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Apagar', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok != true) return;
    await ApiClient.clearHistory();
    await _loadHistory();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Sair', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Icon(Icons.waves, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text('Meu Perfil',
                    style: AppTextStyles.headlineLg.copyWith(fontSize: 26)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: AppColors.error,
                  tooltip: 'Sair',
                  onPressed: _logout,
                ),
              ]),
            ),

            // ── User card ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutralBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12, offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      (user?['name'] as String? ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?['name'] as String? ?? 'Usuário',
                        style: AppTextStyles.headlineSm),
                    Text(user?['email'] as String? ?? '',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ]),
                ]),
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────────────────
            const SizedBox(height: 20),
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.home_outlined), text: 'Endereços'),
                Tab(icon: Icon(Icons.history), text: 'Histórico'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _AddressesTab(
                    addresses: _addresses,
                    loading: _loadingAddresses,
                    onAdd: _addAddress,
                    onDelete: _deleteAddress,
                  ),
                  _HistoryTab(
                    history: _history,
                    loading: _loadingHistory,
                    onClear: _clearHistory,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Addresses Tab ─────────────────────────────────────────────────────────────

class _AddressesTab extends StatelessWidget {
  final List<dynamic> addresses;
  final bool loading;
  final VoidCallback onAdd;
  final void Function(int) onDelete;

  const _AddressesTab({
    required this.addresses, required this.loading,
    required this.onAdd, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Adicionar endereço'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        Expanded(
          child: addresses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Nenhum endereço salvo'),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final a = addresses[i] as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: const Icon(Icons.place,
                            color: AppColors.primary),
                        title: Text(a['label'] as String? ?? ''),
                        subtitle: Text(
                            '${a['city_name']} — ${a['uf']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => onDelete(a['id'] as int),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final List<dynamic> history;
  final bool loading;
  final VoidCallback onClear;

  const _HistoryTab({
    required this.history, required this.loading, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        if (history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Limpar histórico'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        Expanded(
          child: history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Nenhum alerta registrado'),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final h = history[i] as Map<String, dynamic>;
                    final color = _colorFromHex(
                        _severityColor(h['severity'] as String? ?? ''));
                    final date = DateTime.tryParse(
                            h['recorded_at'] as String? ?? '') ??
                        DateTime.now();
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            (h['triggered_alert'] as bool? ?? false)
                                ? Icons.warning_rounded
                                : Icons.check_circle,
                            color: color,
                          ),
                        ),
                        title: Text(
                            '${h['city_name']} — ${h['uf']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h['reason'] as String? ?? ''),
                            Text(
                              '${date.day.toString().padLeft(2, '0')}/'
                              '${date.month.toString().padLeft(2, '0')}/'
                              '${date.year}  '
                              '${date.hour.toString().padLeft(2, '0')}:'
                              '${date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _severityColor(String s) => {
        'safe': '#4CAF50',
        'watch': '#FFEB3B',
        'warning': '#FF9800',
        'danger': '#FF7E7B',
        'emergency': '#B71C1C',
      }[s] ??
      '#9E9E9E';

  Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ── Add Address Dialog ────────────────────────────────────────────────────────

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog();

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _label = TextEditingController();
  final _city = TextEditingController();
  final _uf = TextEditingController();
  final _ibge = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  @override
  void dispose() {
    _label.dispose(); _city.dispose(); _uf.dispose();
    _ibge.dispose(); _lat.dispose(); _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo endereço'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(_label, 'Rótulo (ex: Casa, Trabalho)'),
          _dialogField(_city, 'Cidade'),
          _dialogField(_uf, 'UF (ex: SP)', maxLength: 2),
          _dialogField(_ibge, 'Código IBGE'),
          _dialogField(_lat, 'Latitude',
              type: TextInputType.numberWithOptions(decimal: true)),
          _dialogField(_lng, 'Longitude',
              type: TextInputType.numberWithOptions(decimal: true)),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_label.text.isEmpty || _city.text.isEmpty) return;
            Navigator.pop(context, {
              'label': _label.text.trim(),
              'city_name': _city.text.trim(),
              'uf': _uf.text.trim().toUpperCase(),
              'ibge_code': _ibge.text.trim(),
              'lat': double.tryParse(_lat.text) ?? 0.0,
              'lng': double.tryParse(_lng.text) ?? 0.0,
            });
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _dialogField(TextEditingController c, String label,
      {TextInputType type = TextInputType.text, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        ),
      ),
    );
  }
}