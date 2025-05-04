import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UserChooseTraining extends StatefulWidget {
  const UserChooseTraining({super.key});

  @override
  State<UserChooseTraining> createState() => _UserChooseTrainingState();
}

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} //

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

class _UserChooseTrainingState extends State<UserChooseTraining> {
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
                      return const UserMainMenu(
                          selectedInitIndex: 1, subSelectedInitIndex: 0);
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
          Container(
              margin: const EdgeInsets.only(left: 50),
              alignment: Alignment.centerLeft,
              child: const Text("Choose your Training\nPreference",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 22))),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setSession("training_venue", "Onsite");
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const UserMainMenu(
                            selectedInitIndex: 1, subSelectedInitIndex: 22);
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
                            Icon(Icons.home, color: Colors.white, size: 40),
                            Container(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  SizedBox(height: 10),
                                  Text("Onsite",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ]))
                          ]),
                    )),
                GestureDetector(
                    onTap: () {
                      setSession("training_venue", "Offsite");
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const UserMainMenu(
                            selectedInitIndex: 1, subSelectedInitIndex: 22);
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
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.computer,
                                      color: Colors.white, size: 40),
                                  Icon(Icons.mobile_friendly,
                                      color: Colors.white, size: 40),
                                ]),
                            Container(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  SizedBox(height: 10),
                                  Text("Offsite",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  // Text("Gym Enthusiast",
                                  //     style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.bold))
                                ]))
                          ]),
                    ))
              ]),
        ],
      ))
    ]));
  }
}
