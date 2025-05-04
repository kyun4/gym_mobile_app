import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/adminMainMenu.dart';
import 'package:fitup/pages/splash.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _authGateState();
}

Future<String> scanUserDetails(accountUserId) async {
  String dataReturn = "";
  var url = "https://fitup-43ee3-default-rtdb.firebaseio.com/" + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((userId, userData) {
      if (userData['firebase_uid'] == accountUserId) {
        dataReturn = userData['role'].toString();
      }
    });
  } catch (error) {
    throw error;
  }

  return dataReturn;
}

class _authGateState extends State<AuthGate> {
  String? roleID;
  bool doneLoading = false;

  void initState() {
    super.initState();
    getUserRole();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        doneLoading = true;
      });
    });
  }

  Future<void> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? userId = user?.uid ?? "";
      String roleId = await scanUserDetails(userId);
      setState(() {
        roleID = roleId;
      });
    }
  }

  Widget build(BuildContext context) {
    return roleID == null
        ? doneLoading == true
            ? const Splash()
            : Scaffold(
                body: Center(
                    child: Container(child: CircularProgressIndicator())))
        : roleID == "2"
            ? const InstructorMainMenu(
                selectedInitIndex: 0, subSelectedInitIndex: 0)
            : roleID == "1"
                ? const UserMainMenu(
                    selectedInitIndex: 0, subSelectedInitIndex: 0)
                : const AdminMainMenu(
                    selectedInitIndex: 0, subSelectedInitIndex: 0);
  }
}
