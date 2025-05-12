import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:fitup/classes/Users.dart';
import 'package:fitup/classes/GymExercises.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserTrainerDetailedSearch extends StatefulWidget {
  const UserTrainerDetailedSearch({super.key});

  @override
  State<UserTrainerDetailedSearch> createState() =>
      _userTrainerDetailedSearch();
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

Stream<List<GymExercises>> getExercises() {
  final databaseRef = FirebaseDatabase.instance.ref('exercises');

  return databaseRef.onValue.map((event) {
    final List<GymExercises> listExercises = [];
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((dataId, data) {
      listExercises.add(GymExercises(
          exercise_id: data['exercise_id'],
          exercise_name: data['exercise_name'],
          details: data['details'],
          icon: data['icon'],
          improve: data['improve'],
          added_by: data['added_by'],
          status: data['status'],
          date_time_added: data['date_time_added'],
          last_updated_by: data['last_updated_by'],
          date_time_last_updated: data['date_time_last_updated']));
    });

    return listExercises;
  });
} // getExercises()

Stream<List<GymTrainerClasses>> getStreamTrainerClasses() {
  final databaseRef = FirebaseDatabase.instance.ref("gym_trainer_classes");

  return databaseRef.onValue.map((event) {
    final List<GymTrainerClasses> gymTrainerClasses = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

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

    return gymTrainerClasses;
  });
} // getStreamTrainerClasses

Future<List<UserGymClasses>> getGymUserDetails() async {
  final List<UserGymClasses> listData = [];
  String firebaseUserId = FirebaseAuth.instance.currentUser!.uid.toString();
  String url = dbUrl + "gym_user_classes.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null ||
        extractedData == Null ||
        response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((data, json) {
      if (json['firebase_uid'] == firebaseUserId) {
        listData.add(UserGymClasses(
            user_gym_class_id: json['user_gym_class_id'] ?? "",
            gym_class_id: json['gym_class_id'] ?? "",
            user_id: json['user_id'] ?? "",
            trainer_id: json['trainer_id'] ?? "",
            transaction_id: json['transaction_id'] ?? "",
            status: json['status'] ?? "",
            payment_status: json['payment_status'] ?? "",
            date_time_trainer_approved:
                json['date_time_trainer_approved'] ?? "",
            date_time_booked: json['date_time_booked'] ?? "",
            date_time_admin_approved: json['date_time_admin_approved'] ?? "",
            approved_by_admin: json['approved_by_admin'] ?? ""));
      }
    });
  } catch (error) {
    throw error;
  }

  return listData;
} // getGymUserDetails

Future<List<Users>> getTrainerDetails() async {
  final List<Users> listUsers = [];

  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {}

    extractedData.forEach((userId, userData) {
      listUsers.add(Users(
          firebase_uid: userData['firebase_uid'] ?? '',
          username: userData['username'] ?? '',
          firstname: userData['firstname'] ?? '',
          middlename: userData['middlename'] ?? '',
          lastname: userData['lastname'] ?? '',
          ext: userData['ext'] ?? '',
          role: userData['role'] ?? '',
          phone: userData['phone'] ?? '',
          email: userData['email'] ?? '',
          otp: userData['otp'] ?? '',
          email_verified: userData['email_verified'] ?? '',
          occupation: userData['occupation'] ?? '',
          title: userData['title'] ?? '',
          date_time_registered: userData['date_time_registered'] ?? '',
          date_time_premium_activated: userData['date_time_activated'] ?? '',
          date_time_membership: userData['date_time_membership'] ?? ''));
    });
  } catch (error) {
    throw error;
  }

  return listUsers;
} // getTrainerDetails

Stream<List<Users>> getTrainers(String coachNameLike) {
  final databaseRef = FirebaseDatabase.instance.ref("users");

  return databaseRef.onValue.map((event) {
    final List<Users> listUsers = [];
    List<Users> filteredUsers = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((userId, userData) {
      if (userData['role'] == "2") {
        listUsers.add(Users(
            firebase_uid: userData['firebase_uid'] ?? '',
            username: userData['username'] ?? '',
            firstname: userData['firstname'] ?? '',
            middlename: userData['middlename'] ?? '',
            lastname: userData['lastname'] ?? '',
            ext: userData['ext'] ?? '',
            role: userData['role'] ?? '',
            phone: userData['phone'] ?? '',
            email: userData['email'] ?? '',
            otp: userData['otp'] ?? '',
            email_verified: userData['email_verified'] ?? '',
            occupation: userData['occupation'] ?? '',
            title: userData['title'] ?? '',
            date_time_registered: userData['date_time_registered'] ?? '',
            date_time_premium_activated: userData['date_time_activated'] ?? '',
            date_time_membership: userData['date_time_membership'] ?? ''));
      }
    });

    if (coachNameLike.isEmpty) {
      filteredUsers = listUsers;
    } else {
      filteredUsers = listUsers
          .where((userItem) => userItem.username.contains(coachNameLike))
          .toList();
    }

    // listUsers.where((userData) => userData.role == "2").toList();

    return filteredUsers;
  });
} // getTrainers

class _userTrainerDetailedSearch extends State<UserTrainerDetailedSearch> {
  String? exerciseNameSelected;
  String? availabilityStartTime;
  String? availabilityEndTime;
  String? trainingVenue;
  String? coachNameSearch;
  String? exerciseId;
  List<Users> listTrainerDetails = [];
  List<UserGymClasses> listGymUserClasses = [];

  @override
  void initState() {
    super.initState();
    getSharedSessionValues();
    getUserTrainerDetails();
    getUserGymClasses();
  }

  void getUserTrainerDetails() async {
    List<Users> listTrainers = await getTrainerDetails();
    setState(() {
      listTrainerDetails = listTrainers;
    });
  } // getTrainerDetails

  void getUserGymClasses() async {
    List<UserGymClasses> listUserGymData = await getGymUserDetails();
    setState(() {
      listGymUserClasses = listUserGymData;
    });
  } // getUserGymClasses

  void getSharedSessionValues() async {
    String? exerciseName = await getSession("exerciseNameSelected");
    String? coachName = await getSession("coachName");
    String? startTimeRange = await getSession("selectedStartTime");
    String? endTimeRange = await getSession("selectedEndTime");
    String? trainingSetup = await getSession("training_venue");
    String? exerciseIdValue = await getSession("exercise_id");

    setState(() {
      exerciseNameSelected = exerciseName;
      coachNameSearch = coachName;
      availabilityStartTime = startTimeRange;
      availabilityEndTime = endTimeRange;
      trainingVenue = trainingSetup;
      exerciseId = exerciseIdValue;
    });
  } // getSharedSessionValues

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.63,
                  child: Container(
                      child: StreamBuilder(
                          stream: getStreamTrainerClasses(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text("No gym classes data available"));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return Scaffold(
                              body: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final userGymData = snapshot.data!;
                                    final gymData = userGymData[index];
                                    String exercise_id_from_cardview =
                                        gymData.exercise_id;
                                    String trainerFirebaseUID =
                                        gymData.firebase_uid;
                                    String cover_photo_url =
                                        gymData.cover_photo_url;
                                    String className = gymData.class_name;
                                    String classDescription =
                                        gymData.class_description;
                                    String pricePerDay = gymData.price_per_day;
                                    String scheduledDays =
                                        gymData.scheduled_days;
                                    String gymTrainerClassId =
                                        gymData.gym_trainer_class_id;

                                    int hasAlreadyBooked = listGymUserClasses
                                        .where((listGymUserData) =>
                                            listGymUserData.gym_class_id ==
                                            gymTrainerClassId)
                                        .toList()
                                        .length;

                                    String username = listTrainerDetails
                                                .where((trainerData) =>
                                                    trainerData.firebase_uid ==
                                                    trainerFirebaseUID)
                                                .toList()
                                                .length >
                                            0
                                        ? listTrainerDetails
                                            .where((trainerData) =>
                                                trainerData.firebase_uid ==
                                                trainerFirebaseUID)
                                            .toList()[0]
                                            .username
                                        : "";

                                    String firstname = listTrainerDetails
                                                .where((trainerData) =>
                                                    trainerData.firebase_uid ==
                                                    trainerFirebaseUID)
                                                .toList()
                                                .length >
                                            0
                                        ? listTrainerDetails
                                            .where((trainerData) =>
                                                trainerData.firebase_uid ==
                                                trainerFirebaseUID)
                                            .toList()[0]
                                            .firstname
                                        : "";

                                    String fullname = firstname;

                                    return GestureDetector(
                                      onTap: () {
                                        if (hasAlreadyBooked == 1) {
                                        } else {
                                          setSession("receiverName", fullname);
                                          setSession(
                                              "trainerUsername", username);
                                          setSession("trainerFirebaseUid",
                                              trainerFirebaseUID);
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return const UserMainMenu(
                                                selectedInitIndex: 1,
                                                subSelectedInitIndex: 26);
                                          }));
                                        }
                                      },
                                      child: Visibility(
                                        visible: exerciseId ==
                                                exercise_id_from_cardview
                                            ? true
                                            : false,
                                        child: Container(
                                            padding: const EdgeInsets.all(5),
                                            margin: const EdgeInsets.only(
                                                top: 15,
                                                left: 10,
                                                right: 10,
                                                bottom: 20),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                      child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Image.network(
                                                        height: 250,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            50,
                                                        cover_photo_url,
                                                        errorBuilder: (context,
                                                            error, StackTrace) {
                                                      return Center(
                                                          child: Container(
                                                              height: 250,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  50,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.2))),
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(Icons
                                                                        .image_not_supported_outlined),
                                                                    Center(
                                                                        child: Text(
                                                                            "Error Loading Image"))
                                                                  ])));
                                                    }, loadingBuilder: (context,
                                                            Widget child,
                                                            ImageChunkEvent?
                                                                loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      } else {
                                                        return Container(
                                                          height: 250,
                                                          width: 250,
                                                          child: Center(
                                                              child: CircularProgressIndicator(
                                                                  value: loadingProgress !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          (loadingProgress.expectedTotalBytes ??
                                                                              1)
                                                                      : null)),
                                                        );
                                                      }
                                                    }, fit: BoxFit.cover),
                                                  )),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(children: [
                                                                  Icon(
                                                                      Icons
                                                                          .location_pin,
                                                                      color: Color.fromARGB(
                                                                          199,
                                                                          118,
                                                                          10,
                                                                          160)),
                                                                  Text(
                                                                      " $className with ${username}"),
                                                                ]),
                                                                Row(children: [
                                                                  Text("4.8 "),
                                                                  Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 20,
                                                                      color: Color.fromARGB(
                                                                          199,
                                                                          118,
                                                                          10,
                                                                          160))
                                                                ])
                                                              ]),
                                                          SizedBox(height: 8),
                                                          hasAlreadyBooked == 1
                                                              ? Text(
                                                                  " You have already booked this class")
                                                              : Visibility(
                                                                  visible:
                                                                      false,
                                                                  child:
                                                                      Text("")),
                                                          Text("Location",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12)),
                                                          Text(
                                                              "Date and Time Availability: $scheduledDays",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12)),
                                                          SizedBox(height: 8),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    "PHP $pricePerDay / Day",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "Discounted if booked early",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w300)),
                                                              ]),
                                                        ]),
                                                  )
                                                ])),
                                      ),
                                    );
                                  }),
                            );
                          }))),
            ],
          )),
      Positioned(
        top: 0,
        right: 0,
        left: 0,
        child: Column(
          children: [
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 238, 239),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 15))
                ],
              ),
              child: Column(children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return const UserMainMenu(
                          selectedInitIndex: 1, subSelectedInitIndex: 24);
                    }));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.65),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: Offset(0, 0))
                      ],
                    ),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 30, bottom: 10),
                    padding: const EdgeInsets.all(12),
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: const EdgeInsets.all(5),
                              child: Icon(Icons.search,
                                  color: Color.fromARGB(199, 116, 10, 180))),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.7,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exerciseNameSelected ?? "",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(199, 116, 10, 180)),
                                  ),
                                  Text(
                                    "July 22 - 1 Adult",
                                    style: TextStyle(
                                        color: Colors.black54.withOpacity(0.8)),
                                  )
                                ]),
                          ),
                          Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Color.fromARGB(199, 116, 80, 180)),
                              child: SvgPicture.asset(
                                  "assets/svg/filter-svgrepo-com.svg",
                                  color: Colors.white))
                        ]),
                  ),
                ),
                Container(
                    height: 85,
                    margin: const EdgeInsets.only(left: 13.5, right: 13.5),
                    child: StreamBuilder(
                        stream: getExercises(),
                        builder: (context, snapshot) {
                          final data = snapshot.data!;
                          int listLength = snapshot.data!.length;

                          if (snapshot.hasError) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          return ListView.builder(
                              itemCount: listLength,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                String exerciseIdSelection =
                                    data[index].exercise_id;
                                String exerciseName = data[index].exercise_name;
                                String icon = data[index].icon;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      exerciseNameSelected = exerciseName;
                                      exerciseId = exerciseIdSelection;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 12, bottom: 5),
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 3.0,
                                              color: exerciseNameSelected ==
                                                      exerciseName
                                                  ? Color.fromARGB(
                                                      199, 116, 10, 180)
                                                  : Colors.black54)),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 45,
                                            width: 45,
                                            padding: const EdgeInsets.all(7),
                                            child: SvgPicture.asset(
                                              "assets/svg/$icon",
                                              color: exerciseNameSelected ==
                                                      exerciseName
                                                  ? Color.fromARGB(
                                                      199, 116, 10, 180)
                                                  : Colors.black54,
                                            )),
                                        Container(
                                            child: Text(exerciseName,
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: exerciseNameSelected ==
                                                            exerciseName
                                                        ? Color.fromARGB(
                                                            199, 116, 10, 180)
                                                        : Colors.black54)))
                                      ],
                                    ),
                                  ),
                                );
                              });
                        })),
              ]),
            ),
          ],
        ),
      ),
    ])));
  }
}
