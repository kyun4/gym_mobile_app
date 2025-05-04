import 'package:flutter/material.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/users.dart';

import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class ClientOrders extends StatefulWidget {
  const ClientOrders({super.key});
  State<ClientOrders> createState() => _clientOrdersState();
}

Future<List<GymTrainerClasses>> getClasses(String firebaseUID) async {
  List<GymTrainerClasses> listClasses = [];
  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      if (firebaseUID == json['firebase_uid']) {
        listClasses.add(GymTrainerClasses(
            gym_trainer_class_id: json['gym_trainer_class_id'],
            training_category_id: json['training_category_id'],
            class_name: json['class_name'],
            class_description: json['class_description'],
            price_per_day: json['price_per_day'],
            cover_photo_url: json['cover_photo_url'],
            best_for: json['best_for'],
            exercise_id: json['exercise_id'],
            date_start: json['date_start'],
            date_end: json['date_end'],
            duration_in_mins: json['duration_in_mins'],
            firebase_uid: json['firebase_uid'],
            date_time_added: json['date_time_added'],
            date_time_last_updated: json['date_time_last_updated'],
            is_active: json['is_active'],
            is_done: json['is_done'],
            schedule_times: json['schedule_times'],
            scheduled_days: json['scheduled_days'],
            session_setup: json['session_setup'],
            level: json['level'],
            users_per_class_limit: json['users_per_class_limit'],
            status: json['status']));
      }
    });
  } catch (error) {
    throw error;
  }
  return listClasses;
} // getClasses

Stream<List<UserGymClasses>> getStreamUserGymClasses(String firebaseUID) {
  List<UserGymClasses> listGymUserClassesData = [];

  final databaseRef = FirebaseDatabase.instance.ref("user_gym_classes");
  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((key, json) {
      if (firebaseUID.trim() == json['trainer_id']) {
        listGymUserClassesData.add(UserGymClasses(
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

    listGymUserClassesData.sort((a, b) => DateTime.parse(b.date_time_booked)
        .compareTo(DateTime.parse(a.date_time_booked)));

    return listGymUserClassesData;
  });
} // getStreamUserGymClasses

Stream<List<GymUserSessionClass>> getStreamGymUserOrders(String firebaseUID) {
  List<GymUserSessionClass> listGymUserSessionData = [];
  final databaseRef = FirebaseDatabase.instance.ref("user_gym_sessions");
  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((key, json) {
      listGymUserSessionData.add(GymUserSessionClass(
          gym_user_session_id: json['gym_user_session_id'],
          gym_session_id: json['gym_session_id'],
          gym_class_id: json['gym_class_id'],
          date_time_meet: json['date_time_meet'],
          price_per_day_net: json['price_per_day_net'],
          price_per_day: json['price_per_day'],
          fitup_service_percentage_from_price:
              json['fitup_service_percentage_from_price'],
          fitup_service_price: json['fitup_service_price'],
          rating: json['rating'],
          review: json['review'],
          status: json['status'],
          trainer_id: json['trainer_id'],
          user_id: json['user_id'],
          admin_remittance_date_time: json['admin_remittance_date_time'],
          is_trainer_remittance_confirm:
              json['is_trainer_remittance_confirm']));
    });

    return listGymUserSessionData;
  });
} // getStreamGymUserOrders

String formatDateTime(String inputDateTime) {
  String formatDateTime = "";

  var formatter = DateFormat("MMM dd, yyyy h:mma");
  DateTime dateTimeInput = DateTime.parse(inputDateTime);
  var formatted = formatter.format(dateTimeInput);

  formatDateTime = formatted;

  return formatDateTime;
}

class _clientOrdersState extends State<ClientOrders> {
  String? firebaseUID;
  List<GymTrainerClasses> listClassesData = [];
  List<Users> listUsers = [];

  void initState() {
    super.initState();

    setState(() {
      firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    });

    getAllData(firebaseUID ?? "");
  }

  void getAllData(String firebaseUIDValue) async {
    List<GymTrainerClasses> listClassesDataValues =
        await getClasses(firebaseUIDValue);
    List<Users> listUsersData =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getUsersJson();
    setState(() {
      listClassesData = listClassesDataValues;
      listUsers = listUsersData;
    });
  } // getClassesData

  void acceptReservation(String trainerId, String clientId, String classId,
      String gymUserClassId) {
    Provider.of<FirebaseServices>(context, listen: false)
        .acceptReservation(trainerId, clientId, classId, gymUserClassId);

    Provider.of<FirebaseServices>(context, listen: false)
        .addGymSessionRecordsToSessionUsers(
            trainerId, clientId, classId, gymUserClassId, "12");
  } // acceptReservation

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const InstructorMainMenu(
                        selectedInitIndex: 0, subSelectedInitIndex: 0);
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
            title: Text("Your Client Orders", style: TextStyle(fontSize: 16))),
        body: SafeArea(
            child: Container(
          margin: const EdgeInsets.only(top: 15),
          child: StreamBuilder(
              stream: getStreamUserGymClasses(firebaseUID ?? ""),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("No available data"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text("No data"));
                }

                final rawList = snapshot.data!;
                final deduplicated = <String, dynamic>{}; // Map by ID

                for (var item in rawList) {
                  deduplicated[item.user_gym_class_id] =
                      item; // always replaces older
                }

                final uniqueList = deduplicated.values.toList();

                return ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context, index) {
                      final dataContent = uniqueList![index];
                      String gymUserClassId = dataContent.user_gym_class_id;
                      String classId = dataContent.gym_class_id;
                      String clientUserId = dataContent.user_id;
                      String bookedDate = dataContent.date_time_booked;
                      String bookingDate = formatDateTime(bookedDate);
                      String status = dataContent.status;

                      String className = listClassesData
                                  .where((classData) =>
                                      classData.gym_trainer_class_id == classId)
                                  .toList()
                                  .length >
                              0
                          ? listClassesData
                              .where((classData) =>
                                  classData.gym_trainer_class_id == classId)
                              .first
                              .class_name
                          : "";

                      String clientUsername = listUsers
                                  .where((userData) =>
                                      userData.firebase_uid == clientUserId)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  userData.firebase_uid == clientUserId)
                              .first
                              .username
                          : "";

                      String clientFirstname = listUsers
                                  .where((userData) =>
                                      userData.firebase_uid == clientUserId)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  userData.firebase_uid == clientUserId)
                              .first
                              .firstname
                          : "";

                      String clientMiddlename = listUsers
                                  .where((userData) =>
                                      userData.firebase_uid == clientUserId)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  userData.firebase_uid == clientUserId)
                              .first
                              .middlename
                          : "";

                      String clientLastname = listUsers
                                  .where((userData) =>
                                      userData.firebase_uid == clientUserId)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  userData.firebase_uid == clientUserId)
                              .first
                              .lastname
                          : "";

                      String clientExtname = listUsers
                                  .where((userData) =>
                                      userData.firebase_uid == clientUserId)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  userData.firebase_uid == clientUserId)
                              .first
                              .ext
                          : "";

                      String fullname = clientFirstname +
                          " " +
                          clientLastname +
                          " " +
                          clientExtname;

                      String trainerUsername = listUsers
                                  .where((userData) =>
                                      firebaseUID == userData.firebase_uid)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  firebaseUID == userData.firebase_uid)
                              .first
                              .username
                          : "";

                      String trainerFirstname = listUsers
                                  .where((userData) =>
                                      firebaseUID == userData.firebase_uid)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  firebaseUID == userData.firebase_uid)
                              .first
                              .firstname
                          : "";

                      String tainerMiddlename = listUsers
                                  .where((userData) =>
                                      firebaseUID == userData.firebase_uid)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  firebaseUID == userData.firebase_uid)
                              .first
                              .middlename
                          : "";

                      String trainerLastname = listUsers
                                  .where((userData) =>
                                      firebaseUID == userData.firebase_uid)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  firebaseUID == userData.firebase_uid)
                              .first
                              .lastname
                          : "";

                      String trainerExtname = listUsers
                                  .where((userData) =>
                                      firebaseUID == userData.firebase_uid)
                                  .toList()
                                  .length >
                              0
                          ? listUsers
                              .where((userData) =>
                                  firebaseUID == userData.firebase_uid)
                              .first
                              .ext
                          : "";

                      String trainerFullname = trainerFirstname +
                          " " +
                          trainerLastname +
                          " " +
                          trainerExtname;

                      return GestureDetector(
                        onTap: () {
                          setSession("trainerFullname", trainerFullname);
                          setSession("classTitle", className);
                          setSession("classId", classId);
                          setSession("trainerUsername", trainerUsername);
                          setSession("status", status);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const InstructorMainMenu(
                                selectedInitIndex: 0, subSelectedInitIndex: 91);
                          }));
                        },
                        child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 7.5),
                                    child: ClipOval(
                                        child: Image.network("", errorBuilder:
                                            (context, error, StackTrace) {
                                      return Center(
                                          child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.35)),
                                              child: Icon(
                                                  Icons.image_not_supported)));
                                    }, fit: BoxFit.cover)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    width:
                                        MediaQuery.of(context).size.width - 230,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(className.toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                          Text(fullname,
                                              style: TextStyle(fontSize: 12)),
                                          Text(bookingDate,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic))
                                        ]),
                                  ),
                                  Container(
                                      width: 115,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (status == "1") {
                                                } else {
                                                  acceptReservation(
                                                      firebaseUID ?? "",
                                                      clientUserId,
                                                      classId,
                                                      gymUserClassId);

                                                  setState(() {
                                                    status = "1";
                                                  });
                                                }
                                              },
                                              child: Container(
                                                  width: 115,
                                                  decoration: BoxDecoration(
                                                      border: status == "1"
                                                          ? Border.all(
                                                              color:
                                                                  Colors.grey)
                                                          : Border.all(
                                                              color: Colors
                                                                  .transparent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: status != "1"
                                                          ? Color.fromARGB(
                                                              199, 167, 10, 180)
                                                          : Colors.transparent),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          right: 18,
                                                          left: 18),
                                                  child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      status == "1"
                                                          ? "Accepted"
                                                          : "Accept",
                                                      style: TextStyle(color: status != "1" ? Colors.white : Colors.grey))),
                                            )
                                          ]))
                                ])),
                      );
                    });
              }),
        )));
  }
}
