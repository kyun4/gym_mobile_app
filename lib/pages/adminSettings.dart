import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/adminMainMenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/pages/splash.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _adminSettingsState();
}

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} // setSession

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

class _adminSettingsState extends State<AdminSettings> {
  String? roleId;
  String? firebaseUIDValue;

  Future<String> getUserRole(String firebaseUID) async {
    String roleId = "";

    var url = dbUrl + "users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (response.body == null || response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((userId, userData) {
        if (firebaseUID == userData['firebase_uid']) {
          roleId = userData['role'];
        }
      });
    } catch (error) {
      throw error;
    }

    return roleId;
  } // getUserRole

  void initState() {
    super.initState();
    firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      removeSession("training_venue");
      removeSession("exerciseNameSelected");
      removeSession("coachName");
      removeSession("selectedtartTime");
      removeSession("selectedEndTime");
      removeSession("role");
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const Splash();
      }));
    }

    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () async {
                  roleId = await getUserRole(firebaseUIDValue!);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return roleId == "1"
                        ? UserMainMenu(
                            selectedInitIndex: 4, subSelectedInitIndex: 0)
                        : roleId == "2"
                            ? InstructorMainMenu(
                                selectedInitIndex: 4, subSelectedInitIndex: 0)
                            : AdminMainMenu(
                                selectedInitIndex: 0, subSelectedInitIndex: 0);
                    ;
                  }));
                }),
            title: const Text("Settings"),
            centerTitle: true),
        body: ListView(children: <Widget>[
          Column(
            children: [
              Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        margin: const EdgeInsets.only(
                            top: 20, right: 20, left: 20, bottom: 10),
                        child: const Text("Account",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        height: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.1)),
                        child: Column(children: [
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Security",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.notifications_none_outlined,
                                      size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Notification",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.lock_outlined, size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Privacy",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                        ])),
                  ])),
              Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        margin: const EdgeInsets.only(
                            top: 20, right: 20, left: 20, bottom: 10),
                        child: const Text("Utilization",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        height: 165,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.1)),
                        child: Column(children: [
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                      "assets/svg/gym-svgrepo-com.svg",
                                      height: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Gym Names",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.sports_gymnastics, size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Gym Exercises",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Terms and Policies",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                        ])),
                  ])),
              Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        margin: const EdgeInsets.only(
                            top: 20, right: 20, left: 20, bottom: 10),
                        child: const Text("Actions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        height: 110,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.1)),
                        child: Column(children: [
                          Container(
                            margin: const EdgeInsets.all(7),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.report_outlined, size: 30),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          15),
                                  Text("Report a problem",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300)),
                                ]),
                          ),
                          GestureDetector(
                            onTap: () {
                              signOut();
                            },
                            child: Container(
                              margin: const EdgeInsets.all(7),
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.logout_outlined, size: 30),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                15),
                                    Text("Logout",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300)),
                                  ]),
                            ),
                          ),
                        ])),
                  ])),
            ],
          ),
        ]));
  }
}
