import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'OrbitFlood',
                  style: AppTextStyles.headlineLg,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Acesse sua conta',
                style: AppTextStyles.headlineMd,
              ),
              const SizedBox(height: 8),
              Text(
                'Monitore alertas de inundação em tempo real e mantenha-se seguro.',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 32),
              const _AuthTextField(
                label: 'E-mail',
                icon: Icons.email_outlined,
                hint: 'seu@email.com',
              ),
              const SizedBox(height: 16),
              const _AuthTextField(
                label: 'Senha',
                icon: Icons.lock_outline,
                hint: '••••••••',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueci minha senha'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Entrar com',
                  style: AppTextStyles.labelSm,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.apple),
                      label: const Text('Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: const Text('Criar nova conta'),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
