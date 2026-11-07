class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // stduent or staff

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? 'student',
  );

  Map<String, dynamic> toMap() => {'name': name, 'email': email, 'role': role};
}
