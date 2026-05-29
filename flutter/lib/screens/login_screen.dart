import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lumen_orbit/main.dart';
import 'package:lumen_orbit/widgets/build_form_field.dart';
import 'package:lumen_orbit/widgets/build_password_field.dart';
import '../theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  State<LoginScreen> createState() => _LoginScreenState();
}

  class _LoginScreenState extends State<LoginScreen> {
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
                child: Text(
                  'OrbitFlood',
                  style: AppTextStyles.headlineLg,
                ),
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
              const BuildFormField(
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Esqueci minha senha?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight(400),
                      wordSpacing: -1.5,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AppShell()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Cor de fundo do botão
                  foregroundColor: Colors.white, // Cor do texto e do ícone
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20), // Espaçamento interno
                  elevation: 5, // Altura da sombra
                  textStyle: AppTextStyles.labelSm,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Bordas arredondadas
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight(800),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      // Parte 1: Texto normal
                      const TextSpan(
                        text: 'Não tem uma conta? ',
                        style: const TextStyle(
                          color: Color(0xFF2D1600), // Cor do texto comum
                          fontSize: 13,
                          fontWeight: FontWeight(400),
                        ),
                      ),
                      // Parte 2: O Link com destaque e clique
                      TextSpan(
                        text: 'Criar conta',
                        style: const TextStyle(
                          color: AppColors
                              .secondary, // Sua cor de destaque do tema
                          fontSize: 13,
                          fontWeight: FontWeight(800), // Destaque em negrito
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: AppColors
                          .onSurface, // Ajuste a cor se preferir mais clara
                      thickness: 1, // Espessura da linha
                      endIndent:
                          15, // Espaço entre a linha da esquerda e o texto
                    ),
                  ),
                  const Center(
                    child: const Text(
                      'OU ENTRE COM',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight(300),
                          color: AppColors.onSurface,
                          fontFamily: 'Plus Jakarta Sans',
                          wordSpacing: -0.5),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors
                          .onSurface, // Ajuste a cor se preferir mais clara
                      thickness: 1, // Espessura da linha
                      indent: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}



