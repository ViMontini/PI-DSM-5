import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';
import '../model/user.dart';

class PasswordAuthWidget extends StatefulWidget {
  final Future<void> Function(int) onAuthenticated;

  const PasswordAuthWidget({required this.onAuthenticated});

  @override
  _PasswordAuthWidgetState createState() => _PasswordAuthWidgetState();
}

class _PasswordAuthWidgetState extends State<PasswordAuthWidget> {
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  Future<void> _authenticate() async {
    String password = _passwordController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      UserDB userDB = UserDB();
      User user = await userDB.fetchById(userId);
      if (user.password == password) {
        await widget.onAuthenticated(userId);
      } else {
        setState(() {
          _error = 'Senha incorreta';
        });
      }
    } else {
      setState(() {
        _error = 'Usuário não encontrado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Senha'),
          obscureText: true,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _authenticate,
          child: Text('Entrar'),
        ),
      ],
    );
  }
}
