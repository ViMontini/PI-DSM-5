import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';

class PatternAuthWidget extends StatefulWidget {
  final Future<void> Function(int) onAuthenticated;

  const PatternAuthWidget({required this.onAuthenticated});

  @override
  _PatternAuthWidgetState createState() => _PatternAuthWidgetState();
}

class _PatternAuthWidgetState extends State<PatternAuthWidget> {
  // Implement your pattern authentication logic here
  Future<void> _authenticate() async {
    // Assuming pattern authentication is successful
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      await widget.onAuthenticated(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add your pattern input widget here
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _authenticate,
          child: Text('Entrar'),
        ),
      ],
    );
  }
}
