import 'package:flutter/material.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';

import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/AdminSettings.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class TrainerBookingSessions extends StatefulWidget {
  const TrainerBookingSessions({super.key});

  State<TrainerBookingSessions> createState() => _trainerBookingSessionsState();
}

void addPaymentMethodGCash(String firebaseUid, String accountNumber) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "user_payment_method/$firebaseUid.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "gcash": accountNumber,
          "gcash_date_time_add": date_time_formatted,
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid,
          "credit_card": "",
          "credit_card_cvc": "",
          "credit_card_date_time_add": "",
          "credit_card_expiry": "",
          "apple_pay": "",
          "apple_pay_date_time_add": "",
        }));
  } catch (error) {
    throw Error;
  }
} // addPaymentMethodGCash

void addPaymentMethodCreditCard(
    String firebaseUid, String accountNumber, String expiry, String cvc) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "user_payment_method/$firebaseUid.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "gcash": accountNumber,
          "gcash_date_time_add": date_time_formatted,
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid,
          "credit_card": accountNumber,
          "credit_card_cvc": cvc,
          "credit_card_date_time_add": date_time_formatted,
          "credit_card_expiry": expiry,
          "apple_pay": "",
          "apple_pay_date_time_add": "",
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid
        }));
  } catch (error) {
    throw Error;
  }
} // addPaymentMethodCreditCard

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

class _trainerBookingSessionsState extends State<TrainerBookingSessions> {
  String? trainerFullname;
  String? classTitle;
  String? trainerUsername;
  String? gymUserClassStatus;
  String? classId;
  String? firebaseUID;
  String? gymUserSessionStatus;
  String? gymUserSessionPaymentStatus;
  String? gymSessionUserId;
  List<GymSessionClass> listGymSessionData = [];
  List<GymUserSessionClass> listGymUserSessionData = [];
  List<AdminSettings> listAdminSettingsData = [];

  void initState() {
    super.initState();
    getSharedPreferences();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getSessionsData();
    getAdminSettings();
  }

  void updateSession(String gym_session_status, String userSessionId) {
    String dateTimeFinished =
        DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    String url = dbUrl + "gym_sessions/$userSessionId.json";
    try {
      final response = http.patch(Uri.parse(url),
          body: json.encode({
            "status": gym_session_status,
            "date_time_actual_finished": dateTimeFinished
          }));
    } catch (error) {
      throw error;
    }
  } // updateSession

  void getSessionsData() async {
    List<GymSessionClass> listGymSessionsDataValues =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getStreamGymSessions();

    List<GymUserSessionClass> listGymSessionUsers = await getUserSessions();

    setState(() {
      listGymSessionData = listGymSessionsDataValues;
      listGymUserSessionData = listGymSessionUsers;
    });
  } // getSessions

  void getAdminSettings() async {
    List<AdminSettings> listAdminSettingsValue =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getAdminSettings();
    setState(() {
      listAdminSettingsData = listAdminSettingsValue;
    });
  } // getAdminSettings

  void getSharedPreferences() async {
    String? trainerFullnameValue = await getSession("trainerFullname");
    String? classTitleValue = await getSession("classTitle");
    String? classIdValue = await getSession("classId");
    String? trainerUsernameValue = await getSession("trainerUsername");
    String? gymUserClassStatusValue = await getSession("status");
    String? sessionUserIdValue = await getSession("session_user_id");

    setState(() {
      trainerFullname = trainerFullnameValue;
      classTitle = classTitleValue;
      classId = classIdValue;
      trainerUsername = trainerUsernameValue;
      gymUserClassStatus = gymUserClassStatusValue;
      gymSessionUserId = sessionUserIdValue;
    });
  } // getSharedPreferences

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
            admin_remittance_date_time:
                json['admin_remittance_date_time'] ?? "",
            is_trainer_remittance_confirm:
                json['is_trainer_remittance_confirm'] ?? ""));
      });
    } catch (error) {
      throw error;
    }

    return listGymUserSessionsData;
  } // getUserSessions

  Stream<List<GymSessionClass>> getStreamSession(String gymClassId) {
    final dbref = FirebaseDatabase.instance.ref("gym_sessions");

    return dbref.onValue.map((event) {
      final List<GymSessionClass> listGymSessionsData = [];
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((key, json) {
        if (gymClassId == json['gym_class_id']) {
          listGymSessionsData.add(GymSessionClass(
              gym_session_id: json['gym_session_id'] ?? "",
              gym_class_id: json['gym_class_id'] ?? "",
              for_date_schedule: json['for_date_schedule'] ?? "",
              for_day_schedule: json['for_day_schedule'] ?? "",
              for_time_range_schedule: json['for_time_range_schedule'] ?? "",
              price_per_day: json['price_per_day'] ?? "",
              trainer_id: json['trainer_id'] ?? "",
              date_time_actual_finished:
                  json['date_time_actual_finished'] ?? "",
              status: json['status'] ?? ""));
        }
      });

      listGymSessionsData.sort((
        a,
        b,
      ) =>
          DateTime.parse(a.for_date_schedule)
              .compareTo(DateTime.parse(b.for_date_schedule)));

      return listGymSessionsData;
    });
  } // getStreamSession

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const InstructorMainMenu(
                        selectedInitIndex: 0, subSelectedInitIndex: 90);
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
            title: Column(children: [
              Text("Sessions for",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(classTitle!.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12))
            ])),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
                    stream: getStreamSession(classId ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Sessions empty"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final rawList = snapshot.data!;
                      final deduplicated = <String, dynamic>{}; // Map by ID

                      for (var item in rawList) {
                        deduplicated[item.gym_session_id] =
                            item; // always replaces older
                      }

                      final uniqueList = deduplicated.values.toList();

                      return ListView.builder(
                          itemCount: uniqueList.length,
                          itemBuilder: (context, index) {
                            final dataContent = uniqueList[index];

                            String dateSchedule = dataContent.for_date_schedule;
                            String dateScheduleFormat =
                                DateFormat("MMM dd, yyyy")
                                    .format(DateTime.parse(dateSchedule));
                            String price_per_day = dataContent.price_per_day;

                            String gym_session_status = dataContent.status;
                            String sessionId = dataContent.gym_session_id;

                            String userStatus = listGymUserSessionData
                                        .where((userSession) =>
                                            userSession.gym_session_id ==
                                                sessionId &&
                                            userSession.user_id ==
                                                gymSessionUserId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSessionData
                                    .where((userSession) =>
                                        userSession.gym_session_id == sessionId)
                                    .toList()[0]
                                    .status
                                : "";

                            String price_per_day_net = listGymUserSessionData
                                        .where((userSession) =>
                                            userSession.gym_session_id ==
                                            sessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSessionData
                                    .where((userSession) =>
                                        userSession.gym_session_id == sessionId)
                                    .toList()[0]
                                    .price_per_day_net
                                : "";

                            String fitupFee = listGymUserSessionData
                                        .where((userSession) =>
                                            userSession.gym_session_id ==
                                            sessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSessionData
                                    .where((userSession) =>
                                        userSession.gym_session_id == sessionId)
                                    .toList()[0]
                                    .fitup_service_price
                                : "";

                            String paymentStatus = "";

                            if (userStatus == "1") {
                              paymentStatus = "(PAID)";
                            }

                            return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black12))),
                                padding: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width - 20,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: userStatus == "1"
                                                  ? Colors.green
                                                  : Colors.grey
                                                      .withOpacity(0.3)),
                                          child: Icon(Icons.class_outlined,
                                              color: userStatus == "1"
                                                  ? Colors.white
                                                  : Colors.black87)),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 15),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              225,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(dateScheduleFormat),
                                                Text(
                                                    "PHP " +
                                                        price_per_day +
                                                        " " +
                                                        paymentStatus +
                                                        "",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            userStatus == "1"
                                                                ? FontWeight
                                                                    .w400
                                                                : FontWeight
                                                                    .bold,
                                                        fontSize: 16)),
                                                Visibility(
                                                  visible: userStatus == "1"
                                                      ? true
                                                      : false,
                                                  child: Text(
                                                      userStatus == "1"
                                                          ? "PHP $price_per_day_net"
                                                          : "",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.green)),
                                                ),
                                                Visibility(
                                                    visible: userStatus == "1"
                                                        ? true
                                                        : false,
                                                    child: Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 5),
                                                        child: Row(children: [
                                                          Text(
                                                              "Fit Up Service Fee: PHP " +
                                                                  fitupFee,
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  fontSize: 10))
                                                        ])))
                                              ])),
                                      Text(
                                          gymUserSessionStatus == "0"
                                              ? "Pay upon\nTrainer's Confirmation"
                                              : "",
                                          style: TextStyle(fontSize: 12)),
                                      Visibility(
                                        visible: true,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (gym_session_status != "1" &&
                                                gymUserClassStatus != "1") {
                                            } else {
                                              updateSession("1", sessionId);

                                              setState(() {
                                                gym_session_status = "1";
                                              });
                                            }
                                          },
                                          child: Container(
                                              width: 115,
                                              decoration: BoxDecoration(
                                                  border: gym_session_status ==
                                                          "1"
                                                      ? Border.all(
                                                          color: Colors.grey)
                                                      : Border.all(
                                                          color: Colors
                                                              .transparent),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: gym_session_status !=
                                                          "1" // gym session is not yet done by trainer

                                                      ? Color.fromARGB(
                                                          199, 167, 10, 180)
                                                      : Colors.transparent),
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                  right: 18,
                                                  left: 18),
                                              child: Text(
                                                  textAlign: TextAlign.center,
                                                  gym_session_status == "1"
                                                      ? "Done"
                                                      : gymUserClassStatus ==
                                                              "1"
                                                          ? "Mark as Done"
                                                          : "User not yet accepted",
                                                  style: TextStyle(
                                                      color:
                                                          gym_session_status !=
                                                                  "1"
                                                              ? Colors.white
                                                              : Colors.grey))),
                                        ),
                                      )
                                    ]));
                          });
                    }))));
  }
}
