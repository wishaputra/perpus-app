class User {
  final String id;
  final String username;
  final String nama;
  final String role;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.nama,
    required this.role,
    this.token,
  });
}
