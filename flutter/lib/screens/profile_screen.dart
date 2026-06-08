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
  List<dynamic> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await ApiClient.getHistory();
      if (mounted) setState(() { _history = data; _loadingHistory = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
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
                Tab(icon: Icon(Icons.history), text: 'Histórico'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
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