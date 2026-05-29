import 'package:flutter/material.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.waves,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Meu Perfil',
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 28),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // User Profile Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProfileCard(),
              ),
              
              const SizedBox(height: 24),
              
              // Account Settings Section
              _MenuSection(
                title: 'CONFIGURAÇÕES DA CONTA',
                items: [
                  _MenuItemData(
                    icon: Icons.person_outline,
                    title: 'Informações Pessoais',
                    onTap: () {
                      // TODO: Navigate to personal info screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Informações Pessoais')),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.home_outlined,
                    title: 'Endereços Salvos',
                    onTap: () {
                      // TODO: Navigate to saved addresses screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Endereços Salvos')),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () {
                      // TODO: Navigate to notifications settings screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificações')),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Safety & Support Section
              _MenuSection(
                title: 'SEGURANÇA E SUPORTE',
                items: [
                  _MenuItemData(
                    icon: Icons.history,
                    title: 'Histórico de Alertas',
                    onTap: () {
                      // TODO: Navigate to alert history screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Histórico de Alertas')),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.contact_phone_outlined,
                    title: 'Contatos de Emergência',
                    onTap: () {
                      // TODO: Navigate to emergency contacts screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contatos de Emergência')),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.help_outline,
                    title: 'Ajuda e Suporte',
                    onTap: () {
                      // TODO: Navigate to help & support screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajuda e Suporte')),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Logout Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Logout Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Implement logout functionality
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Navigate to login screen
                                  },
                                  child: const Text('Sair', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.neutralBorder),
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
                              Icon(
                                Icons.logout,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sair',
                                style: AppTextStyles.headlineSm.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App Version
                    Text(
                      'Flood Guard v1.0.0',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Card Widget
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
          // Avatar with Edit Button
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 4,
                  ),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'João Silva',
                  style: AppTextStyles.headlineSm,
                ),
                const SizedBox(height: 4),
                Text(
                  'joao.silva@email.com',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Menu Section Widget
class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                letterSpacing: 1.4,
              ),
            ),
          ),
          
          // Menu Items Container
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
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                      ),
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

// Menu Item Data Class
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

// Menu Item Widget
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
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  data.title,
                  style: AppTextStyles.bodyLg,
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.outline,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

