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
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:fitup/classes/UserGymClasses.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingSuccessful extends StatefulWidget {
  const UserBookingSuccessful({super.key});

  @override
  State<UserBookingSuccessful> createState() => _userBookingSuccessfulState();
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

class _userBookingSuccessfulState extends State<UserBookingSuccessful> {
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
  String? class_description;
  String? class_rating;
  String? exerciseId;
  String? bestFor;
  String? classLevel;
  String? genre;
  String? gymClassStartDate;
  String? gymClassStartTime;
  var formatter = DateFormat("MMM dd, yyyy");

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
          trainerFirstname + " " + trainerLastname + " " + trainerExt;

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
      gymClassStartDate = gymClassStartDateValue;
      gymClassStartTime = gymClassStartTimeValue;
    });
  } // getPreferencesValues

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        SizedBox(height: 55),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return UserMainMenu(
                  selectedInitIndex: 0, subSelectedInitIndex: 0);
            }));
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.withOpacity(0.2)),
                    child: Icon(Icons.close, size: 14))
              ])),
        ),
        SizedBox(height: 25),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return UserMainMenu(
                  selectedInitIndex: 0, subSelectedInitIndex: 0);
            }));
          },
          child: Container(
              width: 85,
              height: 85,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(85), color: Colors.green),
              child: Icon(Icons.check, color: Colors.white, size: 55)),
        ),
        SizedBox(height: 25),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                child: Text("Booking Successful!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Colors.green))),
          ]),
          SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin:
                const EdgeInsets.only(left: 35, right: 35, bottom: 15, top: 15),
            child: Center(
              child:
                  Text.rich(TextSpan(style: TextStyle(fontSize: 14), children: [
                TextSpan(text: 'Dear'),
                TextSpan(
                    text: ' $clientFullname ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'you have successfully\n'),
                TextSpan(text: 'scheduled booking '),
                TextSpan(
                    text: '$trainerFullname',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' for\n'),
                TextSpan(text: 'the upcoming date '),
                TextSpan(
                    text: formatter
                        .format(DateTime.parse(gymClassStartDate ?? "")),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' at '),
                TextSpan(
                    text: gymClassStartTime ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'Our service provider will contact you soon.'),
              ])),
            ),
          ),
          SizedBox(height: 50),
          GestureDetector(
            onTap: () {
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: (context) {
              //   return UserMainMenu(
              //       selectedInitIndex: 1, subSelectedInitIndex: 28);
              // }));
            },
            child: Container(
                height: 55,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.5),
                    color: Color.fromARGB(199, 167, 10, 180)),
                child: Text("Explore More",
                    style: TextStyle(fontSize: 16, color: Colors.white))),
          )
        ])
      ]),
    ));
  }
}
