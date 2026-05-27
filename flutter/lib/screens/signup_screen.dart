import 'package:flutter/material.dart';
import '../theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text('Criar Conta', style: AppTextStyles.headlineMd),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthTextField(label: 'Nome Completo', hint: 'Nome completo', icon: Icons.person_outline),
            const SizedBox(height: 16),
            const _AuthTextField(label: 'E-mail', hint: 'seu@email.com', icon: Icons.email_outlined),
            const SizedBox(height: 16),
            const _AuthTextField(label: 'Senha', hint: '••••••••', icon: Icons.lock_outline, obscureText: true),
            const SizedBox(height: 16),
            const _AuthTextField(label: 'Confirmar Senha', hint: '••••••••', icon: Icons.lock_outline, obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Cadastrar'),
            ),
            const Spacer(),
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF1E6), Color(0xFFFFFFFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.bottomCenter,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Onda suave de conectividade para o fluxo do monitoramento hídrico.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;
  final bool obscureText;

  const _AuthTextField({
    required this.label,
    required this.icon,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
