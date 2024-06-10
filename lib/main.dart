import 'package:despesa_digital/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'controller/auth_controller.dart';
import 'view/auth_view.dart';
import 'view/home_page.dart';
import 'package:despesa_digital/utils/sizes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => Sizes.init(context));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage()
      /*
      FutureBuilder(
        future: _authController.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return HomePage(); // Usuário autenticado, vai para a HomePage
          } else {
            return AuthView(); // Usuário não autenticado, vai para a AuthView
          }
        },
      ), */
    );
  }
}
