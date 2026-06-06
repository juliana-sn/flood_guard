import 'package:flutter/material.dart';

import '../services/cache_service.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.waves, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Meu Perfil',
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProfileCard(),
              ),

              const SizedBox(height: 24),

              _MenuSection(
                title: 'CONFIGURAÇÕES DA CONTA',
                items: [
                  _MenuItemData(
                    icon: Icons.person_outline,
                    title: 'Informações Pessoais',
                    onTap: () => _snack(context, 'Informações Pessoais'),
                  ),
                  _MenuItemData(
                    icon: Icons.home_outlined,
                    title: 'Endereços Salvos',
                    onTap: () => _snack(context, 'Endereços Salvos'),
                  ),
                  _MenuItemData(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () => _snack(context, 'Notificações'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _MenuSection(
                title: 'SEGURANÇA E SUPORTE',
                items: [
                  _MenuItemData(
                    icon: Icons.history,
                    title: 'Histórico de Alertas',
                    onTap: () => _snack(context, 'Histórico de Alertas'),
                  ),
                  _MenuItemData(
                    icon: Icons.contact_phone_outlined,
                    title: 'Contatos de Emergência',
                    onTap: () => _snack(context, 'Contatos de Emergência'),
                  ),
                  _MenuItemData(
                    icon: Icons.help_outline,
                    title: 'Ajuda e Suporte',
                    onTap: () => _snack(context, 'Ajuda e Suporte'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Seção nova: cache e dados
              _MenuSection(
                title: 'DADOS DO APP',
                items: [
                  _MenuItemData(
                    icon: Icons.delete_sweep_outlined,
                    title: 'Limpar cache local',
                    onTap: () async {
                      final cache = await CacheService.create();
                      await cache.clearAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cache limpo com sucesso!')),
                        );
                      }
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.info_outline,
                    title: 'Fontes de dados',
                    onTap: () => _showDataSources(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Logout
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLogoutDialog(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: AppColors.neutralBorder),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Sair',
                                style: AppTextStyles.headlineSm
                                    .copyWith(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Flood Guard v1.0.0',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Dados: CEMADEN · CPTEC/INPE · OpenWeather · IBGE',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.4),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sair',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDataSources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fontes de dados', style: AppTextStyles.headlineMd),
            const SizedBox(height: 16),
            _DataSourceRow(
              icon: Icons.water_damage_outlined,
              name: 'CEMADEN',
              desc: 'Dados de pluviômetros em tempo real',
            ),
            _DataSourceRow(
              icon: Icons.cloud_outlined,
              name: 'CPTEC / INPE',
              desc: 'Previsão meteorológica nacional',
            ),
            _DataSourceRow(
              icon: Icons.map_outlined,
              name: 'GeoServer INPE',
              desc: 'Polígonos de zonas de risco',
            ),
            _DataSourceRow(
              icon: Icons.location_city_outlined,
              name: 'IBGE',
              desc: 'Geocodificação de municípios',
            ),
            _DataSourceRow(
              icon: Icons.thunderstorm_outlined,
              name: 'OpenWeather',
              desc: 'Previsão de chuva por coordenadas (fallback)',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DataSourceRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  const _DataSourceRow(
      {required this.icon, required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.headlineSm.copyWith(fontSize: 14)),
              Text(desc,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF313A51).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryContainer, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA0NGMyjznWOf8sW9FhyZ92wIAVQHyQJYJhGqbepGr-pS6CK9fgGEhMA4hfIkHZ1h3olGenaZbO5MkPIM8ASo1moBEVVXne6nm7VVjpFjD9rUEJz-TXP7wKoDO0vwrYnMUeBiQVh--5JU1uTis4stEQPQVs2jqpm92OGsoGjRG6Rlo_RoMjTzlW38JkHmLfBWkGs6hDMk5kTgE9TXGEi42Ct4VOwFvwr3cVwGYeEEt8yVuJDaRxBK4F6ym-g1BFKJAX_g0EHXjp7EKa',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('João Silva', style: AppTextStyles.headlineSm),
                const SizedBox(height: 4),
                Text(
                  'joao.silva@email.com',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Section ────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(title,
                style: AppTextStyles.labelLg.copyWith(letterSpacing: 1.4)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutralBorder),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF313A51).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _MenuItem(data: items[i]),
                  if (i < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                          height: 1, color: Colors.grey.shade100),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _MenuItem extends StatelessWidget {
  final _MenuItemData data;
  const _MenuItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(data.title, style: AppTextStyles.bodyLg)),
              Icon(Icons.chevron_right, color: AppColors.outline, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
