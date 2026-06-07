import 'package:flutter/material.dart';
import '../theme.dart';

class BuildFormField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const BuildFormField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<BuildFormField> createState() => _BuildFormFieldState();
}

class _BuildFormFieldState extends State<BuildFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            widget.label,
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
            controller: _controller,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                widget.icon,
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
