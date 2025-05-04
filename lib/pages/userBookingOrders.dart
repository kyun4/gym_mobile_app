import 'package:flutter/material.dart';
import 'package:fitup/pages/UserMainMenu.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/users.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingOrders extends StatefulWidget {
  const UserBookingOrders({super.key});

  State<UserBookingOrders> createState() => _userBookingOrdersState();
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

Future<List<GymTrainerClasses>> getGymTrainerClasses() async {
  List<GymTrainerClasses> listGymTrainerClasses = [];
  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listGymTrainerClasses.add(GymTrainerClasses(
          gym_trainer_class_id: json['gym_trainer_class_id'] ?? "",
          training_category_id: json['training_category_id'] ?? "",
          class_name: json['class_name'] ?? "",
          class_description: json['class_description'] ?? "",
          price_per_day: json['price_per_day'] ?? "",
          cover_photo_url: json['cover_photo_url'] ?? "",
          best_for: json['best_for'] ?? "",
          exercise_id: json['exercise_id'] ?? "",
          date_start: json['date_start'] ?? "",
          date_end: json['date_end'] ?? "",
          duration_in_mins: json['duration_in_mins'] ?? "",
          firebase_uid: json['firebase_uid'] ?? "",
          date_time_added: json['date_time_added'] ?? "",
          date_time_last_updated: json['date_time_last_updated'],
          is_active: json['is_active'] ?? "",
          is_done: json['is_done'] ?? "",
          schedule_times: json['schedule_times'] ?? "",
          scheduled_days: json['scheduled_days'] ?? "",
          session_setup: json['session_setup'] ?? "",
          level: json['level'] ?? "",
          users_per_class_limit: json['users_per_class_limit'] ?? "",
          status: json['status'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listGymTrainerClasses;
} // getGymTrainerClasses

Stream<List<UserGymClasses>> streamBookingOrders(String firebaseUID) {
  final dbref = FirebaseDatabase.instance.ref("user_gym_classes");
  return dbref.onValue.map((event) {
    final List<UserGymClasses> list_gym_classes = [];
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((dataId, json) {
      if (firebaseUID == json['user_id']) {
        list_gym_classes.add(UserGymClasses(
            user_gym_class_id: json['user_gym_class_id'],
            gym_class_id: json['gym_class_id'],
            user_id: json['user_id'],
            trainer_id: json['trainer_id'],
            transaction_id: json['transaction_id'],
            status: json['status'],
            payment_status: json['payment_status'],
            date_time_trainer_approved: json['date_time_trainer_approved'],
            date_time_booked: json['date_time_booked'],
            date_time_admin_approved: json['date_time_admin_approved'],
            approved_by_admin: json['approved_by_admin']));
      }
    });

    return list_gym_classes;
  });
} // streamBookingOrders

class _userBookingOrdersState extends State<UserBookingOrders> {
  List<GymTrainerClasses> listGymTrainer = [];
  List<Users> listUsers = [];
  String? firebaseUIDValue;

  void initState() {
    super.initState();
    getTrainerClassesFuture();
    getAllUsersFuture();

    String? fuid = FirebaseAuth.instance.currentUser!.uid.toString();
    setState(() {
      firebaseUIDValue = fuid;
    });
  }

  void getAllUsersFuture() async {
    List<Users> listAllUsers =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getUsersJson();

    setState(() {
      listUsers = listAllUsers;
    });
  }

  void getTrainerClassesFuture() async {
    List<GymTrainerClasses> listGymTrainerValues = await getGymTrainerClasses();
    setState(() {
      listGymTrainer = listGymTrainerValues;
    });
  } // getTrainerClassesFuture

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const UserMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 0);
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
                            color: const Color.fromARGB(199, 118, 10, 160))))),
            centerTitle: true,
            title: Text("My Booking Orders", style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                    stream: streamBookingOrders(firebaseUIDValue ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("No data Available"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final userGymData = snapshot.data![index];
                            String gym_class_id = userGymData.gym_class_id;
                            String date_time_booked =
                                userGymData.date_time_booked;
                            String date_time_accepted =
                                userGymData.date_time_trainer_approved;
                            String status = userGymData.status;
                            String paymentStatus = userGymData.payment_status;

                            String classTitle = listGymTrainer
                                        .where((gymData) =>
                                            gymData.gym_trainer_class_id ==
                                            gym_class_id)
                                        .toList()
                                        .length >
                                    0
                                ? listGymTrainer
                                    .where((gymData) =>
                                        gymData.gym_trainer_class_id ==
                                        gym_class_id)
                                    .toList()[0]
                                    .class_name
                                : "";

                            String trainerId = listGymTrainer
                                        .where((gymData) =>
                                            gymData.gym_trainer_class_id ==
                                            gym_class_id)
                                        .toList()
                                        .length >
                                    0
                                ? listGymTrainer
                                    .where((gymData) =>
                                        gymData.gym_trainer_class_id ==
                                        gym_class_id)
                                    .toList()[0]
                                    .firebase_uid
                                : "";

                            String trainerUsername = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == trainerId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == trainerId)
                                    .toList()[0]
                                    .username
                                : "";

                            String trainerFirstname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == trainerId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == trainerId)
                                    .toList()[0]
                                    .firstname
                                : "";

                            String trainerLastname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == trainerId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == trainerId)
                                    .toList()[0]
                                    .lastname
                                : "";

                            String trainerFullname =
                                trainerFirstname + " " + trainerLastname;

                            String coverPhotoUrl = listGymTrainer
                                        .where((gymData) =>
                                            gymData.gym_trainer_class_id ==
                                            gym_class_id)
                                        .toList()
                                        .length >
                                    0
                                ? listGymTrainer
                                    .where((gymData) =>
                                        gymData.gym_trainer_class_id ==
                                        gym_class_id)
                                    .toList()[0]
                                    .cover_photo_url
                                : "";

                            String userCount = listUsers.length.toString();

                            //String classTitle = gym_class_id;

                            return GestureDetector(
                              onTap: () {
                                setSession("classTitle", classTitle);
                                setSession("classId", gym_class_id);
                                setSession("trainerUsername", trainerUsername);
                                setSession("trainerFullname", trainerFullname);
                                setSession("gymUserSessionStatus", status);
                                setSession("gymUserSessionPaymentStatus",
                                    paymentStatus);

                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const UserMainMenu(
                                      selectedInitIndex: 4,
                                      subSelectedInitIndex: 14);
                                }));
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(coverPhotoUrl,
                                              height: 60, width: 85,
                                              loadingBuilder: (context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                      loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return Center(
                                                  child: CircularProgressIndicator(
                                                      value: loadingProgress !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null));
                                            }
                                          }, errorBuilder:
                                                  (context, error, StackTrace) {
                                            return Center(
                                                child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    size: 50));
                                          }, fit: BoxFit.cover),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20, right: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              200,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    classTitle.toUpperCase() +
                                                        "\nby " +
                                                        trainerFullname,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                status == "1"
                                                    ? Text(
                                                        "Accepted: " +
                                                            date_time_accepted,
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12))
                                                    : Text(
                                                        "Booked: " +
                                                            date_time_booked,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 12))
                                              ]),
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: Container(
                                            child: status == "1"
                                                ? Container(
                                                    width: 25,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.green),
                                                    child: Icon(Icons.check,
                                                        color: Colors.white))
                                                : Container(
                                                    width: 25,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.grey),
                                                    child: Icon(Icons.pending,
                                                        color: Colors.white)),
                                          ),
                                        )
                                      ])),
                            );
                          });
                    }))));
  }
}
