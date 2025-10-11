import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:achpp/models/meeting.dart';
import 'package:achpp/services/meeting_service.dart';

class MeetingCreateScreen extends StatefulWidget {
  const MeetingCreateScreen({super.key});

  @override
  State<MeetingCreateScreen> createState() => _MeetingCreateScreenState();
}

class _MeetingCreateScreenState extends State<MeetingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetingService _service = MeetingService();

  // Поля формы
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _date = TextEditingController(); // YYYY-MM-DD
  final TextEditingController _startTime = TextEditingController(); // HH:MM
  final TextEditingController _endTime = TextEditingController(); // HH:MM
  String? _imageFilePath;
  String _format = 'online';
  final TextEditingController _platform = TextEditingController();
  final TextEditingController _joinUrl = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _maxParticipants = TextEditingController();
  String _status = 'published'; // Пользователь не выбирает, используем значение по умолчанию
  final TextEditingController _notes = TextEditingController();

  bool _submitting = false;
  String? _error;

  Widget _buildCoverPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                image: _imageFilePath != null
                    ? DecorationImage(image: FileImage(File(_imageFilePath!)), fit: BoxFit.cover)
                    : null,
              ),
              child: _imageFilePath == null
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Обложка встречи',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _imageFilePath == null ? 'JPEG, PNG, WEBP • до 5MB' : _imageFilePath!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                if (picked != null) {
                  final file = File(picked.path);
                  final bytes = await file.length();
                  if (bytes > 5 * 1024 * 1024) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Размер файла не должен превышать 5MB')),
                      );
                    }
                    return;
                  }
                  setState(() {
                    _imageFilePath = picked.path;
                  });
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Загрузить'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                side: const BorderSide(color: Colors.white24),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _date.dispose();
    _startTime.dispose();
    _endTime.dispose();
    _platform.dispose();
    _joinUrl.dispose();
    _location.dispose();
    _maxParticipants.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final meeting = await _service.createMeeting(
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
        date: _date.text.trim(),
        startTime: _startTime.text.trim(),
        endTime: _endTime.text.trim(),
        format: _format,
        platform: _platform.text.trim().isEmpty ? null : _platform.text.trim(),
        joinUrl: _joinUrl.text.trim().isEmpty ? null : _joinUrl.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        maxParticipants: int.tryParse(_maxParticipants.text.trim()),
        status: _status,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        imageFilePath: _imageFilePath,
      );
      if (mounted) {
        Navigator.of(context).pop<Meeting>(meeting);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Новая встреча'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.event, color: Theme.of(context).colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Основная информация',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Название *',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Colors.white,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите название' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Colors.white,
                ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.access_time, color: Color(0xFF3B82F6), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Время и место проведения',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        decoration: InputDecoration(
                          labelText: 'Дата (YYYY-MM-DD) *',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                      readOnly: true,
                      onTap: () async {
                        final today = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: today,
                          lastDate: DateTime(today.year + 1, today.month, today.day),
                          helpText: 'Выберите дату встречи',
                          confirmText: 'Готово',
                          cancelText: 'Отмена',
                        );
                        if (picked != null) {
                          _date.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        }
                      },
                        validator: (v) => (v == null || !RegExp(r'^\\d{4}-\\d{2}-\\d{2}$').hasMatch(v)) ? 'Формат: YYYY-MM-DD' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _startTime,
                        decoration: InputDecoration(
                          labelText: 'Начало (HH:MM) *',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          helpText: 'Время начала',
                          confirmText: 'Готово',
                          cancelText: 'Отмена',
                        );
                        if (picked != null) {
                          _startTime.text = picked.format(context);
                          // Приводим к HH:MM
                          final hh = picked.hour.toString().padLeft(2, '0');
                          final mm = picked.minute.toString().padLeft(2, '0');
                          _startTime.text = '$hh:$mm';
                        }
                      },
                        validator: (v) => (v == null || !RegExp(r'^\\d{2}:\\d{2}$').hasMatch(v)) ? 'Формат: HH:MM' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _endTime,
                        decoration: InputDecoration(
                          labelText: 'Конец (HH:MM) *',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          helpText: 'Время окончания',
                          confirmText: 'Готово',
                          cancelText: 'Отмена',
                        );
                        if (picked != null) {
                          final hh = picked.hour.toString().padLeft(2, '0');
                          final mm = picked.minute.toString().padLeft(2, '0');
                          _endTime.text = '$hh:$mm';
                        }
                      },
                        validator: (v) => (v == null || !RegExp(r'^\\d{2}:\\d{2}$').hasMatch(v)) ? 'Формат: HH:MM' : null,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              const Text(
                'Если встреча переходит на следующий день, укажите время окончания меньше времени начала.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
                      const SizedBox(height: 12),
                // Формат
                DropdownButtonFormField<String>(
                  value: _format,
                  decoration: InputDecoration(
                    labelText: 'Формат *',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
                  iconEnabledColor: Theme.of(context).colorScheme.onSurface,
                  iconDisabledColor: Theme.of(context).colorScheme.onSurface,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  items: [
                    DropdownMenuItem(value: 'online', child: Text('Онлайн', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    DropdownMenuItem(value: 'offline', child: Text('Офлайн', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    DropdownMenuItem(value: 'hybrid', child: Text('Гибрид', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                  ],
                  onChanged: (v) => setState(() => _format = v ?? 'online'),
                ),
                      const SizedBox(height: 12),
                      // Обложка встречи
                      _buildCoverPicker(),
                      const SizedBox(height: 12),
                if (_format != 'offline') ...[
                  TextFormField(
                    controller: _platform,
                    decoration: InputDecoration(
                      labelText: 'Платформа (Zoom и т.п.)',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _joinUrl,
                    decoration: InputDecoration(
                      labelText: 'Ссылка для подключения',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
                if (_format != 'online') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _location,
                    decoration: InputDecoration(
                      labelText: 'Локация',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
                      const SizedBox(height: 12),
                TextFormField(
                  controller: _maxParticipants,
                  decoration: InputDecoration(
                    labelText: 'Макс. участников',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Colors.white,
                ),
                      const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: InputDecoration(
                    labelText: 'Заметки',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  maxLines: 2,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Colors.white,
                ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: const Icon(Icons.check),
                    label: Text(_submitting ? 'Создание...' : 'Создать встречу'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


