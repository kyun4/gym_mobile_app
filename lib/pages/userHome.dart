import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _userHomeState();
}

class _userHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Container(
                child: SvgPicture.asset(
                    "assets/svg/user-profile-svgrepo-com.svg")),
            title: Column(children: [
              Text("Fit Up",
                  style: TextStyle(
                      color: const Color.fromARGB(199, 118, 10, 160),
                      fontWeight: FontWeight.w500)),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(199, 118, 10, 160)),
                  child: Row(children: [
                    Text("Go to Premium"),
                    Icon(Icons.workspace_premium)
                  ]))
            ])),
        body: SafeArea(child: Container()));
  }
}
