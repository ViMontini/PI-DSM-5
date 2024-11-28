import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:despesa_digital/view/authentication_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/categorizer.dart';
import 'database/database_service.dart';
import 'database/user_db.dart';
import 'model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa o DatabaseService
  DatabaseService databaseService = DatabaseService();

  // Verificação de conectividade e sincronização
  try {
    // Verifica a conectividade
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // Tenta sincronizar dados, mas captura possíveis erros
      try {
        await Categorizer.recategorizarDesconhecidos();
        await databaseService.syncDataOnStart();
      } catch (e) {
        print('Erro ao sincronizar dados: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização será realizada depois.');
    }
  } catch (e) {
    print('Erro ao verificar conectividade: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<int?> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTimeUser') ?? true;
  }

  Future<bool> _isUserRegistered(int userId) async {
    UserDB userDB = UserDB();
    User? user = await userDB.fetchUserById(userId);
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _isFirstTime(),
        _loadUserId().then((userId) => _isUserRegistered(userId ?? 0)),
      ]),
      builder: (context, AsyncSnapshot<List<bool>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          bool isFirstTime = snapshot.data![0];
          bool isUserRegistered = snapshot.data![1];
          WidgetsBinding.instance.addPostFrameCallback((_) => Sizes.init(context));
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Minha App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            locale: Locale('pt', 'BR'),
            supportedLocales: [const Locale('pt', 'BR')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AuthenticationPage(),
          );
        }
      },
    );
  }
}
