import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart'; // Para hash de senha
import '../model/user.dart';
import 'database_service.dart';

class UserDB {
  final tableName = 'usuario';

  // Atualizando a criação da tabela para incluir google_id e profile_picture_url
  Future<void> createUser(Database database) async {
    await database.execute('''
    CREATE TABLE IF NOT EXISTS $tableName (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "username" TEXT NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      "auth_method" TEXT NOT NULL,
      "pin" TEXT,
      "password" TEXT,
      "google_id" TEXT,                     -- Novo campo para o ID do Google
      "profile_picture_url" TEXT,            -- Novo campo para a URL da foto de perfil
      "status_sync" INTEGER NOT NULL DEFAULT 0
    );
    ''');
  }

  // Cria um usuário
  Future<int> create({
    required String username,
    required String email,
    required String authMethod,
    String? pin,
    String? password,
    String? googleId,
    String? profilePictureUrl,
  }) async {
    final database = await DatabaseService().database;

    // Inserir o usuário no banco de dados
    return await database.insert(
      tableName,
      {
        'username': username,
        'email': email,
        'auth_method': authMethod,
        'pin': pin,
        'password': password != null ? hashPassword(password) : null, // Hash da senha se presente
        'google_id': googleId,
        'profile_picture_url': profilePictureUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }


  // Busca usuário pelo email
  Future<User?> fetchUserByEmail(String email) async {
    final database = await DatabaseService().database;
    final result = await database.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromSqfliteDatabase(result.first);
    }
    return null;
  }

  // Busca usuário pelo ID
  Future<User?> fetchUserById(int id) async {
    final database = await DatabaseService().database;
    final result = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromSqfliteDatabase(result.first);
    }
    return null;
  }

  // Função para atualizar a senha de um usuário pelo email
  Future<int> updatePassword(String email, String newPassword) async {
    final database = await DatabaseService().database;

    return await database.update(
      tableName,
      {'password': newPassword}, // Atualiza a senha
      where: 'email = ?',        // Busca pelo email
      whereArgs: [email],
    );
  }

  // Busca o usuário no banco de dados local usando o Google ID
  Future<User?> fetchUserByGoogleId(String googleId) async {
    final db = await DatabaseService().database; // Obtenha a instância do banco de dados
    final List<Map<String, dynamic>> result = await db.query(
      'usuario',
      where: 'google_id = ?',
      whereArgs: [googleId],
    );

    if (result.isNotEmpty) {
      return User.fromSqfliteDatabase(result.first); // Converta o resultado para um objeto User
    } else {
      return null; // Retorna null se não encontrar o usuário
    }
  }

  // Atualiza as informações do usuário no banco de dados local
  Future<void> updateUser({
    required int id,
    required String username,
    required String email,
    String? profilePictureUrl,
  }) async {
    final db = await DatabaseService().database; // Obtenha a instância do banco de dados
    await db.update(
      'usuario',
      {
        'username': username,
        'email': email,
        'profile_picture_url': profilePictureUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualiza a senha no banco local usando o user_id
  Future<int> updatePasswordById(int userId, String newPassword) async {
    final database = await DatabaseService().database;

    return await database.update(
      'usuario',
      {'password': newPassword},
      where: 'id = ?',  // Filtra pelo user_id
      whereArgs: [userId],
    );
  }

  // Verifica a senha do usuário
  Future<bool> verifyPassword(String email, String inputPassword) async {
    final user = await fetchUserByEmail(email);
    if (user != null && user.password != null) {
      return BCrypt.checkpw(inputPassword, user.password!);  // Verificar senha hasheada
    }
    return false;
  }

  // Função para hashear a senha
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  Future<String?> getPassword(int userId) async {
    final db = await DatabaseService().database;
    final result = await db.query(
      'usuario',
      columns: ['password'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['password'] as String?;
    }
    return null;
  }
}
