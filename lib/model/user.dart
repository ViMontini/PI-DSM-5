class User {
  final int id;
  final String username;
  final String email;
  final String authMethod; // Pode ser 'google' ou 'app_password'
  final String? pin;
  final String? password;
  final String? googleId; // Adicionando o ID do Google
  final String? profilePictureUrl; // URL da foto de perfil do Google

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.authMethod,
    this.pin,
    this.password,
    this.googleId,  // ID do Google
    this.profilePictureUrl,  // Foto de perfil do Google
  });

  factory User.fromSqfliteDatabase(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      authMethod: data['auth_method'],
      pin: data['pin'],
      password: data['password'],
      googleId: data['google_id'],  // Novo campo para o Google ID
      profilePictureUrl: data['profile_picture_url'],  // Novo campo para foto de perfil
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'auth_method': authMethod,
      'pin': pin,
      'password': password,
      'google_id': googleId,  // Google ID adicionado ao map
      'profile_picture_url': profilePictureUrl,  // URL da foto de perfil
    };
  }
}
