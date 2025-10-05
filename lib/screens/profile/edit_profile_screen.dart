import 'package:flutter/material.dart';
import 'package:achpp/models/user.dart';
import 'package:achpp/models/subscription.dart';
import 'package:achpp/models/product.dart';
import 'package:achpp/models/profile_response.dart';
import 'package:achpp/services/api_client.dart';
import 'package:achpp/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_drawer.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final SubscriptionStatus? subscriptionStatus;
  final List<Product> products;
  final Function(User)? onUserUpdated;

  const EditProfileScreen({super.key, required this.user, this.subscriptionStatus, this.products = const [], this.onUserUpdated});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthRepository _authRepository = AuthRepository();
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _firstname;
  late TextEditingController _lastname;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _bio;
  bool _saving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _firstname = TextEditingController(text: widget.user.fullName);
    _lastname = TextEditingController(text: widget.user.lastname ?? '');
    _email = TextEditingController(text: widget.user.email);
    _phone = TextEditingController(text: widget.user.phone ?? '');
    _bio = TextEditingController(text: widget.user.bio ?? '');
    _avatarUrl = widget.user.avatar;
  }

  @override
  void dispose() {
    _firstname.dispose();
    _lastname.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Редактирование профиля', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Редактирование профиля', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Аватар + кнопка изменить (заглушка)
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF6B46C1),
                    backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Text(
                            widget.user.fullName.isNotEmpty && (widget.user.lastname?.isNotEmpty ?? false)
                                ? '${widget.user.fullName[0]}${widget.user.lastname![0]}'
                                : widget.user.fullName.isNotEmpty 
                                    ? widget.user.fullName[0].toUpperCase()
                                    : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _showAvatarOptions,
                    icon: const Icon(Icons.photo_camera, size: 18),
                    label: const Text('Изменить аватар'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildField('Имя', _firstname),
              _buildField('Фамилия', _lastname),

              // Email (только через техподдержку)
              _buildField(
                'Email',
                _email,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                helperText: 'Изменение email — через техподдержку',
              ),

              // Телефон (только через техподдержку)
              _buildField(
                'Телефон',
                _phone,
                keyboardType: TextInputType.phone,
                readOnly: true,
                helperText: 'Изменение номера — через техподдержку',
              ),

              // Описание / Bio
              _buildField(
                'О себе (bio)',
                _bio,
                maxLines: 5,
                hintText: 'Коротко о себе, специализация, интересы...'
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
    String? helperText,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              helperText: helperText,
              helperStyle: const TextStyle(color: Colors.grey),
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _save() async {
    try {
      setState(() => _saving = true);

      final payload = {
        if (_firstname.text.trim().isNotEmpty) 'firstname': _firstname.text.trim(),
        if (_lastname.text.trim().isNotEmpty) 'lastname': _lastname.text.trim(),
        'bio': _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      };

      final updatedUser = await _authRepository.updateProfile(payload);

      // Вызываем callback для обновления пользователя в родительском виджете
      widget.onUserUpdated?.call(updatedUser);

      if (!mounted) return;

      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль обновлен'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF8B5CF6)),
              title: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF8B5CF6)),
              title: const Text('Сделать фото', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _saving = true);
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 768,
        maxHeight: 768,
        imageQuality: 88,
      );
      if (image == null) {
        setState(() => _saving = false);
        return;
      }
      await _uploadAvatar(File(image.path));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выбора изображения: $e')),
      );
    }
  }

  Future<void> _uploadAvatar(File file) async {
    try {
      final response = await _apiClient.postFile('/profile/avatar', file, fieldName: 'avatar');
      // Ожидаем { success: true, data: { avatar_url: ... } }
      final data = response.data;
      final avatarUrl = (data is Map && data['data'] is Map) ? data['data']['avatar_url'] as String? : null;
      if (avatarUrl != null) {
        setState(() {
          _avatarUrl = avatarUrl;
          _saving = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аватар обновлен')),
        );
      } else {
        throw 'Некорректный ответ сервера';
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки аватара: $e')),
      );
    }
  }
}


