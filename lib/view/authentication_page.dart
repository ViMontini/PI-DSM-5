import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widget/fingerprint_auth_widget.dart';
import '../widget/password_auth_widget.dart';
import '../widget/pattern_auth_widget.dart';
import '../widget/pin_auth_widget.dart';

enum AuthMethod { password, pattern, fingerprint, pin }

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  AuthMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _loadSelectedMethod();
  }

  Future<void> _loadSelectedMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? method = prefs.getString('auth_method');
    setState(() {
      _selectedMethod = AuthMethod.values.firstWhere(
            (e) => e.toString() == method,
        orElse: () => AuthMethod.password,
      );
    });
  }

  Future<void> _onAuthenticated(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMethod == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.purpledarkOne,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 60.0),
            child: Center(
              child: Text(
                'Autenticação',
                style: AppTextStyles.mediumText.apply(color: AppColors.white),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildAuthWidget(),
                  Spacer(),
                  Image.asset('assets/images/logo1.png', width: 150, height: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthWidget() {
    switch (_selectedMethod) {
      case AuthMethod.password:
        return PasswordAuthWidget(onAuthenticated: _onAuthenticated);
      case AuthMethod.pattern:
        return PatternAuthWidget(onAuthenticated: _onAuthenticated);
      case AuthMethod.fingerprint:
        return FingerprintAuthWidget(onAuthenticated: _onAuthenticated);
      case AuthMethod.pin:
        return PinAuthWidget(onAuthenticated: _onAuthenticated);
      default:
        return Container();
    }
  }
}
