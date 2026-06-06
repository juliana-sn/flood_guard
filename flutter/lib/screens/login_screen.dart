import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'signup_screen.dart';

// Substitua pelo seu AppShell real
// import 'package:seu_app/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() =>
      setState(() => _isPasswordVisible = !_isPasswordVisible);

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    // TODO: Implementar autenticação real (Firebase, Supabase, etc.)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
  }

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
              const SizedBox(height: 48),
              const Center(
                child: Text('Flood Guard', style: AppTextStyles.headlineLg),
              ),
              const SizedBox(height: 24),
              const Text(
                'Acesse sua conta',
                style: AppTextStyles.headlineMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Monitore alertas de inundação em tempo real.',
                style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email
              _FormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                hint: 'seu@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Senha
              _PasswordField(
                controller: _passwordController,
                label: 'Senha',
                hint: '••••••••',
                isVisible: _isPasswordVisible,
                onToggle: _togglePasswordVisibility,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci minha senha?',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Plus Jakarta Sans'),
                      ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text.rich(
                  TextSpan(children: [
                    const TextSpan(
                      text: 'Não tem uma conta? ',
                      style: TextStyle(
                          color: Color(0xFF2D1600), fontSize: 13),
                    ),
                    TextSpan(
                      text: 'Criar conta',
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen()),
                            ),
                    ),
                  ]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              const Row(children: [
                Expanded(
                    child: Divider(color: AppColors.onSurface, endIndent: 15)),
                Text('OU ENTRE COM',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppColors.onSurface,
                        fontFamily: 'Plus Jakarta Sans')),
                Expanded(
                    child: Divider(color: AppColors.onSurface, indent: 15)),
              ]),
              const SizedBox(height: 32),

              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Google'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets locais (substitui BuildFormField / BuildPasswordField) ───────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLg),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLg),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}
