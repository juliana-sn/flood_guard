import 'package:flutter/material.dart';
import '../theme.dart';

class AlertCenterScreen extends StatelessWidget {
  const AlertCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Central de Alerta', style: AppTextStyles.headlineMd),
              const SizedBox(height: 20),
              _StatusCard(
                title: 'Crítico',
                description: 'Tempestade severa iminente. Acompanhe as notificações e evite áreas baixas.',
                color: const Color(0xFFFF7E7B),
              ),
              const SizedBox(height: 16),
              _StatusCard(
                title: 'Seguro',
                description: 'Condições normais na maioria das regiões monitoradas.',
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              Text('Monitoramento ao vivo', style: AppTextStyles.headlineMd),
              const SizedBox(height: 16),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thermostat, size: 72, color: AppColors.outline),
                      const SizedBox(height: 12),
                      Text(
                        'Visual de chuva em tempo real',
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Ligar para Defesa Civil (199)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineMd.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(description, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}
