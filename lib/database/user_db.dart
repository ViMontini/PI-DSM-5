import 'package:sqflite/sqflite.dart';
import '../model/user.dart';
import 'database_service.dart';

class UserDB {
  final tableName = 'users';

  Future<void> createUser(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $tableName (
      "id" INTEGER NOT NULL,
      "username" TEXT NOT NULL,
      "email" TEXT NOT NULL,
      "auth_method" TEXT NOT NULL,
      "pin" TEXT,
      "password" TEXT,
      PRIMARY KEY ("id" AUTOINCREMENT)
    );
    """);
  }

  Future<int> create({required String username, required String email, required String authMethod, String? pin, String? password}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (username, email, auth_method, pin, password) VALUES (?, ?, ?, ?, ?)''',
      [username, email, authMethod, pin, password],
    );
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.rawQuery('''SELECT * FROM $tableName''');
    return users.map((user) => User.fromSqfliteDatabase(user)).toList();
  }

  Future<User> fetchById(int id) async {
    final database = await DatabaseService().database;
    final users = await database.rawQuery('''SELECT * FROM $tableName WHERE id = ?''', [id]);
    return User.fromSqfliteDatabase(users.first);
  }

  Future<int> update({required int id, String? username, String? email, String? authMethod, String? pin, String? password}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (authMethod != null) 'auth_method': authMethod,
        if (pin != null) 'pin': pin,
        if (password != null) 'password': password,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ?''', [id]);
  }
}
