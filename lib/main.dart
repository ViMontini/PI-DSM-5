import 'package:flutter/material.dart';
import 'view/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Certifique-se de que os plugins do Flutter estão inicializados
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
