import 'package:flutter/material.dart';
import '../theme.dart';

class BuildFormField extends StatelessWidget {
  // 1. Definição correta das variáveis (com TextInputType? corrigido)
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;

  // 2. Criação do construtor obrigatório para inicializar as variáveis
  const BuildFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType, // Opcional, pois pode ser nulo
  });

  // 3. Implementação do método build
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.onSurface,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
