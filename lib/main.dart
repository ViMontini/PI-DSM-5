import 'package:despesa_digital/utils/sizes.dart';
import 'package:despesa_digital/view/authentication_page.dart';
import 'package:despesa_digital/view/registration_page.dart';
import 'package:despesa_digital/view/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/user_db.dart';
import 'model/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');
    if (isFirstTime == null || isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      return true;
    }
    return false;
  }

  Future<bool> _isUserRegistered() async {
    UserDB userDB = UserDB();
    List<User> users = await userDB.fetchAll();
    return users.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: Future.wait([_isFirstTime(), _isUserRegistered()]),
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
            locale: Locale('pt', 'BR'), // Define o local padrão para português do Brasil
            supportedLocales: [
              const Locale('pt', 'BR'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: isFirstTime
                ? RegistrationPage()
                : isUserRegistered
                ? AuthenticationPage()
                : RegistrationPage(),
            routes: {
              '/auth': (context) => AuthenticationPage(),
              '/home': (context) => SplashPage(),
            },
          );
        }
      },
    );
  }
}

