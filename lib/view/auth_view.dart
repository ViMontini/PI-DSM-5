import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../model/user.dart';

class AuthView extends StatefulWidget {
  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _authController = AuthController();
  final _nameController = TextEditingController();
  String _credentialMethod = 'PIN'; // Default method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuração Inicial')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            DropdownButton<String>(
              value: _credentialMethod,
              items: <String>['PIN', 'Desenho de tela', 'Digital']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _credentialMethod = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _saveUser,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUser() {
    String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coloque seu nome')));
      return;
    }
    User user = User(name: name, credentialMethod: _credentialMethod);
    _authController.saveUser(user).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário salvo com sucesso')));
    });
  }
}