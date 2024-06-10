import 'dart:async';
import 'package:despesa_digital/view/home_page.dart';
import 'package:despesa_digital/view/home_page_view.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    init();
  }

  Timer init(){
    return Timer(
        Duration(seconds: 2),
        navigateToHome);
  }

  void navigateToHome() {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => const HomePageView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6a02b0),
              Color(0xFF55008f),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Despesa Digital',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFffffff),
                ),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
