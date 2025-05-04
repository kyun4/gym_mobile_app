import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
import 'package:fitup/classes/GymExercises.dart';
import 'package:fitup/classes/UserGymClasses.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserClassView extends StatefulWidget {
  const UserClassView({super.key});

  @override
  State<UserClassView> createState() => _userClassViewState();
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

Future<List<GymExercises>> getExercises() async {
  final List<GymExercises> gymExercises = [];
  String url =
      "https://fitup-43ee3-default-rtdb.firebaseio.com/" + "exercises.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((gymClassesId, json) {
      gymExercises.add(GymExercises(
          exercise_id: json['exercise_id'] ?? "",
          details: json['details'] ?? "",
          exercise_name: json['exercise_name'] ?? "",
          icon: json['icon'] ?? "",
          improve: json['improve'] ?? "",
          status: json['status'] ?? "",
          date_time_added: json['date_time_added'] ?? "",
          added_by: json['added_by'] ?? "",
          date_time_last_updated: json['date_time_last_updated'] ?? "",
          last_updated_by: json['last_updated_by'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return gymExercises;
} // getExercises

Future<List<UserGymClasses>> getGymUserClasses() async {
  final List<UserGymClasses> listData = [];
  String url = "https://fitup-43ee3-default-rtdb.firebaseio.com/" +
      "user_gym_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((gymClassesId, json) {
      listData.add(UserGymClasses(
          user_gym_class_id: json['user_gym_class_id'] ?? "",
          gym_class_id: json['gym_class_id'] ?? "",
          user_id: json['user_id'] ?? "",
          trainer_id: json['trainer_id'] ?? "",
          transaction_id: json['transaction_id'] ?? "",
          status: json['status'] ?? "",
          payment_status: json['payment_status'] ?? "",
          date_time_trainer_approved: json['date_time_trainer_approved'] ?? "",
          date_time_booked: json['date_time_booked'] ?? "",
          date_time_admin_approved: json['date_time_admin_approved'] ?? "",
          approved_by_admin: json['approved_by_admin'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listData;
} // getGymUserClasses

Future<List<GymTrainerClasses>> getTrainerClasses() async {
  final List<GymTrainerClasses> gymTrainerClasses = [];
  String url = "https://fitup-43ee3-default-rtdb.firebaseio.com/" +
      "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((gymClassesId, data) {
      if (data['status'] == "1") {
        gymTrainerClasses.add(GymTrainerClasses(
            gym_trainer_class_id: data['gym_trainer_class_id'] ?? "",
            training_category_id: data['training_category_id'] ?? "",
            class_name: data['class_name'] ?? "",
            class_description: data['class_description'] ?? "",
            price_per_day: data['price_per_day'],
            cover_photo_url: data['cover_photo_url'],
            best_for: data['best_for'] ?? "",
            exercise_id: data['exercise_id'] ?? "",
            date_start: data['date_start'] ?? "",
            date_end: data['date_end'] ?? "",
            duration_in_mins: data['duration_in_mins'] ?? "",
            firebase_uid: data['firebase_uid'] ?? "",
            date_time_added: data['date_time_added'] ?? "",
            date_time_last_updated: data['date_time_last_updated'] ?? "",
            is_active: data['is_active'] ?? "",
            is_done: data['is_done'] ?? "",
            level: data['level'] ?? "",
            schedule_times: data['schedule_times'] ?? "",
            scheduled_days: data['scheduled_days'] ?? "",
            session_setup: data['session_setup'] ?? "",
            users_per_class_limit: data['users_per_class_limit'] ?? "",
            status: data['status'] ?? ""));
      }
    });
  } catch (error) {
    throw error;
  }

  return gymTrainerClasses;
} // getTrainerClasses

class _userClassViewState extends State<UserClassView> {
  String? trainerName;
  String? trainerId;
  List<Users> userList = [];
  List<UserGymClasses> userGymClassesList = [];
  List<GymExercises> exercisesList = [];
  String? clientUsername;
  String? clientFullname;
  String? numberOfUsersTaken;
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

    firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    getAllUsers();
    getAllUserGymClasses();
    getPreferencesValues();
  }

  void getAllUserGymClasses() async {
    List<UserGymClasses> listGymUserData = await getGymUserClasses();
    setState(() {
      userGymClassesList = listGymUserData;
    });
  } // getAllUserGymClasses

  void getPreferencesValues() async {
    List<GymExercises> listExercises = await getExercises();
    setState(() {
      exercisesList = listExercises;
    });

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

    String? genreValue = exercisesList
                .where((exerciseData) =>
                    exerciseData.exercise_id == exerciseIDValue)
                .toList()
                .length >
            0
        ? exercisesList
            .where(
                (exerciseData) => exerciseData.exercise_id == exerciseIDValue)
            .toList()[0]
            .exercise_name
        : "";

    String numberOfClassTaken = userGymClassesList
        .where(
            (userGymClassData) => userGymClassData.gym_class_id == classIdValue)
        .toList()
        .length
        .toString();

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
      numberOfUsersTaken = numberOfClassTaken;
    });

    setSession("genre", genreValue);
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
                            selectedInitIndex: 1, subSelectedInitIndex: 28);
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
              height: 50,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Row(children: [
                        ClipOval(
                            child: Image.network(classImageUrl ?? "",
                                fit: BoxFit.cover, height: 35, width: 35)),
                        ClipOval(
                            child: Image.network(classImageUrl ?? "",
                                fit: BoxFit.cover, height: 35, width: 35)),
                        ClipOval(
                            child: Image.network(classImageUrl ?? "",
                                fit: BoxFit.cover, height: 35, width: 35))
                      ]),
                      SizedBox(width: 5),
                      Text(numberOfUsersTaken == "0"
                          ? "Be the first to reserve!"
                          : "Taken"),
                      SizedBox(width: 3),
                      Text(
                          numberOfUsersTaken == "0"
                              ? ""
                              : numberOfUsersTaken ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(numberOfUsersTaken == "0"
                          ? ""
                          : int.parse(numberOfUsersTaken.toString()) == 1
                              ? "time"
                              : "times")
                    ]),
                    Row(children: [
                      Text("4.80"),
                      Icon(Icons.star),
                    ])
                  ])),
          Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text("Class details",
                          style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(199, 116, 10, 180))),
                      SizedBox(width: MediaQuery.of(context).size.width - 250)
                    ]),
                    SizedBox(height: 25),
                    Container(
                        child: Row(children: [
                      Container(
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 8.5),
                          child: Text("Level:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      Text(classLevel ?? "",
                          style: TextStyle(color: Colors.grey, fontSize: 18))
                    ])),
                    Container(
                        child: Row(children: [
                      Container(
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 8.5),
                          child: Text("Best for:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      Text(bestFor ?? "",
                          style: TextStyle(color: Colors.grey, fontSize: 18))
                    ])),
                    Container(
                        child: Row(children: [
                      Container(
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 8.5),
                          child: Text("Genre:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      Text(genre ?? "",
                          style: TextStyle(color: Colors.grey, fontSize: 18))
                    ])),
                  ])),
          SizedBox(height: 50),
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
                Text("Book This Class Now!"),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMainMenu(
                          selectedInitIndex: 1, subSelectedInitIndex: 30);
                    }));
                  },
                  child: Container(
                      height: 55,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13.5),
                          color: Color.fromARGB(199, 167, 10, 180)),
                      child: Text("Reserve",
                          style: TextStyle(fontSize: 16, color: Colors.white))),
                )
              ]))
        ])
      ]),
    ));
  }
}
