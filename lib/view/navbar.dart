import 'package:flutter/material.dart';
import 'package:despesa_digital/controller/utils.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;

  CustomNavbar({required this.scaffoldKey, required this.title});

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: Text(title, style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
