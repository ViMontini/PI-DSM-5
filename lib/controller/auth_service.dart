import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;  // Prefixando o Firebase User
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bcrypt/bcrypt.dart'; // Para hashear/verificar senhas
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import '../database/user_db.dart';
import '../model/user.dart' as local_user; // Prefixando o modelo User local

var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserDB _userDB = UserDB();

  // Pegar o usuário atual autenticado no Firebase
  firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Login com email e senha do Firebase
  Future<firebase_auth.UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(getErrorMessage(e.code));
    }
  }

  // Criar usuário com email e senha no Firebase
  Future<firebase_auth.UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(getErrorMessage(e.code));
    }
  }

  // Método para deslogar da conta Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut(); // Deslogar do Google
    await _firebaseAuth.signOut(); // Deslogar do Firebase
  }


  // Login com Google e sincronização de informações
  Future<firebase_auth.UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Verificar conexão com a Internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("Falha ao se conectar na Internet. Verifique sua conexão.");
      }

      // Iniciar o processo de login com Google
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      if (gUser == null) {
        throw Exception("Login com o Google foi cancelado.");
      }

      // Obter detalhes da requisição de autenticação
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Criar credenciais do Google para login
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Fazer login com Google no Firebase
      final firebase_auth.UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      final String email = gUser.email;
      final String username = gUser.displayName ?? 'Sem Nome';
      final String googleId = gUser.id;
      final String? profilePictureUrl = gUser.photoUrl;

      // Verificar se o usuário já existe no banco local pelo Google ID ou e-mail
      local_user.User? existingUser = await _userDB.fetchUserByGoogleId(googleId);

      if (existingUser == null) {
        existingUser = await _userDB.fetchUserByEmail(email);
      }

      int userId;

      if (existingUser != null) {
        userId = existingUser.id;
        await _userDB.updateUser(
          id: userId,
          username: username,
          email: email,
          profilePictureUrl: profilePictureUrl,
        );
      } else {
        userId = await _userDB.create(
          username: username,
          email: email,
          authMethod: 'google',
          password: null,
          googleId: googleId,
          profilePictureUrl: profilePictureUrl,
        );
      }

      await saveUserIdToSharedPreferences(userId);
      return userCredential;
    } on PlatformException catch (e) {
      // Tratamento específico para erro de plataforma (ex.: network_error)
      if (e.code == 'network_error') {
        showErrorMessage(context, "Não foi possível realizar o login. Verifique sua conexão com a internet.");
      } else {
        showErrorMessage(context, "Ocorreu um erro ao tentar realizar o login: ${e.message}");
      }
      return null;
    } catch (e) {
      // Tratamento genérico de erros
      showErrorMessage(context, "Erro: ${e.toString()}");
      return null;
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  // Registrar novo usuário do Google no banco de dados local
  Future<void> registerNewGoogleUser({
    required String email,
    required String username,
    required String googleId,
    String? profilePictureUrl,
  }) async {
    try {
      // Registro inicial do usuário no banco de dados, com senha como NULL
      int userId = await _userDB.create(
        username: username,
        email: email,
        authMethod: 'google',
        password: null, // Sem senha inicialmente (será criada depois)
        googleId: googleId,
        profilePictureUrl: profilePictureUrl,
      );
      await saveUserIdToSharedPreferences(userId);
    } catch (e) {
      throw Exception('Erro ao registrar o usuário no banco de dados: $e');
    }

  }


  // Solicitar senha adicional e verificar
  Future<bool> _promptForPasswordAndVerify(local_user.User user) async {
    // Exibir uma interface para que o usuário insira a senha adicional
    String inputPassword = await _showPasswordInputDialog();

    // Verificar se a senha inserida corresponde ao hash armazenado
    return BCrypt.checkpw(inputPassword, user.password!);
  }

  // Exibir caixa de diálogo para o usuário inserir a senha
  Future<String> _showPasswordInputDialog() async {
    // Implementação da interface de entrada de senha (caixa de diálogo)
    // Retornar a senha inserida pelo usuário
    // Para este exemplo, é um placeholder:
    return Future.value("senha_inserida");
  }

  // Solicitar ao usuário para criar uma nova senha
  Future<String> _promptForNewPassword() async {
    // Exibir interface para o usuário criar uma nova senha
    // Para este exemplo, é um placeholder:
    return Future.value("nova_senha");
  }

  // Verifica se o usuário já tem uma senha configurada
  Future<bool> hasPassword(String email) async {
    final user = await _userDB.fetchUserByEmail(email);

    if (user != null) {
      // Log para verificar o que está acontecendo
      print('Usuário encontrado: ${user.username}, senha: ${user.password}');

      // Verifica se a senha está presente e não está vazia
      if (user.password != null && user.password!.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // Verifica se o usuário já existe no banco de dados pelo email
  Future<bool> userExists(String email) async {
    final user = await _userDB.fetchUserByEmail(email);
    return user != null; // Retorna true se o usuário existir
  }

  // Verifica se a senha fornecida está correta para o email dado
  Future<bool> verifyPassword(String email, String inputPassword) async {
    final user = await _userDB.fetchUserByEmail(email);

    if (user != null && user.password != null) {
      // Verifica se a senha inserida corresponde ao hash armazenado no banco de dados
      return BCrypt.checkpw(inputPassword, user.password!);
    }
    return false;
  }

  // Função para registrar a senha adicional para um usuário Google
  Future<void> registerPasswordForGoogleUser(String email, String password) async {
    try {
      // Hash da senha
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Atualizar o usuário no banco de dados local com a nova senha
      await _userDB.updatePassword(email, hashedPassword);

    } catch (e) {
      throw Exception("Erro ao registrar senha: $e");
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Buscar o usuário pelo email no banco de dados local
      final user = await _userDB.fetchUserByEmail(email);

      if (user == null) {
        throw Exception("Usuário não encontrado.");
      }

      // Verificar se a senha fornecida é igual à senha armazenada (com bcrypt)
      bool isPasswordCorrect = BCrypt.checkpw(password, user.password!);

      if (!isPasswordCorrect) {
        throw Exception("Senha incorreta.");
      }

      // Retorna verdadeiro se a senha estiver correta
      return true;
    } catch (e) {
      print("Erro na autenticação com email e senha: $e");
      return false;
    }
  }

  Future<void> saveUserIdToSharedPreferences(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  // Mensagens de erro
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
        return 'Senha incorreta. Por favor, tente novamente.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com esse email.';
      case 'invalid-email':
        return 'Este email não é válido.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    }
  }
}
