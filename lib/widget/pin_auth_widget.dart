import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';
import '../model/user.dart';

class PinAuthWidget extends StatefulWidget {
  final Future<void> Function(int) onAuthenticated;

  const PinAuthWidget({required this.onAuthenticated});

  @override
  _PinAuthWidgetState createState() => _PinAuthWidgetState();
}

class _PinAuthWidgetState extends State<PinAuthWidget> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  Future<void> _authenticate() async {
    String pin = _pinController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      UserDB userDB = UserDB();
      User user = await userDB.fetchById(userId);
      if (user.pin == pin) {
        await widget.onAuthenticated(userId);
      } else {
        setState(() {
          _error = 'PIN incorreto';
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
          controller: _pinController,
          decoration: InputDecoration(labelText: 'PIN'),
          obscureText: true,
          keyboardType: TextInputType.number,
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
