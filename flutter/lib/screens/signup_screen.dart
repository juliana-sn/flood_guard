import 'package:flutter/material.dart';
import 'package:lumen_orbit/widgets/build_form_field.dart';
import 'package:lumen_orbit/widgets/build_password_field.dart';
import '../theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // TODO: Implement actual signup logic
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.surfaceVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.waves,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OrbitFlood',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Header Section
                    Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitore níveis de água e receba alertas críticos em tempo real.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Registration Form
                    BuildFormField(
                      label: 'Nome Completo',
                      icon: Icons.person_outline,
                      hint: 'Como deseja ser chamado?',
                    ),

                    const SizedBox(height: 24),

                    BuildFormField(
                      label: 'Email',
                      icon: Icons.mail_outline,
                      hint: 'seu@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 24),

                    BuildPasswordField(
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      hint: '••••••••',
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: _togglePasswordVisibility,
                    ),

                    const SizedBox(height: 24),

                    BuildPasswordField(
                      label: 'Confirmar Senha',
                      icon: Icons.lock_reset,
                      hint: 'Repita sua senha',
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: _toggleConfirmPasswordVisibility,
                    ),

                    const SizedBox(height: 32),

                    // Register Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Already have account link
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Já tenho conta',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider with "OU"
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.surfaceVariant,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: AppTextStyles.labelSm.copyWith(
                              color:
                                  AppColors.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.surfaceVariant,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Google'),
                            style: ElevatedButton.styleFrom(
                              // Cor de fundo
                              foregroundColor:
                                  AppColors.primary, // Cor do texto e ícone
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple),
                            label: const Text('Apple'),
                            style: ElevatedButton.styleFrom(
                              // Cor de fundo
                              foregroundColor:
                                  AppColors.primary, // Cor do texto e ícone
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Social Login Buttons

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Decorative Footer Wave
          ],
        ),
      ),
    );
  }
}