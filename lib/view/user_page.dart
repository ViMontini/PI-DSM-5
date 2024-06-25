import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';
import '../model/user.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:despesa_digital/utils/sizes.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = _loadUser();
  }

  Future<User> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      UserDB userDB = UserDB();
      return await userDB.fetchById(userId);
    } else {
      throw Exception("Usuário não encontrado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
              height: 150.h,
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 80.h,
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
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 350.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<User>(
              future: _futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar usuário'));
                } else if (snapshot.hasData) {
                  User user = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage('assets/images/user_avatar.png'), // Substitua pelo caminho da sua imagem de perfil
                              ),
                              SizedBox(height: 16),
                              Text(
                                user.username,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                user.email,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('Usuário não encontrado'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
