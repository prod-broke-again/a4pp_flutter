import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      // try {
      //   await AuthService().forgotPassword(_emailController.text);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Инструкции по сбросу пароля отправлены на ваш email'),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      //   Navigator.of(context).pop();
      // } catch (e) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(e.toString()),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Градиент в стиле логина
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A), Color(0xFF101016)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B46C1).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.lock_reset, color: Color(0xFF9F7AEA)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Восстановление пароля',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Введите ваш email для сброса пароля', style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(height: 20),
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
                          ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Сбросить пароль',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.goNamed('login');
                              }
                            },
                            child: const Text(
                              'Вернуться ко входу',
                              style: TextStyle(color: Colors.white, fontSize: 14),
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
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF6B46C1),
      ),
      filled: true,
      fillColor: Colors.black38,
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
