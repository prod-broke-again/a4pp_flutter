import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/blocs/auth/auth_bloc.dart';
import 'package:mobile/repositories/auth_repository.dart';
import 'package:mobile/services/preload_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/courses/courses_screen.dart';
import 'screens/courses/course_details_screen.dart';
import 'screens/clubs/clubs_screen.dart';
import 'screens/clubs/club_details_screen.dart';
import 'screens/meetings/meetings_screen.dart';
import 'screens/video_library/video_library_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/blog/blog_screen.dart';
import 'screens/balance/balance_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'models/user.dart';
import 'models/subscription.dart';
import 'models/course.dart';
import 'models/club.dart';

void main() {
  runApp(const PsychologistApp());
}

class PsychologistApp extends StatefulWidget {
  const PsychologistApp({super.key});

  @override
  State<PsychologistApp> createState() => _PsychologistAppState();
}

class _PsychologistAppState extends State<PsychologistApp> {
  final AuthRepository _authRepository = AuthRepository();
  late AuthBloc _authBloc;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: _authRepository);
    _initializeRouter();
  }

  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            final preloadedData = state.extra as PreloadedData?;
            return MainScreen(preloadedData: preloadedData);
          },
          routes: [
            GoRoute(
              path: 'courses',
              name: 'courses',
              builder: (context, state) => const CoursesScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  name: 'course-details',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug'] ?? '';
                    // Создаем временный курс с slug для загрузки данных
                    final course = Course(
                      id: 0,
                      title: '',
                      slug: slug,
                      description: '',
                      shortDescription: '',
                      image: null,
                      maxParticipants: 0,
                      publishedAt: DateTime.now(),
                      formattedPublishedAt: '',
                      zoomLink: null,
                      materialsFolderUrl: null,
                      autoMaterials: false,
                      productLevel: 0,
                      isHidden: false,
                      isFavoritedByUser: false,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      contentCount: 0,
                    );
                    return CourseDetailsScreen(course: course);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'clubs',
              name: 'clubs',
              builder: (context, state) => const ClubsScreen(),
              routes: [
                GoRoute(
                  path: ':slug',
                  name: 'club-details',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug'] ?? '';
                    // Создаем временный клуб с slug для загрузки данных
                    final club = Club(
                      id: 0,
                      name: '',
                      slug: slug,
                      description: '',
                      image: null,
                      zoomLink: null,
                      materialsFolderUrl: null,
                      autoMaterials: false,
                      currentDonations: 0.0,
                      formattedCurrentDonations: '',
                      status: '',
                      productLevel: 0,
                      owner: User(
                        id: 0,
                        email: '',
                        balance: 0,
                        auto: false,
                        psyLance: false,
                        role: Role(name: '', color: ''),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      isFavoritedByUser: false,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      speakers: '',
                    );
                    return ClubDetailsScreen(club: club);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'meetings',
              name: 'meetings',
              builder: (context, state) => const MeetingsScreen(),
            ),
            GoRoute(
              path: 'videos',
              name: 'videos',
              builder: (context, state) => const VideoLibraryScreen(rootFolders: []),
            ),
            GoRoute(
              path: 'subscription',
              name: 'subscription',
              builder: (context, state) => SubscriptionScreen(
                currentSubscription: Subscription(
                  id: 0,
                  productId: 0,
                  userId: 0,
                  status: '',
                  expiresAt: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  amount: 0,
                  autoRenew: false,
                  currency: '',
                  startsAt: DateTime.now(),
                ),
                availablePlans: const [],
              ),
            ),
            GoRoute(
              path: 'transactions',
              name: 'transactions',
              builder: (context, state) => const TransactionsScreen(
                transactions: [],
                currentBalance: 0,
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => SettingsScreen(
                user: User(
                  id: 0,
                  email: '',
                  balance: 0,
                  auto: false,
                  psyLance: false,
                  role: Role(name: '', color: ''),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
            GoRoute(
              path: 'blog',
              name: 'blog',
              builder: (context, state) => const BlogScreen(),
            ),
            GoRoute(
              path: 'balance',
              name: 'balance',
              builder: (context, state) => const BalanceScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6B46C1),
        secondary: Color(0xFF8B5CF6),
        surface: Color(0xFF2D2D2D),
        background: Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      fontFamilyFallback: ['Roboto', 'Noto Sans', 'Arial', 'sans-serif'],
      textTheme: GoogleFonts.nunitoTextTheme(textTheme).copyWith(
        bodyLarge: GoogleFonts.nunito(),
        bodyMedium: GoogleFonts.nunito(),
        bodySmall: GoogleFonts.nunito(),
        headlineLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.nunito(fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6B46C1),
          side: const BorderSide(color: Color(0xFF6B46C1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6B46C1),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => _authRepository),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'АЧПП - Ассоциация частнопрактикующих психологов и психотерапевтов',
          debugShowCheckedModeBanner: false,
          theme: theme,
          routerConfig: _router,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }
}
