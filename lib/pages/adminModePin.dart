import 'package:flutter/material.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fitup/pages/login.dart';

import 'package:fitup/components/TextFieldNumberOnly.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminModePin extends StatefulWidget {
  const AdminModePin({super.key});

  State<AdminModePin> createState() => _adminModePinState();
}

class _adminModePinState extends State<AdminModePin> {
  TextEditingController textAdminPinController = new TextEditingController();
  String? labelError;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const Splash();
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160))))),
            centerTitle: true,
            title: Text("Login to Admin Mode", style: TextStyle(fontSize: 16))),
        body: SafeArea(
            child: Container(
                margin: const EdgeInsets.only(top: 75),
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  Text(
                      textAlign: TextAlign.center,
                      "You are entering the administration mode\nPlease enter Admin PIN to continue",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 22),
                  TextFieldNumberOnly(
                      hint_text_value: "Enter Admin PIN",
                      textController: textAdminPinController,
                      obscure_text: false,
                      iconPrefix: Icon(Icons.pin),
                      iconSuffix:
                          Icon(Icons.ac_unit, color: Colors.transparent)),
                  SizedBox(height: 5),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(labelError ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12))),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      if (textAdminPinController.text.toString().trim() ==
                          "888010") {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const Login(loginRole: "3");
                        }));
                      } else {
                        setState(() {
                          labelError = "Wrong PIN";
                        });
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(199, 118, 10, 160)),
                        child: GestureDetector(
                            onTap: () {},
                            child: const Text("Submit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)))),
                  )
                ]))));
  }
}
