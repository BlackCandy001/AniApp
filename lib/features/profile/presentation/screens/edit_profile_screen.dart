import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/localization/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  String? _selectedAvatar;
  bool _isLoading = false;

  final List<String> _availableAvatars = [
    'assets/images/avatars/ava1.jpg',
    'assets/images/avatars/ava2.jpg',
    'assets/images/avatars/ava3.jpg',
    'assets/images/avatars/ava4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _selectedAvatar = user.avatarPath;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Thêm nén ảnh nhẹ để tránh tốn dung lượng và tương thích tốt hơn
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedAvatar = image.path;
        });
        // Tự động lưu avatar mới vào SQLite ngay lập tức để phòng tránh Android Activity Recreation
        await ref.read(authProvider.notifier).updateProfileWithPasswordCheck(
          newAvatarPath: image.path,
        );
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể truy cập thư viện ảnh: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final error = await ref.read(authProvider.notifier).updateProfileWithPasswordCheck(
        newUsername: _usernameController.text.trim(),
        newAvatarPath: _selectedAvatar,
        newEmail: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        final currentLang = ref.watch(languageProvider);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.get(currentLang, 'update_success')), backgroundColor: Colors.green));
          context.pop();
        }
      }
    }
  }

  ImageProvider _getAvatarImage(String avatarPath) {
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    } else if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    } else {
      return FileImage(File(avatarPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(currentLang, 'edit_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.get(currentLang, 'avatar'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // --- Chọn ảnh từ máy ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _selectedAvatar != null && _selectedAvatar!.isNotEmpty
                          ? _getAvatarImage(_selectedAvatar!)
                          : null,
                      child: (_selectedAvatar == null || _selectedAvatar!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // --- Chọn ảnh có sẵn (Local Assets) ---
              Text(AppLocalizations.get(currentLang, 'choose_avatar'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _availableAvatars.map((avatar) {
                  final isSelected = avatar == _selectedAvatar;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedAvatar = avatar;
                      });
                      await ref.read(authProvider.notifier).updateProfileWithPasswordCheck(
                        newAvatarPath: avatar,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(avatar),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              Text(AppLocalizations.get(currentLang, 'general_info'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(currentLang, 'display_name'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return AppLocalizations.get(currentLang, 'name_required');
                  if (val.length < 3) return AppLocalizations.get(currentLang, 'name_min_length');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(currentLang, 'email'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return AppLocalizations.get(currentLang, 'email_required');
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                    return AppLocalizations.get(currentLang, 'email_invalid');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              Text(AppLocalizations.get(currentLang, 'change_password'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(AppLocalizations.get(currentLang, 'password_hint'), style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(currentLang, 'current_password'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(currentLang, 'new_password'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return AppLocalizations.get(currentLang, 'password_min_length');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(AppLocalizations.get(currentLang, 'save_changes'), style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
