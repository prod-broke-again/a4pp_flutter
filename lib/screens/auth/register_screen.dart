import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/repositories/auth_repository.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('login');
                    }
                  },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('logo.png', width: 40, height: 40, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Создать аккаунт',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Присоединяйтесь к нашему сообществу! Создайте аккаунт, чтобы получить доступ к курсам, встречам и персонализированным рекомендациям.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      const Text('Данные аккаунта', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Имя',
                                hintText: 'Введите ваше имя',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите ваше имя';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastnameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Фамилия',
                                hintText: 'Введите вашу фамилию',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите вашу фамилию';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'example@email.com',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Пожалуйста, введите корректный email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Телефон (опционально)',
                                hintText: '+7 (999) 123-45-67',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                                ),
                              ),
                              validator: (value) {
                                // Телефон опционален
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                hintText: 'Придумайте надежный пароль',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFF1F1F1F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.grey, size: 16),
                                SizedBox(width: 6),
                                Expanded(child: Text('Пароль должен содержать минимум 8 символов. Для безопасности используйте комбинацию букв, цифр и специальных символов.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Icon(Icons.phone_android, color: Colors.grey, size: 16),
                                SizedBox(width: 6),
                                Expanded(child: Text('Телефон используется для восстановления доступа и важных уведомлений. Можно добавить позже в настройках.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                              ],
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return state is AuthLoadInProgress
                                    ? const Center(child: CircularProgressIndicator())
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _register,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          child: const Text(
                                            'Создать аккаунт',
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
                            Center(
                              child: Text(
                                'Нажимая "Создать аккаунт", вы соглашаетесь с условиями использования и политикой конфиденциальности.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
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
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstname: _nameController.text,
              lastname: _lastnameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              phone: _phoneController.text,
            ),
          );
    }
  }
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