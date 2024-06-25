class User {
  final int id;
  final String username;
  final String email;
  final String authMethod;
  final String? pin;
  final String? password;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.authMethod,
    this.pin,
    this.password,
  });

  factory User.fromSqfliteDatabase(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      authMethod: data['auth_method'],
      pin: data['pin'],
      password: data['password'],
    );
  }
}
