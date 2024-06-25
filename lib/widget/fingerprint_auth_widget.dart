import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';

class FingerprintAuthWidget extends StatefulWidget {
  final Future<void> Function(int) onAuthenticated;

  const FingerprintAuthWidget({required this.onAuthenticated});

  @override
  _FingerprintAuthWidgetState createState() => _FingerprintAuthWidgetState();
}

class _FingerprintAuthWidgetState extends State<FingerprintAuthWidget> {
  // Implement your fingerprint authentication logic here
  Future<void> _authenticate() async {
    // Assuming fingerprint authentication is successful
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
        // Add your fingerprint input widget here
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _authenticate,
          child: Text('Entrar'),
        ),
      ],
    );
  }
}
