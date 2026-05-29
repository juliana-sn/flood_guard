import 'package:flutter/material.dart';
import '../theme.dart';

class BuildPasswordField extends StatelessWidget {
  // 1. Transforme os parâmetros da sua função em propriedades da classe
  final String label;
  final IconData icon;
  final String hint;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  // 2. Crie o construtor da classe
  const BuildPasswordField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  // 3. Implemente o método build obrigatório
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
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.onSurfaceVariant,
                ),
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