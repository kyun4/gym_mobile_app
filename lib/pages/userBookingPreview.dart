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
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:fitup/classes/UserGymClasses.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingPreview extends StatefulWidget {
  const UserBookingPreview({super.key});

  @override
  State<UserBookingPreview> createState() => _userBookingPreviewState();
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

void addReservation(String class_id, String exercise_id,
    String user_firebase_uid, String trainer_firebase_uid) async {
  var gymClassId_value = Uuid();
  String gymClassId = gymClassId_value.v4();

  var transactionId_value = Uuid();
  var transactionId = transactionId_value.v4();

  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  String url = dbUrl + "user_gym_classes/$gymClassId.json";
  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "user_gym_class_id": gymClassId,
          "gym_class_id": class_id,
          "user_id": user_firebase_uid,
          "trainer_id": trainer_firebase_uid,
          "transaction_id": transactionId,
          "status": "0",
          "payment_status": "0",
          "date_time_trainer_approved": "",
          "date_time_booked": date_time_formatted,
          "date_time_admin_approved": "",
          "approved_by_admin": ""
        }));
  } catch (error) {
    throw error;
  }
} // addReservation

class _userBookingPreviewState extends State<UserBookingPreview> {
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

      trainerFullname = trainerFirstname +
          " " +
          trainerMiddlename +
          " " +
          trainerLastname +
          " " +
          trainerExt;

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
    String? gymNameValue = await getSession("gym_name");
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
      gymName = gymNameValue;
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
                            selectedInitIndex: 1, subSelectedInitIndex: 29);
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
        Column(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              child: Stack(children: [
                Positioned.fill(
                  child: Image.network(classImageUrl ?? "", fit: BoxFit.cover,
                      errorBuilder: (context, error, StackTrace) {
                    return Container(
                        height: 350,
                        child: Center(
                            child: Text("Something went wrong, reload page")));
                  }, loadingBuilder: (context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Container(
                        height: 350,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: CircularProgressIndicator(
                                value: loadingProgress != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null)),
                      );
                    }
                  }),
                ),
                Positioned.fill(
                    top: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${trainerFullname}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("FIT UP Username:",
                                  style: TextStyle(color: Colors.white)),
                              Text(trainerName ?? "",
                                  style: TextStyle(color: Colors.white))
                            ]),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook_outlined,
                                  color: Colors.white),
                              Text(" arvigonzaga",
                                  style: TextStyle(color: Colors.white))
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.tiktok, color: Colors.white),
                              Text(" arvi.gonzaga",
                                  style: TextStyle(color: Colors.white))
                            ])
                      ],
                    ))
              ])),
          Container(
              padding: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(genre!.toUpperCase(),
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
                            style:
                                TextStyle(color: Colors.grey, fontSize: 18))),
                    Container(
                        child: Text(
                            "  Monday, Aug 22\n  1:45 with Arvi Gonzaga",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                    SizedBox(height: 30),
                  ])),
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(
                color: Colors.black26,
                height: 1,
                width: MediaQuery.of(context).size.width),
            SizedBox(height: 5),
            Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(left: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text("DISCOUNT CODE",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14))),
                      Row(children: [
                        Container(
                            child: Text("E.g. SDY874",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14))),
                        SizedBox(width: 15),
                        Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.5),
                                border: Border.all(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            child: Text("Enter",
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(199, 167, 10, 180))))
                      ])
                    ])),
            SizedBox(height: 10),
            Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      blurRadius: 25,
                      spreadRadius: 7,
                      color: Colors.grey.withOpacity(0.4),
                      offset: Offset(10, 10))
                ]),
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  SizedBox(height: 12),
                  Text("One more step until completion"),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      addReservation(classId ?? "", exerciseId ?? "",
                          firebaseUIDValue ?? "", trainerId ?? "");
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return UserMainMenu(
                            selectedInitIndex: 1, subSelectedInitIndex: 31);
                      }));
                    },
                    child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13.5),
                            color: Color.fromARGB(199, 167, 10, 180)),
                        child: Text("Next",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white))),
                  )
                ]))
          ])
        ])
      ]),
    ));
  }
}
