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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Фон-градиент
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
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
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
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
                                Expanded(
                                  child: Text(
                                    'С возвращением!',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                              const SizedBox(height: 8),
                              Text('Войдите, чтобы продолжить', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 20),

                              // Поле email
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                decoration: _buildInputDecoration(
                                  hintText: 'Пароль',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                  child: Text(
                                    'Забыли пароль?',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
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
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'или',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Theme.of(context).colorScheme.outline,
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
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      prefixIcon: Icon(
        prefixIcon,
        color: Theme.of(context).colorScheme.primary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}
