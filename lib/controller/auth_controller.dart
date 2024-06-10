import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/user.dart';

class AuthController {
  final _storage = FlutterSecureStorage();

  Future<void> saveUser(User user) async {
    await _storage.write(key: 'userName', value: user.name);
    await _storage.write(key: 'credentialMethod', value: user.credentialMethod);
  }

  Future<User?> getUser() async {
    String? name = await _storage.read(key: 'userName');
    String? credentialMethod = await _storage.read(key: 'credentialMethod');
    if (name != null && credentialMethod != null) {
      return User(name: name, credentialMethod: credentialMethod);
    }
    return null;
  }
}