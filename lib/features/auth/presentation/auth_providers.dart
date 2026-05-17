import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/local/database_helper.dart';

/// Provider kiểm tra trạng thái khởi tạo xác thực (dùng cho redirect guard trong GoRouter).
final authInitProvider = StateProvider<bool>((ref) => false);

/// Provider quản lý đăng nhập / đăng ký người dùng.
/// Giá trị là [UserModel] nếu đã đăng nhập, null nếu chưa.
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref);
});

/// Notifier xử lý đăng nhập, đăng ký, đăng xuất và cập nhật hồ sơ.
/// Dữ liệu người dùng lưu trong SQLite, phiên làm việc lưu trong [SharedPreferences].
class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref ref;

  AuthNotifier(this.ref) : super(null) {
    _loadUser(); // Tự động load phiên đăng nhập khi khởi tạo app
  }

  /// Tải lại thông tin người dùng từ DB dựa trên ID được lưu trong SharedPreferences.
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('logged_in_user_id');
      if (userId != null) {
        final db = await DatabaseHelper.instance.database;
        final maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);
        if (maps.isNotEmpty) {
          state = UserModel.fromMap(maps.first);
          ref.read(authInitProvider.notifier).state = true;
          return;
        }
      }
    } catch (e) {
      // Ignored
    }
    
    // Việc router đọc biến isInit sẽ tự động thực hiện sau đó.
    ref.read(authInitProvider.notifier).state = true;
  }

  /// Đăng nhập bằng email + password. Trả về null nếu thành công, cỗi lỗi nếu thất bại.
  Future<String?> login(String email, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (maps.isNotEmpty) {
        final user = UserModel.fromMap(maps.first);
        state = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('logged_in_user_id', user.id!);
        return null; // Success
      } else {
        return 'Email hoặc mật khẩu không chính xác';
      }
    } catch (e) {
      return 'Lỗi hệ thống: $e';
    }
  }

  Future<String?> register(String email, String password, String username) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Check email exists
      final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
      if (existing.isNotEmpty) {
        return 'Email này đã được đăng ký';
      }

      final user = UserModel(
        email: email,
        password: password,
        username: username,
        createdAt: DateTime.now().toIso8601String(),
      );

      final id = await db.insert('users', user.toMap());
      final newUser = UserModel(
        id: id,
        email: email,
        password: password,
        username: username,
        createdAt: user.createdAt,
      );
      
      state = newUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('logged_in_user_id', id);
      return null; // Success
    } catch (e) {
      return 'Lỗi hệ thống: $e';
    }
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_id');
  }

  Future<String?> updateProfileWithPasswordCheck({
    String? newUsername, 
    String? newAvatarPath,
    String? newEmail,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (state == null) return 'Không tìm thấy người dùng';
    
    final db = await DatabaseHelper.instance.database;
    
    // Nếu có đổi email hoặc password, bắt buộc phải cung cấp mật khẩu cũ đúng
    final isChangingEmail = newEmail != null && newEmail.isNotEmpty && newEmail != state!.email;
    final isChangingPassword = newPassword != null && newPassword.isNotEmpty;

    if (isChangingEmail || isChangingPassword) {
      if (currentPassword == null || currentPassword.isEmpty) {
         return 'Vui lòng nhập mật khẩu hiện tại để thay đổi Email/Mật khẩu';
      }
      if (currentPassword != state!.password) {
         return 'Mật khẩu hiện tại không đúng';
      }
    }
    
    // Validate email if changed
    if (isChangingEmail) {
      final existing = await db.query('users', where: 'email = ?', whereArgs: [newEmail]);
      if (existing.isNotEmpty) {
        return 'Email này đã được sử dụng bởi tài khoản khác';
      }
    }

    final updatedMap = {
      if (newUsername?.isNotEmpty ?? false) 'username': newUsername,
      if (newAvatarPath != null) 'avatar_path': newAvatarPath,
      if (isChangingEmail) 'email': newEmail,
      if (isChangingPassword) 'password': newPassword,
    };
    
    if (updatedMap.isNotEmpty) {
      await db.update('users', updatedMap, where: 'id = ?', whereArgs: [state!.id]);
      
      final maps = await db.query('users', where: 'id = ?', whereArgs: [state!.id]);
      if (maps.isNotEmpty) {
        state = UserModel.fromMap(maps.first);
      }
    }
    return null; // success
  }
}
