import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart'; // Pacote para ícones sociais

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Google,
      text: "Logar com o Google",
      onPressed: onPressed,
    );
  }
}
