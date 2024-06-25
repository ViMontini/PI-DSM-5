import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/user_db.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

enum AuthMethod { senha, desenho, digital, pin }

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  AuthMethod? _selectedMethod;

  void _registerUser() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String authMethod = _selectedMethod.toString().split('.').last;
    String? password;
    String? pin;

    if (_selectedMethod == AuthMethod.senha) {
      password = _passwordController.text;
      if (password != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('As senhas não coincidem')));
        return;
      }
    } else if (_selectedMethod == AuthMethod.pin) {
      pin = _pinController.text;
      if (pin != _confirmPinController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Os PINs não coincidem')));
        return;
      }
    }

    UserDB userDB = UserDB();
    int userId = await userDB.create(username: username, email: email, authMethod: authMethod, pin: pin, password: password);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('auth_method', authMethod);
    await prefs.setBool('isFirstTimeUser', false);

    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.purpledarkOne,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Center(
              child: Text(
                'Registro',
                style: AppTextStyles.mediumText.apply(color: AppColors.white),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Usuário'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    DropdownButtonFormField<AuthMethod>(
                      value: _selectedMethod,
                      onChanged: (AuthMethod? newValue) {
                        setState(() {
                          _selectedMethod = newValue;
                        });
                      },
                      items: AuthMethod.values.map((AuthMethod method) {
                        return DropdownMenuItem<AuthMethod>(
                          value: method,
                          child: Text(method.toString().split('.').last),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Método de Autenticação'),
                    ),
                    if (_selectedMethod == AuthMethod.senha) ...[
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                      ),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(labelText: 'Confirmar Senha'),
                        obscureText: true,
                      ),
                    ],
                    if (_selectedMethod == AuthMethod.pin) ...[
                      TextField(
                        controller: _pinController,
                        decoration: InputDecoration(labelText: 'PIN'),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _confirmPinController,
                        decoration: InputDecoration(labelText: 'Confirmar PIN'),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registerUser,
                      child: Text('Registrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo1.png', width: 150, height: 150),
          ),
        ],
      ),
    );
  }
}
