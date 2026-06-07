import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../main.dart';
import '../theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _passVisible = false;
  bool _confirmVisible = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _password.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty ||
        _password.text.isEmpty) {
      setState(() => _error = 'Preencha todos os campos.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'As senhas não conferem.');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.instance.signup(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
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
        child: Column(
          children: [
            // Top nav
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                    bottom: BorderSide(color: AppColors.surfaceVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.waves, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text('FloodGuard',
                        style: AppTextStyles.headlineMd
                            .copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text('Criar Conta',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold,
                            color: AppColors.onSurface),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Receba alertas críticos de enchentes em tempo real.',
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    _SignupField(controller: _name, label: 'Nome Completo',
                        icon: Icons.person_outline, hint: 'Como deseja ser chamado?'),
                    const SizedBox(height: 20),
                    _SignupField(controller: _email, label: 'Email',
                        icon: Icons.mail_outline, hint: 'seu@email.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _SignupPass(controller: _password, label: 'Senha',
                        icon: Icons.lock_outline,
                        isVisible: _passVisible,
                        onToggle: () => setState(() => _passVisible = !_passVisible)),
                    const SizedBox(height: 20),
                    _SignupPass(controller: _confirm, label: 'Confirmar Senha',
                        icon: Icons.lock_reset,
                        isVisible: _confirmVisible,
                        onToggle: () => setState(() => _confirmVisible = !_confirmVisible)),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
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

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Cadastrar',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Já tenho conta',
                            style: TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            )),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _SignupField({
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
        controller: controller, keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ],
  );
}

class _SignupPass extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isVisible;
  final VoidCallback onToggle;

  const _SignupPass({
    required this.controller, required this.label, required this.icon,
    required this.isVisible, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.labelLg),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, obscureText: !isVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
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