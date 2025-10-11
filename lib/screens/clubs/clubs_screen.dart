import 'package:flutter/material.dart';
import 'package:achpp/models/club.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/auth_service.dart';
import 'package:achpp/widgets/universal_card.dart';
import '../../widgets/app_drawer.dart';
import 'club_details_screen.dart';

class ClubsScreen extends StatefulWidget {
  final User? user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;

  const ClubsScreen({
    super.key,
    this.user,
    this.subscriptionStatus,
    this.products = const [],
  });

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  List<Club> _clubs = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _authService.getClubs(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: 'active',
        sort: 'created_at',
        order: 'desc',
      );
      
      final clubsData = data['clubs'] as List<dynamic>? ?? [];
      final clubs = clubsData.map((json) => Club.fromJson(json)).toList();
      
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _donateToClub(Club club) async {
    final amountController = TextEditingController();
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Донат в клуб',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              club.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Клуб активен',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Сумма доната (₽)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Введите сумму',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: '₽ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _authService.donateToClub(club.slug, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Донат успешно отправлен!')),
          );
          _loadClubs(); // Обновляем список
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка загрузки клубов. Попробуйте позже.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Клубы'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: _loadClubs,
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
        child: Column(
          children: [
            // Описание
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: const Text(
                'Профессиональные сообщества с регулярными встречами для обмена опытом и развития навыков',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (_) => _loadClubs(),
                decoration: InputDecoration(
                  hintText: 'Поиск клубов...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadClubs();
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

            // Контент
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'Ошибка загрузки',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadClubs,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        )
                      : _clubs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Клубы не найдены',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Попробуйте изменить поисковый запрос',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _clubs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: UniversalCard(
                                    item: _clubs[index],
                                    onTap: () => _navigateToClubDetails(_clubs[index]),
                                    onToggleFavorite: () => _toggleFavorite(_clubs[index]),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Старый метод удален - теперь используется UniversalCard
  Widget _buildClubCardOld(Club club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        onTap: () => _navigateToClubDetails(club),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Изображение клуба
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: club.image != null
                    ? Image.network(
                        club.image!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: const Color(0xFF6B46C1),
                          child: const Icon(Icons.group, color: Colors.white, size: 48),
                        ),
                      )
                    : Container(
                        height: 160,
                        color: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimary, size: 48),
                      ),
              ),
              // Статус
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: club.status == 'active'
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
                        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    club.status == 'active' ? 'Активен' : 'Неактивен',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Уровень доступа
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: club.productLevel > 1
                        ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.9)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    club.productLevel > 1 ? 'Премиум' : 'Базовый',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Кнопка избранного
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(club),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      club.isFavoritedByUser ? Icons.favorite : Icons.favorite_border,
                      color: club.isFavoritedByUser ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Информация о клубе
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название
                Text(
                  club.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Описание
                Text(
                  club.description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 12),
                
                // Статистика
                Row(
                  children: [
                    _buildStat(Icons.star, club.productLevel > 1 ? 'Премиум' : 'Базовый'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateToClubDetails(club),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Подробнее',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _donateToClub(club),
                        icon: const Icon(Icons.favorite, size: 16),
                        label: const Text('Донат'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(Club club) async {
    try {
      await _authService.toggleFavorite(
        favorableId: club.id,
        favorableType: 'App\\Models\\Club',
      );
      setState(() {
        // Обновляем статус избранного для клуба
        final index = _clubs.indexWhere((c) => c.id == club.id);
        if (index != -1) {
          _clubs[index] = Club(
            id: club.id,
            name: club.name,
            slug: club.slug,
            description: club.description,
            image: club.image,
            zoomLink: club.zoomLink,
            materialsFolderUrl: club.materialsFolderUrl,
            autoMaterials: club.autoMaterials,
            currentDonations: club.currentDonations,
            formattedCurrentDonations: club.formattedCurrentDonations,
            status: club.status,
            productLevel: club.productLevel,
            owner: club.owner,
            isFavoritedByUser: !club.isFavoritedByUser,
            createdAt: club.createdAt,
            updatedAt: club.updatedAt,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _navigateToClubDetails(Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailsScreen(club: club),
      ),
    );
  }
}
