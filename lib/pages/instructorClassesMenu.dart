import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/classes/GymExercises.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
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

class InstructorClassesMenu extends StatefulWidget {
  const InstructorClassesMenu({super.key});

  @override
  State<InstructorClassesMenu> createState() => _instructorClassesMenuState();
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

class _instructorClassesMenuState extends State<InstructorClassesMenu> {
  String? firebaseUID;
  List<Users> listUsersData = [];
  List<GymSessionClass> listGymSessionsData = [];
  List<GymUserSessionClass> listGymUserSessionsData = [];
  String? fullname;
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

  FocusNode focusNodeDateStart = new FocusNode();

  void initState() {
    super.initState();
    getGymSessionData();
  }

  void getGymSessionData() async {
    List<GymSessionClass> gymSessionClassList = [];
    gymSessionClassList = await getGymSessions();
    setState(() {
      listGymSessionsData = gymSessionClassList;
    });
  } // getGymSessionData

  Future<List<GymSessionClass>> getGymSessions() async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<GymSessionClass> listGymSessions = [];
    String url = dbUrl + "gym_sessions.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {}

      extractedData.forEach((key, json) {
        if (firebaseUID == json['trainer_id']) {
          listGymSessions.add(GymSessionClass(
              gym_session_id: json['gym_session_id'],
              gym_class_id: json['gym_class_id'],
              for_date_schedule: json['for_date_schedule'],
              for_day_schedule: json['for_day_schedule'],
              for_time_range_schedule: json['for_time_range_schedule'],
              price_per_day: json['price_per_day'],
              trainer_id: json['trainer_id'],
              date_time_actual_finished:
                  json['date_time_actual_finished'] ?? "",
              status: json['status']));
        }
      });
    } catch (error) {
      throw error;
    }

    return listGymSessions;
  } // getGymSessions

  void addClass(
      String adsPhotoUrl,
      String className,
      String classDescription,
      String bestFor,
      String price_per_day,
      String exerciseId,
      String training_category_id,
      String sessionSetup,
      String exerciseLevel,
      String dateStart,
      String dateEnd,
      List<String> timeRanges,
      List<String> dayRanges,
      String durationInMins,
      String classLimit) {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    final uniqueID = new Uuid();
    String dateTimeAdded = DateTime.now().toIso8601String();
    String idValue = uniqueID.v4();
    String url = dbUrl + "gym_trainer_classes/$idValue.json";
    try {
      final response = http.put(Uri.parse(url),
          body: json.encode({
            "gym_trainer_class_id": idValue,
            "training_category_id": training_category_id,
            "class_name": className,
            "class_description": classDescription,
            "price_per_day": price_per_day,
            "cover_photo_url": adsPhotoUrl,
            "best_for": bestFor,
            "exercise_id": exerciseId,
            "date_start": dateStart,
            "date_end": dateEnd,
            "duration_in_mins": durationInMins,
            "firebase_uid": firebaseUID,
            "date_time_added": dateTimeAdded,
            "date_time_last_updated": "",
            "is_active": "1",
            "is_done": "",
            "level": exerciseLevel,
            "schedule_times": timeRanges.join(','),
            "scheduled_days": dayRanges.join(','),
            "session_setup": sessionSetup,
            "users_per_class_limit": classLimit,
            "status": "1"
          }));
    } catch (error) {
      throw error;
    }

    int dateDiff =
        DateTime.parse(dateEnd).difference(DateTime.parse(dateStart)).inDays;

    List<String> dayString = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    String for_date_schedule = "";
    String for_day_schedule = "";
    String for_time_range_schedule = "";

    for (int i = 0; i < dateDiff; i++) {
      String for_date_schedule = "";
      String for_day_schedule = "";
      String for_time_range_schedule = "";

      var dateScheduled = DateTime.parse(dateStart).add(Duration(days: i));
      var formatter = DateFormat("yyyy-MM-dd");
      String for_date_scheduled_formatted = formatter.format(dateScheduled);

      for_date_schedule = for_date_scheduled_formatted.toString();
      int day_ndx = DateTime.parse(dateStart).add(Duration(days: i)).weekday;

      for_day_schedule = dayString[day_ndx - 1];

      bool dayMatches = false;

      int ndx = 0;

      dayRanges.forEach((key) {
        if (for_day_schedule.toLowerCase() == key.toString().toLowerCase()) {
          for_time_range_schedule = timeRanges[ndx];
          dayMatches = true;
        }
        ndx += 1;
      });

      if (dayMatches == true) {
        addGymSession(price_per_day, idValue, for_date_schedule,
            for_day_schedule, for_time_range_schedule);
      }
    }
  } // addClass

  void addGymSession(
      String price_per_day,
      String gym_class_id,
      String for_date_schedule,
      String for_day_schedule,
      String for_time_range_schedule) {
    final uniqueID = new Uuid();
    String idValue = uniqueID.v4();

    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    String url = dbUrl + "gym_sessions/$idValue.json";

    try {
      final response = http.put(Uri.parse(url),
          body: json.encode({
            "gym_session_id": idValue,
            "gym_class_id": gym_class_id,
            "for_date_schedule": for_date_schedule,
            "for_day_schedule": for_day_schedule,
            "for_time_range_schedule": for_time_range_schedule,
            "price_per_day": price_per_day,
            "trainer_id": firebaseUID,
            "date_time_actual_finished": "",
            "status": "0"
          }));
    } catch (error) {
      throw error;
    }
  } // addGymSession

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

    Stream<List<GymTrainerClasses>> getClasses() {
      String fUID = FirebaseAuth.instance.currentUser!.uid.toString();
      final List<GymTrainerClasses> listTrainerClasses = [];

      final databaseRef = FirebaseDatabase.instance.ref('gym_trainer_classes');

      return databaseRef.onValue.map((event) {
        final extractedData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        extractedData.forEach((id, json) {
          if (fUID == json['firebase_uid']) {
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
        appBar: AppBar(
            leading: Icon(Icons.class_outlined),
            actions: [
              Container(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 5, right: 20),
                  child: Row(children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            weekAddIndexSelected -= 1;
                          });
                        },
                        child: Text("Previous")),
                    SizedBox(width: 10),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            weekAddIndexSelected += 1;
                          });
                        },
                        child: Text("Next"))
                  ]))
            ],
            title:
                Text("Classes", style: TextStyle(fontWeight: FontWeight.bold))),
        body: SafeArea(
          child: Column(
            children: [
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
                height: MediaQuery.of(context).size.height - 200,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                    stream: getClasses(),
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
                              String dateSessionSchedule =
                                  data.for_date_schedule;

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
                            );
                          });
                    }),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _addClassDialog(context), child: Icon(Icons.add)));
  }

  void _addClassDialog(BuildContext context) {
    XFile? _image;
    String? _downloadURL;
    double _progress = 0.0; //

    final classNameController = TextEditingController();
    final classDescriptionController = TextEditingController();
    final BestForController = TextEditingController();
    final classSizeController = TextEditingController();
    final classDurationController = TextEditingController();
    final classPricePerDayController = TextEditingController();

    String? exerciseId,
        trainingCategoryId,
        sessionSetup,
        exerciseLevel,
        adsCoverPhoto,
        classLimit;

    List<String> selectedTimes = [];
    List<String> selectedDays = [];
    List<String> levels = ["Beginner", "Intermediate", "PRO"];
    int? selectedExerciseIndex;
    int durationInMinsValue = 0;
    Stream streamExercises = getExercises();
    bool saveButtonVisible = false;

    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;
    DateTime? _selectedDateStart;
    DateTime? _selectedDateEnd;
    TimeOfDay? _selectedTimeStartMonday, _selectedTimeEndMonday;
    TimeOfDay? _selectedTimeStartTuesday, _selectedTimeEndTuesday;
    TimeOfDay? _selectedTimeStartWednesday, _selectedTimeEndWednesday;
    TimeOfDay? _selectedTimeStartThursday, _selectedTimeEndThursday;
    TimeOfDay? _selectedTimeStartFriday, _selectedTimeEndFriday;
    TimeOfDay? _selectedTimeStartSaturday, _selectedTimeEndSaturday;
    TimeOfDay? _selectedTimeStartSunday, _selectedTimeEndSunday;

    TimeOfDay addMinutesToTime(TimeOfDay time, int minutesToAdd) {
      final dateNow = DateTime.now();
      final dt = DateTime(
          dateNow.year, dateNow.month, dateNow.day, time.hour, time.minute);
      final newTime = dt.add(Duration(minutes: minutesToAdd));
      return TimeOfDay(hour: newTime.hour, minute: newTime.minute);
    } // addMinutesToTime

    Future<DateTime?> selectDate(context) async {
      DateTime? dateFinal;
      DateTime? _date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101));

      if (_date != null && _date != _selectedDate) {
        // _selectedDateStart = _dateStart;
        dateFinal = _date;
      }

      return dateFinal;
    } // selectDate

    Future<TimeOfDay?> selectTime(context) async {
      TimeOfDay? _selectedTimeFinal =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (_selectedTime != null || _selectedTime != _selectedTimeFinal) {
        _selectedTime = _selectedTimeFinal;
      }

      return _selectedTime;
    } // selectTime

    void initState() {
      super.initState();
      streamExercises.asBroadcastStream();
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            bool HasSelectedScheduleDay() {
              bool hasTimeRange = false;

              selectedTimes.clear();
              selectedDays.clear();

              if (_selectedTimeStartSunday != null ||
                  _selectedTimeStartMonday != null ||
                  _selectedTimeStartTuesday != null ||
                  _selectedTimeStartWednesday != null ||
                  _selectedTimeStartThursday != null ||
                  _selectedTimeStartFriday != null ||
                  _selectedTimeStartSaturday != null) {
                if (_selectedTimeStartSunday != null) {
                  selectedDays.add("Sunday");
                  String timeRangeStart =
                      _selectedTimeStartSunday!.hour.toString() +
                          ":" +
                          _selectedTimeStartSunday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndSunday!.hour.toString() +
                          ":" +
                          _selectedTimeEndSunday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartMonday != null) {
                  selectedDays.add("Monday");
                  String timeRangeStart =
                      _selectedTimeStartMonday!.hour.toString() +
                          ":" +
                          _selectedTimeStartMonday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndMonday!.hour.toString() +
                          ":" +
                          _selectedTimeEndMonday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartTuesday != null) {
                  selectedDays.add("Tuesday");
                  String timeRangeStart =
                      _selectedTimeStartTuesday!.hour.toString() +
                          ":" +
                          _selectedTimeStartTuesday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndTuesday!.hour.toString() +
                          ":" +
                          _selectedTimeEndTuesday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartWednesday != null) {
                  selectedDays.add("Wednesday");
                  String timeRangeStart =
                      _selectedTimeStartWednesday!.hour.toString() +
                          ":" +
                          _selectedTimeStartWednesday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndWednesday!.hour.toString() +
                          ":" +
                          _selectedTimeEndWednesday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartThursday != null) {
                  selectedDays.add("Thursday");
                  String timeRangeStart =
                      _selectedTimeStartThursday!.hour.toString() +
                          ":" +
                          _selectedTimeStartThursday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndThursday!.hour.toString() +
                          ":" +
                          _selectedTimeEndThursday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartFriday != null) {
                  selectedDays.add("Friday");
                  String timeRangeStart =
                      _selectedTimeStartFriday!.hour.toString() +
                          ":" +
                          _selectedTimeStartFriday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndFriday!.hour.toString() +
                          ":" +
                          _selectedTimeEndFriday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                if (_selectedTimeStartSaturday != null) {
                  selectedDays.add("Saturday");
                  String timeRangeStart =
                      _selectedTimeStartSaturday!.hour.toString() +
                          ":" +
                          _selectedTimeStartSaturday!.minute.toString();
                  String timeRangeEnd =
                      _selectedTimeEndSaturday!.hour.toString() +
                          ":" +
                          _selectedTimeEndSaturday!.minute.toString();
                  String timeRange = timeRangeStart + "-" + timeRangeEnd;
                  selectedTimes.add(timeRange);
                }

                hasTimeRange = true;
              } else {
                hasTimeRange = false;
              }

              return hasTimeRange;
            }

            Future<XFile?> _pickImage() async {
              final ImagePicker _picker = ImagePicker();
              XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              return image;
            }

            Future<String?> _uploadImage(XFile image) async {
              String firebaseUID =
                  FirebaseAuth.instance.currentUser!.uid.toString();
              try {
                FirebaseStorage storage = FirebaseStorage.instance;

                final uniqueId = new Uuid();
                String uniqueIdValue = uniqueId.v4();
                String profileImageFileName =
                    firebaseUID + "_" + uniqueIdValue + "";

                Reference ref = storage.ref().child(
                    "trainer_portfolio_images/" +
                        profileImageFileName +
                        ".jpg");
                TaskSnapshot uploadTask = await ref.putFile(File(image.path));

                UploadTask uploadTasking = ref.putFile(File(image.path));

                // Listen to upload progress
                uploadTasking.snapshotEvents.listen((TaskSnapshot snapshot) {
                  double progress =
                      snapshot.bytesTransferred / snapshot.totalBytes;
                  setState(() {
                    _progress = progress; // Update the progress value
                  });
                });

                String downloadURL = await uploadTask.ref.getDownloadURL();

                return downloadURL;
              } catch (e) {
                print('Error uploading image: $e');
                return null;
              }
            } // _uploadImage

            Future<void> _pickAndUploadImage() async {
              // Pick an image
              XFile? image = await _pickImage();
              if (image != null) {
                // Upload the image and get the download URL
                String? downloadURL = await _uploadImage(image);
                if (downloadURL != null) {
                  setState(() {
                    _image = image;
                    adsCoverPhoto = downloadURL;
                    _progress = 0.0;
                  });
                }
              }
            } // _pickAndUploadImage

            void classFormValidation() {
              if (classNameController.text.toString() != "" &&
                  classDescriptionController.text.toString() != "" &&
                  classSizeController.text.toString() != "" &&
                  classDurationController.text.toString() != "" &&
                  classPricePerDayController.text.toString() != "" &&
                  BestForController.text.toString() != "" &&
                  exerciseId != null &&
                  exerciseLevel != null &&
                  _selectedDateStart != null &&
                  _selectedDateEnd != null &&
                  sessionSetup != null &&
                  HasSelectedScheduleDay() == true) {
                saveButtonVisible = true;
              } else {
                saveButtonVisible = false;
              }
            } // classFormValidation

            void durationListener() {
              if (classDurationController.text != null ||
                  classDurationController.text.isNotEmpty ||
                  classDurationController.text.toString().trim() != "") {
                setState(() {
                  durationInMinsValue =
                      int.parse(classDurationController.text.toString());
                });
              } else {
                setState(() {
                  durationInMinsValue = 0;
                });
              }

              classFormValidation();
            } // durationListener

            classDurationController.addListener(durationListener);
            classNameController.addListener(classFormValidation);
            BestForController.addListener(classFormValidation);
            classSizeController.addListener(classFormValidation);
            classDescriptionController.addListener(classFormValidation);

            return AlertDialog(
              title: Text('Add Class',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Container(
                width: MediaQuery.of(context).size.width - 100,
                child: ListView(
                  children: [
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 250,
                      decoration:
                          BoxDecoration(color: Colors.grey.withOpacity(0.05)),
                      child: Center(
                        child: Image.network(adsCoverPhoto ?? "",
                            height: 200,
                            width: MediaQuery.of(context).size.width - 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, StackTrace) {
                          return GestureDetector(
                            onTap: () {
                              _pickAndUploadImage();
                            },
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                  Icon(Icons.upload_file,
                                      color: Colors.black54, size: 75),
                                  SizedBox(height: 5),
                                  Text("Click to Upload Session Photo",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54))
                                ])),
                          );
                        }, loadingBuilder: (context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null));
                          }
                        }),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text("Select Exercise ",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 150,
                          child: StreamBuilder(
                              stream: streamExercises,
                              builder: (context, snapshot) {
                                final data = snapshot!.data;

                                if (snapshot.hasError) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedExerciseIndex = index;
                                            exerciseId =
                                                data[index].exercise_id;
                                          });

                                          classFormValidation();
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    color: selectedExerciseIndex == index
                                                        ? Color.fromARGB(
                                                            199, 167, 10, 180)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                margin: const EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: SvgPicture.asset(
                                                    "assets/svg/" +
                                                        data![index].icon,
                                                    height: 80,
                                                    color: selectedExerciseIndex == index
                                                        ? Colors.white
                                                        : Color.fromARGB(
                                                            199, 167, 10, 180))),
                                            SizedBox(height: 10),
                                            Text(data![index].exercise_name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        selectedExerciseIndex ==
                                                                index
                                                            ? Color.fromARGB(
                                                                199,
                                                                167,
                                                                10,
                                                                180)
                                                            : Colors.grey)),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    });
                              })),
                    ),
                    TextField(
                      controller: classNameController,
                      decoration: InputDecoration(
                          hintText: 'Class Name',
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(199, 167, 10, 180))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.white))),
                    ),
                    SizedBox(height: 10),
                    TextField(
                        controller: classDescriptionController,
                        decoration: InputDecoration(
                            hintText: 'Description',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)))),
                    SizedBox(height: 10),
                    TextField(
                        controller: BestForController,
                        decoration: InputDecoration(
                            hintText: 'Best For',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)))),
                    SizedBox(height: 10),
                    TextField(
                        controller: classSizeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: 'Class Size (Max no. of trainees)',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)))),
                    SizedBox(height: 10),
                    TextField(
                        controller: classDurationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: 'Duration in Minutes',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)))),
                    SizedBox(height: 10),
                    TextField(
                        controller: classPricePerDayController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: 'Price per Day',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(199, 167, 10, 180))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white)))),
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () async {
                          DateTime? dateStart = await selectDate(context);

                          setState(() {
                            _selectedDateStart = dateStart;
                          });

                          classFormValidation();
                        },
                        child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date Start"),
                                  Text(_selectedDateStart == null
                                      ? "MM-DD-YYYY"
                                      : _selectedDateStart
                                          .toString()
                                          .split(' ')[0])
                                ]))),
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () async {
                          DateTime? dateEnd = await selectDate(context);

                          setState(() {
                            _selectedDateEnd = dateEnd;
                          });

                          classFormValidation();
                        },
                        child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date End"),
                                  Text(_selectedDateEnd == null
                                      ? "MM-DD-YYYY"
                                      : _selectedDateEnd
                                          .toString()
                                          .split(' ')[0])
                                ]))),
                    SizedBox(height: 20),
                    Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 15, top: 10, bottom: 10),
                              child: Text("Training Setup: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sessionSetup = "onsite";
                              });
                              classFormValidation();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: sessionSetup == "onsite"
                                        ? Color.fromARGB(199, 167, 10, 180)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: sessionSetup == "onsite"
                                            ? Color.fromARGB(199, 167, 10, 180)
                                                .withOpacity(0.2)
                                            : Color.fromARGB(
                                                199, 167, 10, 180))),
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 12.5,
                                    top: 7.5,
                                    bottom: 7.5),
                                child: Text("Onsite",
                                    style: TextStyle(
                                        color: sessionSetup == "onsite"
                                            ? Colors.white
                                            : Color.fromARGB(
                                                199, 167, 10, 167)))),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sessionSetup = "offsite";
                              });
                              classFormValidation();
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: sessionSetup == "offsite"
                                        ? Color.fromARGB(199, 167, 10, 180)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: sessionSetup == "offsite"
                                            ? Color.fromARGB(199, 167, 10, 180)
                                                .withOpacity(0.2)
                                            : Color.fromARGB(
                                                199, 167, 10, 180))),
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 12.5,
                                    top: 7.5,
                                    bottom: 7.5),
                                child: Text("Offsite",
                                    style: TextStyle(
                                        color: sessionSetup == "offsite"
                                            ? Colors.white
                                            : Color.fromARGB(
                                                199, 167, 10, 167)))),
                          )
                        ])),
                    SizedBox(height: 20),
                    Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 15, top: 10, bottom: 10),
                                  child: Text("Level: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width - 150,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: levels.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            exerciseLevel = levels[index];
                                          });
                                          classFormValidation();
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color:
                                                    exerciseLevel == levels[index]
                                                        ? Color.fromARGB(
                                                            199, 167, 10, 180)
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: exerciseLevel ==
                                                            levels[index]
                                                        ? Color.fromARGB(199, 167, 10, 180)
                                                            .withOpacity(0.2)
                                                        : Color.fromARGB(
                                                            199, 167, 10, 180))),
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 12.5,
                                                top: 7.5,
                                                bottom: 7.5),
                                            child: Text(levels[index], style: TextStyle(color: exerciseLevel == levels[index] ? Colors.white : Color.fromARGB(199, 167, 10, 167)))),
                                      );
                                    }),
                              )
                            ])),
                    Container(
                        child: Column(children: [
                      Visibility(
                        visible: durationInMinsValue > 0 ? true : false,
                        child: Column(children: [
                          Container(
                              margin: const EdgeInsets.only(top: 25),
                              child: Text("Selected Days",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500))),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartSunday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Sunday",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartSunday == null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? sundayStartTime =
                                              await selectTime(context);

                                          TimeOfDay sundayEndTime =
                                              addMinutesToTime(
                                                  sundayStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartSunday =
                                                sundayStartTime;
                                            _selectedTimeEndSunday =
                                                sundayEndTime;
                                          });

                                          classFormValidation();
                                        },
                                        child: _selectedTimeStartSunday != null
                                            ? Text(
                                                _selectedTimeStartSunday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartSunday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSunday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSunday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartSunday == null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndSunday != null
                                            ? Text(
                                                _selectedTimeEndSunday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndSunday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSunday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSunday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartMonday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Monday",
                                            style: TextStyle(
                                                color:
                                                    _selectedTimeStartMonday ==
                                                            null
                                                        ? Colors.black45
                                                        : Colors.white)),
                                        SizedBox(width: 50),
                                        GestureDetector(
                                            onTap: () async {
                                              TimeOfDay? mondayStartTime =
                                                  await selectTime(context);

                                              TimeOfDay mondayEndTime =
                                                  addMinutesToTime(
                                                      mondayStartTime ??
                                                          TimeOfDay.now(),
                                                      int.parse(
                                                          classDurationController
                                                              .text
                                                              .toString()));

                                              setState(() {
                                                _selectedTimeStartMonday =
                                                    mondayStartTime;
                                                _selectedTimeEndMonday =
                                                    mondayEndTime;
                                              });

                                              classFormValidation();
                                            },
                                            child: _selectedTimeStartMonday !=
                                                    null
                                                ? Text(
                                                    _selectedTimeStartMonday!
                                                            .hour
                                                            .toString() +
                                                        ":" +
                                                        _selectedTimeStartMonday!
                                                            .minute
                                                            .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            _selectedTimeStartMonday ==
                                                                    null
                                                                ? Colors.black45
                                                                : Colors.white))
                                                : Text("HH:MM",
                                                    style: TextStyle(
                                                        color:
                                                            _selectedTimeStartMonday ==
                                                                    null
                                                                ? Colors.black45
                                                                : Colors
                                                                    .white))),
                                        Text("to",
                                            style: TextStyle(
                                                color:
                                                    _selectedTimeStartMonday ==
                                                            null
                                                        ? Colors.black45
                                                        : Colors.white)),
                                        GestureDetector(
                                            onTap: () {},
                                            child: _selectedTimeEndMonday !=
                                                    null
                                                ? Text(
                                                    _selectedTimeEndMonday!.hour
                                                            .toString() +
                                                        ":" +
                                                        _selectedTimeEndMonday!
                                                            .minute
                                                            .toString(),
                                                    style: TextStyle(
                                                        color:
                                                            _selectedTimeStartMonday ==
                                                                    null
                                                                ? Colors.black45
                                                                : Colors.white))
                                                : Text("HH:MM",
                                                    style: TextStyle(
                                                        color:
                                                            _selectedTimeStartMonday ==
                                                                    null
                                                                ? Colors.black45
                                                                : Colors
                                                                    .white)))
                                      ]))),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartTuesday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Tuesday",
                                        style: TextStyle(
                                            color: _selectedTimeStartTuesday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? tuesdayStartTime =
                                              await selectTime(context);

                                          TimeOfDay tuesdayEndTime =
                                              addMinutesToTime(
                                                  tuesdayStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartTuesday =
                                                tuesdayStartTime;
                                            _selectedTimeEndTuesday =
                                                tuesdayEndTime;
                                          });

                                          classFormValidation();
                                        },
                                        child: _selectedTimeStartTuesday != null
                                            ? Text(
                                                _selectedTimeStartTuesday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartTuesday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartTuesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartTuesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color: _selectedTimeStartTuesday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndTuesday != null
                                            ? Text(
                                                _selectedTimeEndTuesday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndTuesday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartTuesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartTuesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartWednesday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Wednesday",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartWednesday ==
                                                        null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? wedStartTime =
                                              await selectTime(context);

                                          TimeOfDay wedEndTime =
                                              addMinutesToTime(
                                                  wedStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartWednesday =
                                                wedStartTime;
                                            _selectedTimeEndWednesday =
                                                wedEndTime;
                                          });

                                          classFormValidation();
                                        },
                                        child: _selectedTimeStartWednesday !=
                                                null
                                            ? Text(
                                                _selectedTimeStartWednesday!
                                                        .hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartWednesday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartWednesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartWednesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartWednesday ==
                                                        null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndWednesday != null
                                            ? Text(
                                                _selectedTimeEndWednesday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndWednesday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartWednesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartWednesday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartThursday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Thursday",
                                        style: TextStyle(
                                            color: _selectedTimeStartThursday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? thursdayStartTime =
                                              await selectTime(context);

                                          TimeOfDay thursdayEndTime =
                                              addMinutesToTime(
                                                  thursdayStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartThursday =
                                                thursdayStartTime;
                                            _selectedTimeEndThursday =
                                                thursdayEndTime;
                                          });

                                          classFormValidation();
                                        },
                                        child: _selectedTimeStartThursday !=
                                                null
                                            ? Text(
                                                _selectedTimeStartThursday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartThursday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartThursday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartThursday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color: _selectedTimeStartThursday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndThursday != null
                                            ? Text(
                                                _selectedTimeEndThursday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndThursday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartThursday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartThursday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartFriday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Friday",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartFriday == null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? fridayStartTime =
                                              await selectTime(context);

                                          TimeOfDay fridayEndTime =
                                              addMinutesToTime(
                                                  fridayStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartFriday =
                                                fridayStartTime;
                                            _selectedTimeEndFriday =
                                                fridayEndTime;
                                          });
                                        },
                                        child: _selectedTimeStartFriday != null
                                            ? Text(
                                                _selectedTimeStartFriday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartFriday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartFriday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartFriday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color:
                                                _selectedTimeStartFriday == null
                                                    ? Colors.black45
                                                    : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndFriday != null
                                            ? Text(
                                                _selectedTimeEndFriday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndFriday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartFriday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartFriday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedTimeStartSaturday == null
                                      ? Colors.white
                                      : Color.fromARGB(199, 167, 10, 180)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Saturday",
                                        style: TextStyle(
                                            color: _selectedTimeStartSaturday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    SizedBox(width: 50),
                                    GestureDetector(
                                        onTap: () async {
                                          TimeOfDay? saturdayStartTime =
                                              await selectTime(context);

                                          TimeOfDay saturdayEndTime =
                                              addMinutesToTime(
                                                  saturdayStartTime ??
                                                      TimeOfDay.now(),
                                                  int.parse(
                                                      classDurationController
                                                          .text
                                                          .toString()));

                                          setState(() {
                                            _selectedTimeStartSaturday =
                                                saturdayStartTime;
                                            _selectedTimeEndSaturday =
                                                saturdayEndTime;
                                          });

                                          classFormValidation();
                                        },
                                        child: _selectedTimeStartSaturday !=
                                                null
                                            ? Text(
                                                _selectedTimeStartSaturday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeStartSaturday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSaturday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSaturday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))),
                                    Text("to",
                                        style: TextStyle(
                                            color: _selectedTimeStartSaturday ==
                                                    null
                                                ? Colors.black45
                                                : Colors.white)),
                                    GestureDetector(
                                        onTap: () {},
                                        child: _selectedTimeEndSaturday != null
                                            ? Text(
                                                _selectedTimeEndSaturday!.hour
                                                        .toString() +
                                                    ":" +
                                                    _selectedTimeEndSaturday!
                                                        .minute
                                                        .toString(),
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSaturday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white))
                                            : Text("HH:MM",
                                                style: TextStyle(
                                                    color:
                                                        _selectedTimeStartSaturday ==
                                                                null
                                                            ? Colors.black45
                                                            : Colors.white)))
                                  ])),
                        ]),
                      )
                    ]))
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    addClass(
                        adsCoverPhoto ?? "",
                        classNameController.text,
                        classDescriptionController.text,
                        BestForController.text,
                        classPricePerDayController.text,
                        exerciseId ?? "",
                        trainingCategoryId ?? "",
                        sessionSetup ?? "",
                        exerciseLevel ?? "",
                        _selectedDateStart.toString().split(' ')[0],
                        _selectedDateEnd.toString().split(' ')[0],
                        selectedTimes,
                        selectedDays,
                        classDurationController.text,
                        classLimit ?? classSizeController.text);
                    Navigator.pop(context);
                  },
                  child: Visibility(
                    visible: saveButtonVisible,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Color.fromARGB(199, 167, 10, 180)),
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  } // _addClassDialog
}
