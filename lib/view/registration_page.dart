import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'authentication_page.dart';
import '../controller/auth_service.dart';

class RegistrationPage extends StatefulWidget {
  final String email; // Email do usuário Google
  final String username; // Nome do usuário Google

  RegistrationPage({required this.email, required this.username});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService(); // Serviço de autenticação

  // Função para registrar a senha adicional do usuário do Google
  void _registerPassword() async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('As senhas não coincidem')));
      return;
    }

    try {
      // Registrar a senha adicional no banco de dados local
      await _authService.registerPasswordForGoogleUser(widget.email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha registrada com sucesso!')),
      );

      // Navegar para a página de autenticação ou principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar senha: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que o layout seja redimensionado ao exibir o teclado
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.purpledarkOne,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Center(
              child: Text(
                'Criar Senha',
                style: AppTextStyles.mediumText.apply(color: AppColors.white),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView( // Permite a rolagem dos campos de texto
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Exibe o nome e o email do usuário Google (somente leitura)
                    Text('Usuário: ${widget.username}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text('Email: ${widget.email}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 32),

                    // Campo para criar a senha
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    // Campo para confirmar a senha
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: 'Confirmar Senha'),
                      obscureText: true,
                    ),
                    SizedBox(height: 32),

                    // Botão para registrar a senha
                    ElevatedButton(
                      onPressed: _registerPassword,
                      child: Text('Registrar Senha'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Logo fixada na parte inferior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo1.png', width: 150, height: 150),
          ),
        ],
      ),
    );
  }
}
