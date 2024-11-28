import 'package:bcrypt/bcrypt.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import '../database/user_db.dart';
import '../model/user.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../controller/auth_service.dart';
import 'authentication_page.dart';
import 'package:despesa_digital/utils/sizes.dart';

var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<User> _futureUser;
  final AuthService _authService = AuthService();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final UserDB _userDB = UserDB();

  @override
  void initState() {
    super.initState();
    _futureUser = _loadUser();
  }

  Future<User> _loadUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId != null) {
        User? user = await _userDB.fetchUserById(userId);
        if (user != null) {
          return user;
        } else {
          throw Exception("Usuário não encontrado no banco de dados.");
        }
      } else {
        throw Exception("ID de usuário não encontrado no SharedPreferences.");
      }
    } catch (e) {
      throw Exception("Erro ao carregar usuário: $e");
    }
  }

  Future<void> _changePassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        _showSnackbar("Usuário não encontrado. Faça login novamente.");
        return; // Termina o método se o user_id não estiver definido
      }

      // Verificar senha atual
      String currentPassword = _currentPasswordController.text;
      String? storedPasswordHash = await _userDB.getPassword(userId);

      if (storedPasswordHash == null ||
          !BCrypt.checkpw(currentPassword, storedPasswordHash)) {
        _showSnackbar("Senha atual incorreta.");
        return;
      }

      // Verificar se as novas senhas são iguais
      String newPassword = _newPasswordController.text;
      String confirmNewPassword = _confirmNewPasswordController.text;

      if (newPassword != confirmNewPassword) {
        _showSnackbar("A nova senha e a confirmação não são iguais.");
        return;
      }

      // Atualizar a senha no banco local
      String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await _userDB.updatePasswordById(userId, hashedNewPassword);

      // Verifica conexão com a internet antes de sincronizar
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // Sincronizar com o Firestore
        final databaseService = DatabaseService();
        final db = await databaseService.database;
        await databaseService.syncUsuarioToFirestore(db);

        _showSnackbar("Senha atualizada com sucesso.");
      } else {
        _showSnackbar("Senha atualizada localmente. Sincronização pendente sem internet.");
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    } catch (e) {
      _showSnackbar("Erro ao atualizar a senha: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  Future<void> _logout() async {
    await _authService.signOutGoogle();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthenticationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(500, 30),
                  bottomRight: Radius.elliptical(500, 30),
                ),
              ),
              height: 120.h,
            ),
          ),
          // Title
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 60.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 32.h),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perfil do Usuário',
                    style: AppTextStyles.mediumText.apply(
                        color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          // User Information Section
          Positioned(
            top: 170.h,
            left: 16,
            right: 16,
            child: FutureBuilder<User>(
              future: _futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar usuário.'));
                } else if (snapshot.hasData) {
                  User user = snapshot.data!;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePictureUrl != null
                            ? NetworkImage(user.profilePictureUrl!)
                            : AssetImage(
                            'assets/images/user_avatar.png') as ImageProvider,
                      ),
                      SizedBox(height: 16),
                      Text(user.username,
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight
                              .bold)),
                      SizedBox(height: 8),
                      Text(user.email, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),
                      // Two Buttons: "Deslogar" and "Sincronizar"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Exibe a modal de confirmação para Deslogar
                              bool? shouldLogout = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Deslogar'),
                                    content: Text('Você realmente deseja deslogar?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false), // Cancela
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true), // Confirma
                                        child: Text('Deslogar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Se o usuário confirmar, realiza o logout
                              if (shouldLogout == true) {
                                try {
                                  await _logout();
                                  // Mensagem de sucesso após logout
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Você foi deslogado com sucesso!')),
                                  );
                                } catch (e) {
                                  // Mensagem de erro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao deslogar: $e')),
                                  );
                                }
                              }
                            },
                            child: Text('Deslogar', style: TextStyle(color: Colors.purple)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          SizedBox(width: 16), // Espaço entre os botões
                          ElevatedButton(
                            onPressed: () async {
                              // Exibe a modal de confirmação
                              bool? shouldSync = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Sincronização'),
                                    content: Text('Você realmente deseja Sincronizar as informações?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false), // Cancela
                                        child: Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true), // Confirma
                                        child: Text('Sincronizar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Se o usuário confirmar, realiza a sincronização
                              if (shouldSync == true) {
                                final databaseService = DatabaseService();

                                // Verifica a conexão com a internet
                                final connectivityResult = await Connectivity().checkConnectivity();
                                if (connectivityResult == ConnectivityResult.none) {
                                  // Exibe mensagem de erro se não houver conexão
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sem conexão com a internet. Tente novamente mais tarde.')),
                                  );
                                  return; // Sai do método se não houver internet
                                }

                                // Exibe o indicador de carregamento
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // Impede fechar ao tocar fora
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                // Executa a sincronização
                                try {
                                  await databaseService.syncDataOnStart();
                                  // Exibe a mensagem de sucesso
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Sincronização concluída com sucesso!')),
                                  );
                                } catch (e) {
                                  // Exibe a mensagem de erro
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao sincronizar: $e')),
                                  );
                                } finally {
                                  Navigator.of(context).pop(); // Fecha o indicador de carregamento
                                }
                              }
                            },
                            child: Text('Sincronizar', style: TextStyle(color: Colors.purple)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.purple, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Divider with "Alterar Senha"
                      Row(
                        children: [
                          Expanded(child: Divider(
                              color: Colors.purple, thickness: 2)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Text(
                              'Alterar Senha',
                              style: TextStyle(
                                color: AppColors.purpledarkOne,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(
                              color: Colors.purple, thickness: 2)),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Change Password Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha Atual',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Nova Senha',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _confirmNewPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Nova Senha',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Aligned Button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Exibe a modal de confirmação para Alterar Senha
                            bool? shouldChangePassword = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Alteração'),
                                  content: Text('Você realmente deseja alterar a senha?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false), // Cancela
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true), // Confirma
                                      child: Text('Alterar'),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Se o usuário confirmar, realiza a alteração de senha
                            if (shouldChangePassword == true) {
                              try {
                                await _changePassword();
                                // Mensagem de sucesso após alterar a senha
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Senha alterada com sucesso!')),
                                );
                              } catch (e) {
                                // Mensagem de erro
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao alterar a senha: $e')),
                                );
                              }
                            }
                          },
                          child: Text('Alterar Senha', style: TextStyle(color: Colors.purple)),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.purple,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.purple, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('Usuário não encontrado.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}