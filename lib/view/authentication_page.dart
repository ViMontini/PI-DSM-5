import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importando Google Sign-In
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'google_auth.dart';
import 'google_password.dart';
import 'registration_page.dart';
import 'about_page.dart'; // Importando a página AboutPage

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _logoTapCount = 0; // Contador de cliques na logo
  Timer? _tapResetTimer;

  Future<void> _loginWithGoogle() async {
    try {
      final UserCredential? userCredential = await _authService.signInWithGoogle(context);
      final user = userCredential?.user;

      if (user != null) {
        String email = user.email ?? 'Sem email';
        String username = user.displayName ?? 'Sem Nome';

        bool userExists = await _authService.userExists(email);

        if (!userExists) {
          await _authService.registerNewGoogleUser(
            email: email,
            username: username,
            googleId: user.uid,
            profilePictureUrl: user.photoURL,
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GoogleCreatePasswordPage(email: email, username: username),
            ),
          );
        } else {
          bool hasPassword = await _authService.hasPassword(email);

          if (!hasPassword) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GoogleCreatePasswordPage(email: email, username: username),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GoogleInsertPasswordPage(email: email, username: username, profilePictureUrl: user.photoURL),
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar login com Google: $e')),
      );
    }
  }

  void _onLogoTapped() {
    setState(() {
      _logoTapCount++;
    });

    if (_logoTapCount == 3) {
      _tapResetTimer?.cancel();
      _logoTapCount = 0;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AboutPage()),
      );
    } else {
      _tapResetTimer?.cancel();
      _tapResetTimer = Timer(Duration(seconds: 2), () {
        setState(() {
          _logoTapCount = 0;
        });
      });
    }
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120), // Cabeçalho maior
                Text(
                  'Autenticação',
                  style: AppTextStyles.mediumText.apply(color: AppColors.purpledarkOne),
                ),
                SizedBox(height: 40),
                // Campo de email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Campo de senha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 24),

                // Botão de login
                ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text;
                    String password = _passwordController.text;

                    bool success = await _authService.signInWithEmailAndPassword(email, password);

                    if (success) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MainNavigator()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha na autenticação. Verifique suas credenciais.')),
                      );
                    }
                  },
                  child: Text('Entrar'),
                ),
                SizedBox(height: 24),

                // Botão de login com Google
                SignInButton(
                  Buttons.Google,
                  text: "Logar com o Google",
                  onPressed: _loginWithGoogle,
                ),
                SizedBox(height: 16),

                // Mensagem
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Não tem uma conta? Faça o primeiro login utilizando o botão do Google acima',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _onLogoTapped,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Image.asset('assets/images/logo1.png', width: 200, height: 200),
            ),
          ),
        ],
      ),
    );
  }
}
