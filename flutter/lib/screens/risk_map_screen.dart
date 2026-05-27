import 'package:flutter/material.dart';
import '../theme.dart';

class RiskMapScreen extends StatelessWidget {
  const RiskMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Mapa de Risco', style: AppTextStyles.headlineMd),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined, size: 96, color: AppColors.outline),
                            const SizedBox(height: 16),
                            Text(
                              'Mapa geoespacial em desenvolvimento',
                              style: AppTextStyles.bodyMd,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 140),
              ],
            ),
            Positioned(
              top: 120,
              right: 24,
              child: _LegendCard(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _StatusBottomSheet(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legenda', style: AppTextStyles.headlineMd.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Row(children: [
            _Dot(color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Nível Crítico'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _Dot(color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text('Risco Moderado'),
          ]),
          const SizedBox(height: 16),
          const Text('Localização atual', style: AppTextStyles.labelSm),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Risco de Alagamento', style: AppTextStyles.headlineMd),
          const SizedBox(height: 8),
          Text(
            'Atenção: sua região apresenta níveis elevados de chuva e enchente.',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Ver Rotas de Fuga'),
          ),
        ],
      ),
    );
  }
}
