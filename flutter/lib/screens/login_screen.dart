import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'signup_screen.dart';
import '../main.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Preencha email e senha.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      await AuthService.instance.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AppShell()));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  child: Text('Flood Guard', style: AppTextStyles.headlineLg)),
              const SizedBox(height: 24),
              const Text('Acesse sua conta',
                  style: AppTextStyles.headlineMd, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Monitore alertas de inundação em tempo real.',
                  style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 32),

              _Field(controller: _email, label: 'Email',
                  icon: Icons.mail_outline, hint: 'seu@email.com',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _PasswordField(
                  controller: _password,
                  isVisible: _passwordVisible,
                  onToggle: () =>
                      setState(() => _passwordVisible = !_passwordVisible)),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!,
                      style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ],

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueci minha senha?',
                      style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Entrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: 'Não tem uma conta? ',
                      style: TextStyle(color: Color(0xFF2D1600), fontSize: 13)),
                  TextSpan(
                    text: 'Criar conta',
                    style: const TextStyle(
                        color: AppColors.secondary, fontSize: 13,
                        fontWeight: FontWeight.w800),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SignupScreen())),
                  ),
                ])),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _Field({
    required this.controller, required this.label,
    required this.icon, required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ],
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Senha', style: AppTextStyles.labelLg),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.onSurfaceVariant),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ],
  );
}