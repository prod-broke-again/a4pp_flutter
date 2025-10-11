import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:achpp/models/course.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/auth_service.dart';
import 'package:achpp/widgets/universal_card.dart';
import '../../widgets/app_drawer.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const CoursesScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _authService.getCourses(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (data == null) {
        setState(() {
          _error = 'API вернул null';
          _isLoading = false;
        });
        return;
      }

      if (!data.containsKey('courses')) {
        setState(() {
          _error = 'В ответе API отсутствует ключ "courses"';
          _isLoading = false;
        });
        return;
      }

      final coursesData = data['courses'] as List<dynamic>;

      setState(() {
        _courses = coursesData.map((course) {
          try {
            return Course.fromJson(course);
          } catch (e) {
            rethrow;
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Используем системную тему
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Курсы'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        subscriptionStatus: widget.subscriptionStatus,
        products: widget.products,
        currentIndex: 0,
        onIndexChanged: (_) {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Описание
              Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Text(
                  'Профессиональные занятия и мастер-классы для развития навыков в области психотерапии',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Поиск
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _loadCourses(),
                  decoration: InputDecoration(
                    hintText: 'Поиск курсов...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadCourses();
                            },
                            icon: const Icon(Icons.clear, color: Colors.grey),
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 16),

              // Контент
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки курсов',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCourses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_courses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Курсы не найдены',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Попробуйте изменить параметры поиска или обратитесь к администратору',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 
                          ? 3 
                          : constraints.maxWidth > 400 
                              ? 2 
                              : 1;
                      
                      return Column(
                        children: [
                          for (int i = 0; i < _courses.length; i += crossAxisCount)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i + crossAxisCount < _courses.length ? 16 : 0,
                              ),
                              child: Row(
                                children: [
                                  for (int j = 0; j < crossAxisCount && i + j < _courses.length; j++)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: j < crossAxisCount - 1 ? 16 : 0,
                                        ),
                                        child: UniversalCard(
                                          item: _courses[i + j],
                                          onTap: () => _navigateToCourseDetails(_courses[i + j]),
                                          onToggleFavorite: () => _toggleFavorite(_courses[i + j]),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }




  Future<void> _toggleFavorite(Course course) async {
    try {
      await _authService.toggleFavorite(
        favorableId: course.id,
        favorableType: 'App\\Models\\Course',
      );
      setState(() {
        // Обновляем статус избранного для курса
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index != -1) {
          _courses[index] = Course(
            id: course.id,
            title: course.title,
            slug: course.slug,
            description: course.description,
            shortDescription: course.shortDescription,
            image: course.image,
            maxParticipants: course.maxParticipants,
            publishedAt: course.publishedAt,
            formattedPublishedAt: course.formattedPublishedAt,
            zoomLink: course.zoomLink,
            materialsFolderUrl: course.materialsFolderUrl,
            autoMaterials: course.autoMaterials,
            productLevel: course.productLevel,
            isHidden: course.isHidden,
            isFavoritedByUser: !course.isFavoritedByUser,
            createdAt: course.createdAt,
            updatedAt: course.updatedAt,
            contentCount: course.contentCount,
            nextContent: course.nextContent,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки курсов. Попробуйте позже.')),
      );
    }
  }

  void _navigateToCourseDetails(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(course: course),
      ),
    );
  }



  void _processDonation(int amount) {
    // TODO: Реализовать логику доната
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Донат на сумму $amount₽ отправлен'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Дата не указана';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
