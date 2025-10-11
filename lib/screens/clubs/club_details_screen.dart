import 'package:flutter/material.dart';
import 'package:achpp/models/club.dart';
import 'package:achpp/models/club_meeting.dart';
import 'package:achpp/services/auth_service.dart';
import 'package:achpp/widgets/donation_dialog.dart';
import 'package:achpp/utils/intl_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class ClubDetailsScreen extends StatefulWidget {
  final Club club;

  const ClubDetailsScreen({super.key, required this.club});

  @override
  State<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  final AuthService _authService = AuthService();
  Club? _club;
  bool _isLoading = true;
  String? _error;
  bool _canAccess = false;

  @override
  void initState() {
    super.initState();
    _loadClubDetails();
  }

  Future<void> _loadClubDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _authService.getClub(widget.club.slug);
      setState(() {
        _club = Club.fromJson(data['club']);
        _canAccess = (_club?.zoomLink != null && _club!.zoomLink!.isNotEmpty) ||
            (_club?.materialsFolderUrl != null && _club!.materialsFolderUrl!.isNotEmpty);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _donateToClub() async {
    if (_club == null) return;
    showDialog(
      context: context,
      builder: (context) => DonationDialog(
        title: 'Поддержать клуб',
        modelName: _club!.name,
        fixedAmounts: const [100, 300, 500, 1000, 2000, 5000],
        minAmount: 50,
        onSubmit: (amount) async {
          Navigator.of(context).pop();
          try {
            final data = await _authService.donateToClub(_club!.slug, amount.toDouble());
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Спасибо! Транзакция #${data['transaction_id'] ?? ''}'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            _loadClubDetails();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка доната: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    try {
      await _authService.toggleFavorite(
        favorableId: _club!.id,
        favorableType: 'App\\Models\\Club',
      );
      setState(() {
        _club = Club(
          id: _club!.id,
          name: _club!.name,
          slug: _club!.slug,
          description: _club!.description,
          image: _club!.image,
          zoomLink: _club!.zoomLink,
          materialsFolderUrl: _club!.materialsFolderUrl,
          autoMaterials: _club!.autoMaterials,
          currentDonations: _club!.currentDonations,
          formattedCurrentDonations: _club!.formattedCurrentDonations,
          status: _club!.status,
          productLevel: _club!.productLevel,
          owner: _club!.owner,
          isFavoritedByUser: !_club!.isFavoritedByUser,
          createdAt: _club!.createdAt,
          updatedAt: _club!.updatedAt,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки клуба. Попробуйте позже.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ошибка загрузки клуба:\n\n$_error',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _loadClubDetails,
                          child: const Text('Повторить'),
                        )
                      ],
                    ),
                  ),
                )
              : _club == null
                  ? Center(
                      child: Text(
                        'Клуб не найден',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                _club!.image != null
                                    ? Image.network(
                                        _club!.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimary, size: 64),
                                        ),
                                      )
                                    : Container(
                        color: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.group, color: Theme.of(context).colorScheme.onPrimary, size: 64),
                                      ),
                                // Градиент для читаемости (как в курсе)
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xCC000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                ),
                                // Название клуба
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    _club!.name,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            IconButton(
                              onPressed: _toggleFavorite,
                              padding: const EdgeInsets.only(right: 8),
                              icon: Icon(
                                _club!.isFavoritedByUser ? Icons.favorite : Icons.favorite_border,
                                color: _club!.isFavoritedByUser ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Builder(
                                        builder: (context) {
                                          final hasZoom = _club!.zoomLink != null && _club!.zoomLink!.isNotEmpty;
                                          if (hasZoom && _canAccess) {
                                            return ElevatedButton.icon(
                                              onPressed: () async {
                                                final url = _club!.zoomLink!;
                                                final uri = Uri.tryParse(url);
                                                if (uri != null) {
                                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                }
                                              },
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text('Подключиться'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                          if (!_canAccess) {
                                            final needUpgrade = (_club!.productLevel > 1);
                                            return ElevatedButton.icon(
                                              onPressed: _openSubscription,
                                              icon: const Icon(Icons.shopping_bag_outlined),
                                              label: Text(needUpgrade ? 'Улучшить тариф' : 'Выбрать тариф'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            );
                                          }
                                          return OutlinedButton(
                                            onPressed: null,
                                            style: OutlinedButton.styleFrom(
                                              disabledForegroundColor: Colors.grey,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('Изучить клуб'),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _donateToClub,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                                          foregroundColor: Theme.of(context).colorScheme.tertiary,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        icon: const Icon(Icons.card_giftcard, size: 18),
                                        label: const Text('Поддержать клуб'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_club!.materialsFolderUrl != null && _club!.materialsFolderUrl!.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: Builder(
                                      builder: (context) {
                                        if (_canAccess) {
                                          return OutlinedButton.icon(
                                            onPressed: () async {
                                              final url = _club!.materialsFolderUrl!;
                                              final uri = Uri.tryParse(url);
                                              if (uri != null) {
                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                              foregroundColor: Theme.of(context).colorScheme.secondary,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.folder_open, size: 18),
                                            label: const Text('Открыть материалы'),
                                          );
                                        }
                                        final needUpgrade = (_club!.productLevel > 1);
                                        return ElevatedButton.icon(
                                          onPressed: _openSubscription,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.shopping_bag_outlined),
                                          label: Text(needUpgrade ? 'Улучшить тариф для материалов' : 'Выбрать тариф для материалов'),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                // О клубе (HTML)
                                Text(
                                  'О клубе',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  ),
                                  child: Html(
                                    data: _club!.description,
                                    style: {
                                      'body': Style(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: FontSize(16),
                                        lineHeight: LineHeight.number(1.5),
                                      ),
                                      'p': Style(margin: Margins.only(bottom: 8)),
                                      'strong': Style(color: Theme.of(context).colorScheme.onSurface),
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Ближайшая встреча
                                if (_club!.nextMeeting != null) ...[
                                Text(
                                    'Ближайшая встреча',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                  _buildNextMeetingCard(_club!.nextMeeting!),
                                const SizedBox(height: 24),
                                ],
                                
                                // Расписание встреч
                                if ((_club!.meetings?.isNotEmpty ?? false)) ...[
                                Row(
                                  children: [
                                      Text(
                                        'Расписание встреч',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainer,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                                        ),
                                        child: Text(
                                          formatCountRu(_club!.meetings!.length, ['встреча', 'встречи', 'встреч']),
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                  const SizedBox(height: 12),
                                  _buildMeetingsList(_club!.meetings!),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B46C1), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildNextMeetingCard(ClubMeeting meeting) {
    final dateLine = _formatMeetingLine(meeting);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLine.isNotEmpty ? dateLine : 'Встреча', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Длительность: ${meeting.getDuration()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          if ((meeting.speakers ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(child: Text(meeting.speakers!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatMeetingLine(ClubMeeting meeting) {
    // Форматируем дату из YYYY-MM-DD в DD.MM.YYYY
    String date = '';
    if (meeting.date.isNotEmpty) {
      try {
        final d = DateTime.tryParse(meeting.date);
        if (d != null) {
          final dd = d.day.toString().padLeft(2, '0');
          final mm = d.month.toString().padLeft(2, '0');
          final yyyy = d.year.toString();
          date = '$dd.$mm.$yyyy';
        } else {
          date = meeting.date;
        }
      } catch (_) {
        date = meeting.date;
      }
    }

    // Извлекаем время HH:MM из ISO строк startTime и endTime
    String start = '';
    String end = '';
    try {
      if (meeting.startTime.isNotEmpty) {
        final startDt = DateTime.parse(meeting.startTime);
        start = '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
      }
      if (meeting.endTime.isNotEmpty) {
        final endDt = DateTime.parse(meeting.endTime);
        end = '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      // Если не удалось распарсить, оставляем пустыми
    }

    final timePart = (start.isNotEmpty && end.isNotEmpty) ? '$start–$end' : '';

    final parts = [if (date.isNotEmpty) date, if (timePart.isNotEmpty) timePart];
    return parts.join(' • ');
  }

  Widget _buildMeetingsList(List<ClubMeeting> meetings) {
    return Column(
      children: [
        for (int index = 0; index < meetings.length; index++)
          Container(
            margin: EdgeInsets.only(bottom: index < meetings.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.event, color: Color(0xFF6B46C1), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatMeetingLine(meetings[index]),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _chip(icon: Icons.access_time, text: 'Длительность: ${meetings[index].getDuration()}'),
                          if ((meetings[index].speakers ?? '').isNotEmpty)
                            _chip(icon: Icons.person, text: meetings[index].speakers!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ],
      ),
    );
  }

  void _openSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Откройте раздел подписки для изменения тарифа'),
        backgroundColor: Color(0xFFF59E0B),
      ),
    );
  }
}
