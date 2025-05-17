import 'package:flutter/material.dart';
import 'package:fitup/classes/AppConfig.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/GymExercises.dart';
import 'package:fitup/classes/UserDetails.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/UserGymClasses.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';
import 'dart:convert';

String dbUrl = AppConfig.dbUrl;

class AdminClasses extends StatefulWidget {
  const AdminClasses({super.key});
  State<AdminClasses> createState() => _adminClassesState();
}

Future<List<GymExercises>> getGymExercises() async {
  List<GymExercises> listGymExercisesData = [];
  String url = dbUrl + "exercises.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listGymExercisesData.add(GymExercises(
          exercise_id: json['exercise_id'] ?? "",
          details: json['details'] ?? "",
          exercise_name: json['exercise_name'] ?? "",
          icon: json['icon'] ?? "",
          improve: json['improve'] ?? "",
          status: json['status'] ?? "",
          date_time_added: json['date_time_added'],
          added_by: json['added_by'] ?? "",
          date_time_last_updated: json['date_time_last_updated'] ?? "",
          last_updated_by: json['last_updated_by'] ?? ""));
    });
  } catch (error) {
    throw error;
  }
  return listGymExercisesData;
} // getGymExercisesData

Future<List<GymTrainerClasses>> getGymClasses() async {
  List<GymTrainerClasses> listGymTrainerData = [];
  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listGymTrainerData.add(GymTrainerClasses(
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
          date_time_last_updated: json['date_time_last_updated'] ?? "",
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
  return listGymTrainerData;
} // getGymClasses

Future<List<GymUserSessionClass>> getUserSessions() async {
  List<GymUserSessionClass> listGymUserSessionsData = [];
  String url = dbUrl + "gym_session_users.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      String userIdSession = json['user_id'] ?? "";
      String gymClassId = json['gym_class_id'] ?? "";

      listGymUserSessionsData.add(GymUserSessionClass(
          gym_user_session_id: json['gym_user_session_id'] ?? "",
          gym_session_id: json['gym_session_id'] ?? "",
          gym_class_id: json['gym_class_id'] ?? "",
          date_time_meet: json['date_time_meet'] ?? "",
          price_per_day_net: json['price_per_day_net'] ?? "",
          price_per_day: json['price_per_day'] ?? "",
          fitup_service_percentage_from_price:
              json['fitup_service_percentage_from_price'] ?? "",
          fitup_service_price: json['fitup_service_price'] ?? "",
          rating: json['rating'] ?? "",
          review: json['review'] ?? "",
          status: json['status'] ?? "",
          trainer_id: json['trainer_id'] ?? "",
          user_id: json['user_id'] ?? "",
          admin_remittance_date_time: json['admin_remittance_date_time'] ?? "",
          is_trainer_remittance_confirm:
              json['is_trainer_remittance_confirm'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listGymUserSessionsData;
} // getUserSessions

Future<List<UserGymClasses>> getUserGymClasses() async {
  List<UserGymClasses> listUserGymClasses = [];
  String url = dbUrl + "user_gym_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listUserGymClasses.add(UserGymClasses(
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

  return listUserGymClasses;
} // getUserGymClasses

Future<List<UserDetails>> getAllUsers() async {
  List<UserDetails> listUsersData = [];
  String url = dbUrl + "users.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listUsersData.add(UserDetails(
          username: json['username'] ?? "",
          firebase_uid: json['firebase_uid'] ?? "",
          firstname: json['firstname'] ?? "",
          middlename: json['middlename'] ?? "",
          lastname: json['lastname'] ?? "",
          ext: json['ext'] ?? "",
          email: json['email'] ?? "",
          phone: json['phone'] ?? "",
          otp: json['otp'] ?? "",
          occupation: json['occupation'] ?? "",
          title: json['title'] ?? "",
          role: json['role'] ?? "",
          date_time_membership: json['date_time_membership'] ?? "",
          date_time_premium_activated: json['date_time_premium_actvated'] ?? "",
          date_time_registered: json['date_time_registered'] ?? "",
          email_verified: json['email_verified'] ?? ""));
    });
  } catch (error) {
    throw error;
  }
  return listUsersData;
} // getAllUsers

String getUserDetailsByFirebaseUID(
    List<UserDetails> userListData, String firebaseUID, String field) {
  String value = "";
  var user = userListData
      .firstWhere((userData) => userData.firebase_uid == firebaseUID);

  if (user.firebase_uid.isNotEmpty) {
    var userMap = user.toMap();
    value = userMap[field]?.toString() ?? "";
  }

  return value;
} // getUserByFirebaseUID

class _adminClassesState extends State<AdminClasses> {
  List<GymExercises> listGymExercisesData = [];
  List<UserDetails> listUsers = [];
  List<GymSessionClass> listGymSessionData = [];
  List<GymUserSessionClass> listGymUserSessionData = [];
  List<UserGymClasses> listUserGymClasses = [];

  void initState() {
    super.initState();
    getExercisesData();
    getUsers();
    getSessionsData();
  }

  void getSessionsData() async {
    List<GymSessionClass> listGymSessionsDataValues =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getStreamGymSessions();

    List<GymUserSessionClass> listGymSessionUsers = await getUserSessions();

    List<UserGymClasses> listGymUserClassesData = await getUserGymClasses();

    setState(() {
      listGymSessionData = listGymSessionsDataValues;
      listGymUserSessionData = listGymSessionUsers;
      listUserGymClasses = listGymUserClassesData;
    });
  } // getSessions

  void getExercisesData() async {
    List<GymExercises> listExercises = await getGymExercises();
    setState(() {
      listGymExercisesData = listExercises;
    });
  } // getExercisesData

  void getUsers() async {
    List<UserDetails> listUsersData = await getAllUsers();

    setState(() {
      listUsers = listUsersData;
    });
  } // getUsers

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.transparent),
            centerTitle: true,
            title: Text("Gym Classes", style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
                    stream: getGymClasses().asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("No data available"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final dataRaw = snapshot.data!;
                      final deduplicated = <String, dynamic>{};

                      for (var item in dataRaw) {
                        deduplicated[item.gym_trainer_class_id] = item;
                      }

                      var uniqueList = deduplicated.values.toList();

                      return ListView.builder(
                          itemCount: uniqueList.length,
                          itemBuilder: (context, index) {
                            final dataContent = uniqueList[index];
                            String classId = dataContent.gym_trainer_class_id;
                            String className = dataContent.class_name;
                            String classDescription =
                                dataContent.class_description;
                            String exerciseId = dataContent.exercise_id;
                            String firebaseUID = dataContent.firebase_uid;

                            int usersEnrolled = listUserGymClasses
                                .where((userGymClasses) =>
                                    userGymClasses.gym_class_id == classId &&
                                    userGymClasses.status == "1")
                                .toList()
                                .length;

                            int numberOfSessions = listGymSessionData
                                .where((sessionData) =>
                                    sessionData.gym_class_id == classId)
                                .toList()
                                .length;

                            String firstname = getUserDetailsByFirebaseUID(
                                listUsers, firebaseUID, "firstname");

                            String middlename = getUserDetailsByFirebaseUID(
                                listUsers, firebaseUID, "middlename");

                            String lastname = getUserDetailsByFirebaseUID(
                                listUsers, firebaseUID, "lastname");

                            String extname = getUserDetailsByFirebaseUID(
                                listUsers, firebaseUID, "ext");

                            String dateTimeAdded =
                                DateFormat("MMM dd, yyyy H:mma").format(
                                    DateTime.parse(
                                        dataContent.date_time_added));

                            String fullname = firstname + " " + lastname;

                            String exerciseIcon = listGymExercisesData
                                        .where((exerciseData) =>
                                            exerciseData.exercise_id ==
                                            exerciseId)
                                        .length >
                                    0
                                ? listGymExercisesData
                                    .where((exerciseData) =>
                                        exerciseData.exercise_id == exerciseId)
                                    .toList()
                                    .first
                                    .icon
                                : "";

                            return Container(
                                padding: const EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          height: 65,
                                          width: 65,
                                          margin: const EdgeInsets.only(
                                              left: 5,
                                              right: 15,
                                              top: 2.5,
                                              bottom: 2.5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color:
                                                  Colors.grey.withOpacity(0.2)),
                                          child: exerciseIcon != ""
                                              ? SvgPicture.asset(
                                                  "assets/svg/" + exerciseIcon)
                                              : Icon(Icons.class_rounded,
                                                  color: Colors.black87)),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(className,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(classDescription),
                                                    Text(
                                                        "Enrolled: " +
                                                            usersEnrolled
                                                                .toString() +
                                                            "   Sessions: " +
                                                            numberOfSessions
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontSize: 9)),
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "By Trainer " +
                                                            fullname
                                                                .toUpperCase() +
                                                            "",
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 12)),
                                                    Text(dateTimeAdded,
                                                        style: TextStyle(
                                                            fontSize: 11))
                                                  ]),
                                            ]),
                                      )
                                    ]));
                          });
                    }))));
  }
}
