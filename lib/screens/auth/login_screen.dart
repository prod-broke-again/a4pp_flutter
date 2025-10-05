import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:achpp/blocs/auth/auth_bloc.dart';
import 'package:achpp/repositories/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@appp-psy.ru');
  final _passwordController = TextEditingController(text: 'password');
  bool _isPasswordVisible = false;


  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-In: в разработке')),
    );
  }

  void _loginWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-In: в разработке')),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Фон-градиент
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A), Color(0xFF101016)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Акцентные круги
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF6B46C1).withOpacity(0.35), blurRadius: 60)],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.18),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.25), blurRadius: 60)],
              ),
            ),
          ),
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthLoadSuccess) {
                  if (mounted) context.goNamed('home');
                } else if (state is AuthLoadFailure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[800]!),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset('logo.png', width: 48, height: 48, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'С возвращением!',
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                              const SizedBox(height: 8),
                              Text('Войдите, чтобы продолжить', style: TextStyle(color: Colors.grey[400])),
                              const SizedBox(height: 20),

                              // Поле email
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Введите корректный email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Поле пароля
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  hintText: 'Пароль',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите пароль';
                                  }
                                  if (value.length < 6) {
                                    return 'Пароль должен содержать минимум 6 символов';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              // Забыли пароль
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.goNamed('forgot-password');
                                  },
                                  child: const Text(
                                    'Забыли пароль?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Кнопка входа
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return state is AuthLoadInProgress
                                      ? const Center(child: CircularProgressIndicator())
                                      : SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _login,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                            ),
                                            child: const Text(
                                              'Войти',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Разделитель
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'или',
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                            // Кнопка регистрации
                              OutlinedButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFF6B46C1),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Создать аккаунт',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF6B46C1),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1F1F1F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF6B46C1),
          width: 2,
        ),
      ),
    );
  }
}
