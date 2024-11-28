import 'package:bcrypt/bcrypt.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import '../database/database_service.dart';
import '../database/user_db.dart';
import 'authentication_page.dart';

var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

class GoogleCreatePasswordPage extends StatefulWidget {
  final String email; // Email obtido via Google Sign-In
  final String username; // Nome de usuário obtido via Google Sign-In

  GoogleCreatePasswordPage({required this.email, required this.username});

  @override
  _GoogleCreatePasswordPageState createState() => _GoogleCreatePasswordPageState();
}

class _GoogleCreatePasswordPageState extends State<GoogleCreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserDB _userDB = UserDB(); // Instância do banco de dados

  bool _isLoading = false; // Controle de estado de carregamento

  // Função que atualiza a senha do usuário Google no banco de dados
  Future<void> _createPassword() async {
    setState(() {
      _isLoading = true; // Ativa o estado de carregamento
    });

    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Verifica se a senha e a confirmação são iguais
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem.')),
      );
      setState(() {
        _isLoading = false; // Desativa o estado de carregamento
      });
      return;
    }

    try {
      // Gera o hash da senha usando bcrypt
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Atualiza o usuário com a senha gerada no banco de dados
      await _userDB.updatePassword(widget.email, hashedPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha criada com sucesso!')),
      );

      // Redireciona o usuário para a tela principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
      );

      if (connectivityResult != ConnectivityResult.none) {
        // Faz a sincronização se estiver online
        await databaseService.syncUserToFB();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar senha: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Desativa o estado de carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = widget.username.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Impede que o layout suba ao abrir o teclado
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 90), // Desce levemente os elementos
                    Text(
                      'Bem-vindo, $firstName!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Registre uma senha para seu Usuário',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    // Campo para criar a senha
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Crie sua senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    // Campo para confirmar a senha
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirme sua senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 32),
                    // Botão para criar a senha
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _createPassword,
                      child: Text('Criar Senha'),
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
