import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:fitup/classes/UserGymClasses.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingSummary extends StatefulWidget {
  const UserBookingSummary({super.key});

  @override
  State<UserBookingSummary> createState() => _userBookingSummaryState();
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

String convertMilitaryToAMPM(String time24) {
  final dateTime = DateFormat("HH:mm").parse(time24);
  final formattedTime = DateFormat("h:mm a").format(dateTime);
  return formattedTime;
} // convertMilitaryTimeToAMPM

class _userBookingSummaryState extends State<UserBookingSummary> {
  String? trainerName;
  String? trainerId;
  List<Users> userList = [];
  String? clientUsername;
  String? clientFullname;
  String? trainerUsername;
  String? trainerFullname;
  String? firebaseUIDValue;
  String? profileImageUrl;
  String? sessionSetup;
  String? classImageUrl;
  String? classId;
  String? class_name;
  String? gymName;
  String? class_description;
  String? class_rating;
  String? exerciseId;
  String? bestFor;
  String? classLevel;
  String? genre;
  String? gymClassStartDate;
  String? gymClassStartTime;

  void getAllUsers() async {
    List<Users> listAllUsers =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getUsersJson();

    setState(() {
      userList = listAllUsers;

      clientUsername = userList
          .where((clientData) => clientData.firebase_uid == firebaseUIDValue)
          .toList()[0]
          .username;

      String firstname = userList
          .where((clientData) => clientData.firebase_uid == firebaseUIDValue)
          .toList()[0]
          .firstname;

      String middlename = userList
          .where((clientData) => clientData.firebase_uid == firebaseUIDValue)
          .toList()[0]
          .middlename;

      String lastname = userList
          .where((clientData) => clientData.firebase_uid == firebaseUIDValue)
          .toList()[0]
          .lastname;

      String ext = userList
          .where((clientData) => clientData.firebase_uid == firebaseUIDValue)
          .toList()[0]
          .ext;

      String trainerFirstname = userList
          .where((clientData) => clientData.firebase_uid == trainerId)
          .toList()[0]
          .firstname;

      String trainerMiddlename = userList
          .where((clientData) => clientData.firebase_uid == trainerId)
          .toList()[0]
          .middlename;

      String trainerLastname = userList
          .where((clientData) => clientData.firebase_uid == trainerId)
          .toList()[0]
          .lastname;

      String trainerExt = userList
          .where((clientData) => clientData.firebase_uid == trainerId)
          .toList()[0]
          .ext;

      trainerFullname =
          trainerFirstname + "\n" + trainerLastname + " " + trainerExt;

      clientFullname =
          firstname + ' ' + middlename + ' ' + lastname + ' ' + ext;
    });
  } // getAllUsers()

  void initState() {
    super.initState();

    getPreferencesValues();
    firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    getAllUsers();
  }

  void getPreferencesValues() async {
    String? imageUrl = await getSession("class_image_url");
    String? setupSession = await getSession("training_venue");
    String? trainerFirebaseUid = await getSession("trainerFirebaseUid");
    String? exerciseIDValue = await getSession("exerciseId");
    String? classIdValue = await getSession("class_id");
    String? className = await getSession("class_name");
    String? classDescription = await getSession("class_description");
    String? classRating = await getSession("class_rating");
    String? bestForValue = await getSession("best_for");
    String? levelValue = await getSession("level");
    String? genreValue = await getSession("genre");
    String? gymNameValue = await getSession("gym_name");
    String? gymClassStartDateValue = await getSession("gym_class_start_date");
    String? gymClassStartTimeValue = await getSession("gym_class_start_time");

    setState(() {
      classImageUrl = imageUrl;
      sessionSetup = setupSession;
      trainerId = trainerFirebaseUid;
      exerciseId = exerciseIDValue;
      class_name = className;
      class_description = classDescription;
      class_rating = classRating;
      genre = genreValue;
      bestFor = bestForValue;
      classLevel = levelValue;
      classId = classIdValue;
      gymName = gymNameValue;
      gymClassStartDate = gymClassStartDateValue;
      gymClassStartTime = gymClassStartTimeValue;
    });
  } // getPreferencesValues

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ListView(children: [
        SizedBox(height: 25),
        Container(
            padding: const EdgeInsets.only(bottom: 10, left: 30, right: 30),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const UserMainMenu(
                            selectedInitIndex: 1, subSelectedInitIndex: 30);
                      }));
                    },
                    child: Container(
                        margin: const EdgeInsets.all(5),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color.fromARGB(199, 116, 10, 180)),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 22),
                        )),
                  ),
                  Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color.fromARGB(199, 116, 10, 180)),
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(Icons.share, color: Colors.white, size: 22),
                      ))
                ])),
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                margin: const EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width - 25,
                child: Text("THANK YOU FOR BOOKING WITH - ")),
            SizedBox(height: 5),
            Container(
                margin: const EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width - 25,
                child: Text(trainerFullname ?? "",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)))
          ]),
          SizedBox(height: 3.5),
          Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        color: Colors.black26,
                        height: 1,
                        width: MediaQuery.of(context).size.width),
                    SizedBox(height: 15),
                    Row(children: [
                      Text("  Here are your booking info",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87)),
                      SizedBox(width: MediaQuery.of(context).size.width - 250)
                    ]),
                    SizedBox(height: 35),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(genre!.trim().toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                    Text(" $class_name" ?? "",
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                  ]),
                              SizedBox(height: 20),
                              Container(
                                  child: Text(" Anytime Fitness",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 18))),
                              Container(
                                  child: Text(
                                      " Monday, Aug 22\n 1:45 with Arvi Gonzaga",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(height: 30),
                            ])),
                  ])),
          SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return UserMainMenu(
                    selectedInitIndex: 1, subSelectedInitIndex: 32);
              }));
            },
            child: Container(
                height: 55,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.5),
                    color: Color.fromARGB(199, 167, 10, 180)),
                child: Text("Done",
                    style: TextStyle(fontSize: 16, color: Colors.white))),
          )
        ])
      ]),
    ));
  }
}
