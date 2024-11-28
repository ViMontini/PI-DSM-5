import 'package:flutter/material.dart';
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import 'authentication_page.dart';

class GoogleInsertPasswordPage extends StatefulWidget {
  final String email;
  final String username;
  final String? profilePictureUrl;

  GoogleInsertPasswordPage({
    required this.email,
    required this.username,
    this.profilePictureUrl,
  });

  @override
  _GoogleInsertPasswordPageState createState() => _GoogleInsertPasswordPageState();
}

class _GoogleInsertPasswordPageState extends State<GoogleInsertPasswordPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  int _attemptCount = 0;

  Future<void> _verifyPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    await Future.delayed(Duration(milliseconds: 1000));

    try {
      String password = _passwordController.text;
      bool isPasswordCorrect = await _authService.verifyPassword(widget.email, password);

      Navigator.of(context).pop();

      if (isPasswordCorrect) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavigator()),
        );
      } else {
        setState(() {
          _attemptCount++;
        });

        if (_attemptCount >= 3) {
          await _authService.signOutGoogle();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AuthenticationPage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Você excedeu o limite de tentativas. Faça login novamente.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Senha incorreta. Você tem ${3 - _attemptCount} tentativas restantes.')),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar senha: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = widget.username.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50),
                    Text(
                      'Olá, $firstName',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    if (widget.profilePictureUrl != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(widget.profilePictureUrl!),
                      ),
                    if (widget.profilePictureUrl == null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/user_avatar.png'),
                      ),
                    SizedBox(height: 32),
                    Text(
                      'Insira sua senha para logar no aplicativo',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _verifyPassword,
                      child: Text('Verificar Senha'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Logo fixa na parte inferior
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/images/logo1.png',
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
