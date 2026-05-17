class UserModel {
  final int? id;
  final String email;
  final String password;
  final String username;
  final String? avatarPath;
  final String createdAt;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    this.avatarPath,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      username: map['username'],
      avatarPath: map['avatar_path'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'password': password,
      'username': username,
      'avatar_path': avatarPath,
      'created_at': createdAt,
    };
  }
}
