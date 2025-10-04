import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/services/preload_service.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _animationCompleted = false;
  bool _preloadCompleted = false;
  PreloadedData? _preloadedData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Анимация масштаба (от 0.3 до 1.0)
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Анимация прозрачности (от 0.0 до 1.0)
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    // Анимация вращения (небольшое вращение в начале)
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Анимация цвета (от фиолетового к белому)
    _colorAnimation = ColorTween(
      begin: const Color(0xFF6B46C1),
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Добавляем слушатель завершения анимации
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationCompleted = true;
        });
        // После завершения анимации проверяем аутентификацию
        _checkAuthAfterAnimation();
      }
    });

    // Запускаем предварительную загрузку данных параллельно с анимацией
    _startPreloading();

    _controller.forward();
  }

  /// Запуск предварительной загрузки данных главной страницы
  void _startPreloading() async {
    print('🔄 Запуск предварительной загрузки данных...');
    try {
      final preloadService = PreloadService();
      _preloadedData = await preloadService.preloadHomeData();
      if (mounted) {
        setState(() {
          _preloadCompleted = true;
        });
        print('✅ Предварительная загрузка завершена');
      }
    } catch (e) {
      print('❌ Ошибка предварительной загрузки: $e');
      // Даже при ошибке отмечаем как завершенное, чтобы не блокировать навигацию
      if (mounted) {
        setState(() {
          _preloadCompleted = true;
          _preloadedData = PreloadedData.empty();
        });
      }
    }
  }

  void _checkAuthAfterAnimation() {
    // Здесь будет логика проверки аутентификации
    // Пока просто имитируем задержку
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Получаем AuthBloc из контекста
        final authBloc = context.read<AuthBloc>();
        // Запускаем проверку токена
        authBloc.add(AuthCheckTokenRequested());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Навигация только после завершения анимации
        if (_animationCompleted) {
          if (state is AuthTokenValid) {
            // Передаем предварительно загруженные данные
            context.goNamed('home', extra: _preloadedData);
          } else if (state is AuthInitial) {
            context.goNamed('login');
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A), // Темно-серый
                Color(0xFF2D2D2D), // Светло-серый
                Color(0xFF1A1A1A), // Темно-серый
              ],
            ),
          ),
          child: Stack(
            children: [
              // Фоновые круги с анимацией
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BackgroundCirclesPainter(
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),

              // Основной контент
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Анимированный логотип/иконка
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Image.asset(
                                'logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Название приложения с анимацией
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'АЧПП',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: _colorAnimation.value ?? Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ассоциация частнопрактикующих\nпсихологов и психотерапевтов',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                  letterSpacing: 0.5,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 64),

                    // Анимированный индикатор загрузки
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _colorAnimation.value ?? const Color(0xFF6B46C1),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Декоративные элементы
              Positioned(
                top: 100,
                left: 50,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value * 0.3,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 150,
                right: 70,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value * 0.2,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 100,
                left: 100,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value * 0.25,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Кастомный painter для фоновых кругов
class BackgroundCirclesPainter extends CustomPainter {
  final double progress;

  BackgroundCirclesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF6B46C1).withOpacity(0.1 * progress);

    // Рисуем несколько кругов с разными радиусами
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.4;

    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * (0.3 + i * 0.2) * progress;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundCirclesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
