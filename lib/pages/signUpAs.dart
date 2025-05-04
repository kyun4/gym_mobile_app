import 'package:flutter/material.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fitup/pages/RegisterUser.dart';

class SignUpAs extends StatefulWidget {
  const SignUpAs({super.key});

  @override
  State<SignUpAs> createState() => _SignUpAsState();
}

class _SignUpAsState extends State<SignUpAs> {
  final textEmailController = TextEditingController();
  final textPasswordController = TextEditingController();

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Image.asset("assets/images/gymbg1.png", fit: BoxFit.cover)),
      Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
      Positioned.fill(
          child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 35, top: 50),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Splash();
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
                              color:
                                  const Color.fromARGB(199, 118, 10, 160)))))),
          SizedBox(height: 200),
          Center(
            child: Container(
                alignment: Alignment.center,
                child: const Text("Choose Account Type",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 22))),
          ),
          SizedBox(height: 15),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const RegisterUser(registerRole: "2");
                      }));
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(199, 118, 10, 160)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_gymnastics_sharp,
                                color: Colors.white, size: 40),
                            Container(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  Text("Sign Up As",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text("Gym Trainer",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))
                                ]))
                          ]),
                    )),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return RegisterUser(registerRole: "1");
                      }));
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(199, 118, 10, 160)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_2_rounded,
                                color: Colors.white, size: 40),
                            Container(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  Text("Sign Up As",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text("Gym Enthusiast",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))
                                ]))
                          ]),
                    ))
              ]),
        ],
      ))
    ]));
  }
}
