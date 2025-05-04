import 'package:flutter/material.dart';
import 'package:fitup/components/textFieldLocation.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingHome extends StatefulWidget {
  const UserBookingHome({super.key});

  @override
  State<UserBookingHome> createState() => _userBookingHomeState();
}

class _userBookingHomeState extends State<UserBookingHome> {
  TextEditingController locationAddress = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return UserMainMenu(
                      selectedInitIndex: 1, subSelectedInitIndex: 21);
                }));
              },
              child: Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: Text("Use This Location")),
            )
          ]),
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
            padding: const EdgeInsets.all(30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 35),
              Text("Welcome to Fit Up!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              Text("Is this your location?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              SizedBox(height: 25),
              Text(
                  "To skip this step from now on, allow location access for your FitUp serices",
                  style: TextStyle(fontSize: 12)),
              SizedBox(height: 30),
              Container(
                  child: Row(children: [
                Icon(Icons.location_pin,
                    color: Color.fromARGB(199, 118, 60, 180)),
                SizedBox(width: 5),
                TextFieldLocationCustom(
                  textController: locationAddress,
                  obscure_text: false,
                  hint_text_value: "Enter your address",
                ),
              ])),
            ])),
      )
    ]);
  }
}
