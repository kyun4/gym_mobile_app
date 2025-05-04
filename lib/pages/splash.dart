import 'package:flutter/material.dart';
import 'package:fitup/pages/signInAs.dart';
import 'package:fitup/pages/privacyPolicy.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/adminModePin.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/pagesplash1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(0.7), // Black color with 50% opacity
            ),
          ),
          // Overlay content (text in this case)
          Container(
              margin: const EdgeInsets.only(bottom: 70),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(_createRouteAdminPin());
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          child: const Text("")),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                            alignment: Alignment.bottomLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                                "Join our fitness journey\nin a few clicks",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 25)))),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                            alignment: Alignment.bottomLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                                "Unlock your Fitness Potential, Book Your\nWay to Better Health!",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)))),
                    SizedBox(height: 65),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(_createRouteSignUp());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: MediaQuery.of(context).size.width - 85,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(199, 167, 10, 180)),
                          child: const Text("Create an account",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(_createRouteSignIn());
                        },
                        child: Center(
                            child: Container(
                                margin: const EdgeInsets.all(15),
                                child: const Text(
                                    "Have an account already? SIGN IN",
                                    style: TextStyle(color: Colors.white)))))
                  ],
                )
              ])),
        ],
      ),
    );
  }
}

Route _createRouteAdminPin() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const AdminModePin(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start the animation from the right
      const end = Offset.zero; // End at the current position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Route _createRouteSignIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SignInAs(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start the animation from the right
      const end = Offset.zero; // End at the current position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Route _createRouteSignUp() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const PrivacyPolicy(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Start the animation from the right
      const end = Offset.zero; // End at the current position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
