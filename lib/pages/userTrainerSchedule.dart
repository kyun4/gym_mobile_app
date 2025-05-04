import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/classes/GymExercises.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';

import 'package:fitup/pages/UserMainMenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserTrainerSchedule extends StatefulWidget {
  const UserTrainerSchedule({super.key});

  @override
  State<UserTrainerSchedule> createState() => _userTrainerScheduleState();
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

String convertMilitaryToAMPM(String time24) {
  final dateTime = DateFormat("HH:mm").parse(time24);
  final formattedTime = DateFormat("h:mm a").format(dateTime);
  return formattedTime;
} // convertMilitaryTimeToAMPM

class _userTrainerScheduleState extends State<UserTrainerSchedule> {
  String? firebaseUID;
  String? trainerId;
  List<GymSessionClass> listGymSessionsData = [];
  List<GymUserSessionClass> listGymUserSessionsData = [];
  List<Users> listUsersData = [];
  String? fullname;
  String? classTitle;
  String? trainerName;
  String? profileImageUrl;
  int dateIndexSelected = 0;
  int weekAddIndexSelected = 0;

  List<String> daysArray = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getSharedPreferencesValues();
  }

  void getGymSessionData() async {
    List<GymSessionClass> gymSessionClassList = [];
    gymSessionClassList = await getGymSessions(trainerId ?? "");
    setState(() {
      listGymSessionsData = gymSessionClassList;
    });
  } // getGymSessionData

  Future<List<GymSessionClass>> getGymSessions(String trainerID) async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<GymSessionClass> listGymSessions = [];
    String url = dbUrl + "gym_sessions.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        if (trainerID == json['trainer_id']) {
          listGymSessions.add(GymSessionClass(
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
    } catch (error) {
      throw error;
    }

    return listGymSessions;
  } // getGymSessions

  void getSharedPreferencesValues() async {
    String? trainerIdSelected = await getSession("trainerFirebaseUid");
    String? classTitleValue = await getSession("class_name");
    String? trainerNameValue = await getSession("trainer_name");
    setState(() {
      trainerId = trainerIdSelected;
      classTitle = classTitleValue;
      trainerName = trainerNameValue;
    });
    getGymSessionData();
  } // getSharedPreferencesValues

  FocusNode focusNodeDateStart = new FocusNode();

  Stream<List<GymExercises>> getExercises() {
    final List<GymExercises> listExercises = [];

    final databaseRef = FirebaseDatabase.instance.ref('exercises');

    return databaseRef.onValue.map((event) {
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((id, json) {
        listExercises.add(GymExercises(
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

      return listExercises;
    });
  } // getExercises

  @override
  Widget build(BuildContext context) {
    List<String> getCurrentDaysInWeek(int addWeek) {
      List<String> weekDates = [];

      int daysToAdd = addWeek * 7;

      DateTime now = DateTime.now().add(Duration(days: daysToAdd));

      int currentWeekDay = now.weekday;
      DateTime sunday = now.subtract(Duration(days: currentWeekDay % 7));

      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        String formatted = DateFormat('MMM, EEE d').format(day);
        weekDates.add(formatted);
      }

      return weekDates;
    } // getCurrentDaysInWeek

    String formatTime(String inputTime) {
      String formatTimeString = "";

      int timeHr = int.parse(inputTime.split(":")[0]);
      int timeMin = int.parse(inputTime.split(":")[1]);

      String timeHour = "";
      String timeMinutes = "";
      String ampm = "";

      timeHour = timeHr > 12 ? (timeHr - 12).toString() : timeHr.toString();
      timeMinutes =
          timeMin < 10 ? "0" + timeMin.toString() : timeMin.toString();
      ampm = timeHr >= 12 ? "pm" : "am";

      formatTimeString = timeHour + ":" + timeMinutes + "" + ampm;
      return formatTimeString;
    }

    List<String> getCurrentDaysInWeekIndex(int addWeek) {
      List<String> weekDates = [];

      int daysToAdd = addWeek * 7;

      DateTime now = DateTime.now().add(Duration(days: daysToAdd));

      int currentWeekDay = now.weekday;
      DateTime sunday = now.subtract(Duration(days: currentWeekDay % 7));

      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        String formatted = DateFormat('EEE d').format(day);
        weekDates.add(formatted);
      }

      return weekDates;
    } // getCurrentDaysInWeek

    List<String> getCurrentDatesInWeek(int addWeek) {
      List<String> weekDates = [];

      int daysToAdd = addWeek * 7;

      DateTime now = DateTime.now().add(Duration(days: daysToAdd));

      int currentWeekDay = now.weekday;
      DateTime sunday = now.subtract(Duration(days: currentWeekDay % 7));

      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        String formatted = DateFormat('yyyy-MM-dd').format(day);
        weekDates.add(formatted);
      }

      return weekDates;
    } // getCurrentDatesInWeek

    List<String> getCurrentDate(int day) {
      List<String> weekDates = [];
      int weekEquivalent = 0;

      weekEquivalent = day * 7;

      DateTime now = DateTime.now();

      int currentWeekDay = now.add(Duration(days: weekEquivalent)).weekday;
      DateTime sunday = now.subtract(Duration(days: currentWeekDay % 7));

      for (int i = 0; i < 7; i++) {
        DateTime day = sunday.add(Duration(days: i));
        String formatted = DateFormat('yyyy-MM-dd').format(day);
        weekDates.add(formatted);
      }

      return weekDates;
    }

    Stream<List<GymTrainerClasses>> getClasses(String trainerId) {
      final List<GymTrainerClasses> listTrainerClasses = [];

      final databaseRef = FirebaseDatabase.instance.ref('gym_trainer_classes');

      return databaseRef.onValue.map((event) {
        final extractedData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        extractedData.forEach((id, json) {
          if (trainerId == json['firebase_uid']) {
            listTrainerClasses.add(GymTrainerClasses(
                gym_trainer_class_id: json['gym_trainer_class_id'] ?? "",
                training_category_id: json['training_category_id'] ?? "",
                class_name: json['class_name'] ?? "",
                class_description: json['class_description'] ?? "",
                price_per_day: json["price_per_day"],
                cover_photo_url: json['cover_photo_url'],
                best_for: json['best_for'] ?? "",
                exercise_id: json['exercise_id'] ?? "",
                date_start: json['date_start'] ?? "",
                date_end: json['date_end'],
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
          }
        });

        listTrainerClasses.sort((a, b) => DateTime.parse(b.date_start)
            .compareTo(DateTime.parse(a.date_start)));

        return listTrainerClasses;
      });
    } // getClasses

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                                selectedInitIndex: 1, subSelectedInitIndex: 26);
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
                          margin: const EdgeInsets.only(
                            left: 10,
                          ),
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, left: 5, right: 20),
                          child: Row(children: [
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    weekAddIndexSelected -= 1;
                                  });
                                },
                                child: Container(
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3)),
                                    child: Text("<",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54)))),
                            SizedBox(width: 10),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    weekAddIndexSelected += 1;
                                  });
                                },
                                child: Container(
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3)),
                                    child: Text(">",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54))))
                          ])),
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color.fromARGB(199, 116, 10, 180)),
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.share,
                                color: Colors.white, size: 22),
                          ))
                    ])),
            Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        getCurrentDaysInWeek(weekAddIndexSelected).length,
                    itemBuilder: (context, ndx) {
                      final dataValue =
                          getCurrentDaysInWeek(weekAddIndexSelected)[ndx];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            dateIndexSelected = ndx;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(
                                top: 3.5, bottom: 1.5, left: 12, right: 12),
                            margin: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: dateIndexSelected == ndx
                                            ? Colors.black87
                                            : Colors.transparent,
                                        width: 2.0))),
                            child: Text(dataValue)),
                      );
                    })),
            Container(
              height: MediaQuery.of(context).size.height - 300,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: getClasses(trainerId ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("No Session Classes Added"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          String classId =
                              snapshot.data![index].gym_trainer_class_id;
                          String title = snapshot.data![index].class_name;
                          String class_desc =
                              snapshot.data![index].class_description;
                          String duration =
                              snapshot.data![index].duration_in_mins;
                          String timeRange =
                              snapshot.data![index].schedule_times;
                          String datesAvailable =
                              snapshot.data![index].scheduled_days;
                          String dateStart = snapshot.data![index].date_start;
                          String dateEnd = snapshot.data![index].date_end;
                          String pricePerDay =
                              snapshot.data![index].price_per_day;
                          String sessionSetup =
                              snapshot.data![index].session_setup;

                          String dateNowSelected = getCurrentDatesInWeek(
                              weekAddIndexSelected)[dateIndexSelected];

                          String isActive = snapshot.data![index].is_active;

                          bool isDisplay = false;
                          String timeStartValue = "";
                          String timeEndValue = "";

                          listGymSessionsData.forEach((data) {
                            String dateSessionSchedule = data.for_date_schedule;

                            if (dateNowSelected == dateSessionSchedule) {
                              isDisplay = true;

                              String timeStartRaw =
                                  data.for_time_range_schedule.split("-")[0];
                              String timeEndRaw =
                                  data.for_time_range_schedule.split("-")[1];

                              timeStartValue = formatTime(timeStartRaw);
                              timeEndValue = formatTime(timeEndRaw);
                            }
                          });

                          return Visibility(
                            visible: isDisplay,
                            child: GestureDetector(
                              onTap: () {
                                setSession("class_id",
                                    snapshot.data![index].gym_trainer_class_id);
                                setSession("exerciseId",
                                    snapshot.data![index].exercise_id);
                                setSession("class_image_url",
                                    snapshot.data![index].cover_photo_url);
                                setSession("training_venue",
                                    snapshot.data![index].session_setup);
                                setSession(
                                    "level", snapshot.data![index].level);
                                setSession(
                                    "best_for", snapshot.data![index].best_for);
                                setSession("class_name", title);
                                setSession("class_description", class_desc);

                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const UserMainMenu(
                                      selectedInitIndex: 1,
                                      subSelectedInitIndex: 29);
                                }));
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 1))),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  timeStartValue +
                                                      " - " +
                                                      timeEndValue,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              Text("${duration} min")
                                            ]),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text("$title ($sessionSetup)",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              Text("$pricePerDay Php/day",
                                                  style: TextStyle(
                                                      color: Colors.grey))
                                            ]),
                                      ])),
                            ),
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
