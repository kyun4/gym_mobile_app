import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/Users.dart';
import 'package:fitup/classes/messages.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymSessionClass.dart';

import 'package:http/http.dart' as http;

import 'package:fitup/pages/clientOrders.dart';
import 'package:fitup/pages/trainerBookingSessions.dart';

import 'package:fitup/pages/instructorSchedule.dart';

import 'package:fitup/pages/userMessages.dart';
import 'package:fitup/pages/userMessageConversation.dart';

import 'package:fitup/pages/instructorClassesMenu.dart';

import 'package:fitup/pages/instructorProfileMenu.dart';
import 'package:fitup/pages/userProfileImage.dart';
import 'package:fitup/pages/EditProfileDetails.dart';
import 'package:fitup/pages/userSettings.dart';

import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

List<Users> usersList = [];

int _subSelectedIndex = 0;

class InstructorMainMenu extends StatefulWidget {
  final int selectedInitIndex;
  final int subSelectedInitIndex;

  const InstructorMainMenu(
      {super.key,
      required this.selectedInitIndex,
      required this.subSelectedInitIndex});

  @override
  State<InstructorMainMenu> createState() => _instructorMainMenuState();
}

TimeOfDay stringToTimeOfDay(String timeString) {
  final parts = timeString.split(":");
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime timeOfDayToDateTime(TimeOfDay tod) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
}

String findNearestTime(List<String> sortedTimes) {
  final now = DateTime.now();
  Duration? shortestDiff;
  String? closestTime;

  for (var timeStr in sortedTimes) {
    final tod = stringToTimeOfDay(timeStr);
    final dt = timeOfDayToDateTime(tod);

    final diff = dt.difference(now);
    final positiveDiff = diff.isNegative ? diff.abs() : diff;

    if (shortestDiff == null || positiveDiff < shortestDiff) {
      shortestDiff = positiveDiff;
      closestTime = timeStr;
    }
  }

  return closestTime ?? '';
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

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  print('User signed out');
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const Splash();
  }));
}

class getUserDetails extends StatelessWidget {
  void initState() async {}

  Future<String> getDataUsers() async {
    String nameDetails = "";

    User? user = FirebaseAuth.instance.currentUser;

    var url = dbUrl + "users.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      String firebaseUid = user != null ? user!.uid : "";

      extractedData.forEach((userId, userData) {
        if (userData['firebase_uid'] == firebaseUid) {
          nameDetails =
              userData['firstname'] + " " + userData['lastname'] + "!";

          usersList.add(Users(
              firebase_uid: userData['firebase_uid'],
              username: userData['username'],
              firstname: userData['firstname'],
              middlename: userData['middlename'],
              lastname: userData['lastname'],
              role: userData['role'],
              ext: userData['ext'],
              email: userData['email'],
              phone: userData['phone'],
              otp: userData['otp'],
              occupation: userData['occupation'],
              title: userData['title'],
              date_time_premium_activated:
                  userData['date_time_premium_activated'],
              date_time_membership: userData['date_time_membership'],
              date_time_registered: userData['date_time_registered'],
              email_verified: userData['email_verified']));
        }
      });
    } catch (error) {
      throw error;
    }

    return nameDetails;
  }

  Widget build(BuildContext Context) {
    return FutureBuilder(
        future: getDataUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.toString(),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18));
          } else {
            return const Text("Trainer");
          }
        });
  }
}

class _instructorMainMenuState extends State<InstructorMainMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    InboxPage(),
    InstructorSchedulingPage(),
    InstructorClassesMenu(),
    InstructorProfilePage()
  ];

  void initState() {
    setState(() {
      _selectedIndex = widget.selectedInitIndex;
      _subSelectedIndex = widget.subSelectedInitIndex;
    });

    super.initState();
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _subSelectedIndex = 0;

      if (_selectedIndex == 1) {
        removeSession("client_request_mode");
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Client List'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined), label: 'Schedule'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.class_outlined), label: 'Classes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.verified_user_outlined),
                  label: 'Your Profile'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemSelected,
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.black38));
  }
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _inboxPageState();
}

class _inboxPageState extends State<InboxPage> {
  final TextEditingController locationAddress = new TextEditingController();
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0) {
      switch (subSelectedIndexLocal) {
        case 7:
          pageCurrent = UserMessageConversation();
        default:
          pageCurrent = Text("Page not found");
      }
    } else {
      pageCurrent = UserMessages();
    }

    return pageCurrent;
  }
} // InboxPage

class InstructorSchedulingPage extends StatefulWidget {
  const InstructorSchedulingPage({super.key});

  @override
  State<InstructorSchedulingPage> createState() =>
      _instructorSchedulingPageState();
}

class _instructorSchedulingPageState extends State<InstructorSchedulingPage> {
  final TextEditingController locationAddress = new TextEditingController();
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 56 &&
        subSelectedIndexLocal <= 70) {
      switch (subSelectedIndexLocal) {
        case 56:
          pageCurrent = const Center(child: Text("Walappapu"));
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = InstructorSchedule();
    }

    return pageCurrent;
  }
} // InstructorSchedulingPage

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  int subSelectedIndexLocal = 0;
  String firebaseUID = "";

  void initState() {
    super.initState();
    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
      firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 10 &&
        subSelectedIndexLocal <= 14) {
      switch (subSelectedIndexLocal) {
        case 10:
          pageCurrent = const UserSettings();
        case 11:
          pageCurrent = const UserProfileImage();
        case 12:
          pageCurrent = const EditProfileDetails();

        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const InstructorProfileMenu();
    }

    return pageCurrent;
  }
} // InstructorProfilePage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPage();
} // DashboardPage

class _DashboardPage extends State<DashboardPage> {
  String? clientRequestNumber = "0";
  String? firebaseUID;
  String? profileImageUrl;
  List<Messages> listClientRequestMessages = [];
  List<UserGymClasses> listGymUserClasses = [];
  List<UserGymClasses> listGymUserClassesTaken = [];
  List<GymUserSessionClass> listGymUserSessionClasses = [];
  List<GymSessionClass> listGymSessionClasses = [];

  int subSelectedIndexLocal = 0;

  String? nextSessionTime;
  String? nextSessionDuration;
  String? nextSessionClients;

  String? janClientNumber;
  String? febClientNumber;
  String? marClientNumber;
  String? aprClientNumber;
  String? mayClientNumber;
  String? junClientNumber;
  String? julClientNumber;
  String? augClientNumber;
  String? sepClientNumber;
  String? octClientNumber;
  String? novClientNumber;
  String? decClientNumber;

  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();

    getClientRequest(firebaseUID ?? "");
    getLatestProfile(firebaseUID ?? "");
    getNextUserSessions(firebaseUID ?? "");

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
      //firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    });
  }

  void getNextUserSessions(String firebaseUID) async {
    List<GymUserSessionClass> listGymUserSessionData =
        await getGymUserSessions(firebaseUID);

    List<GymSessionClass> listGymSessionData =
        await getGymSessions(firebaseUID);

    setState(() {
      listGymUserSessionClasses = listGymUserSessionData;
      listGymSessionClasses = listGymSessionData;
    });

    String dateTimeNowFormatted =
        DateFormat("yyyy-MM-dd").format(DateTime.now());

    List<GymSessionClass> listGymSessionFilter = listGymSessionClasses
        .where((gymUserSession) =>
            gymUserSession.for_date_schedule.toString() == dateTimeNowFormatted)
        .toList();

    List<String> sessionIds = [];
    List<String> timeStamps = [];
    List<String> timeToSort = [];

    (listGymSessionFilter as Map).forEach((key, data) {
      sessionIds.add(data['gym_session_id']);
      timeStamps.add(data['for_time_range_schedule'].split("-")[0]);
    });

    (listGymUserSessionClasses as Map).forEach((key, data) {
      int sessionIDndx = 0;

      for (var sessionID in sessionIds) {
        if (data['gym_session_id'] == sessionID) {
          timeToSort.add(timeStamps[sessionIDndx]);
        }

        sessionIDndx += 1;
      }
    });

    String nearestTime = findNearestTime(timeToSort);

    int sessionNDX = 0;
    int sessionNDXSelected = 0;

    timeStamps.forEach((keyValue) {
      if (nearestTime == keyValue) {
        sessionNDXSelected = sessionNDX;
      }
      sessionNDX += 1;
    });

    setState(() {
      nextSessionTime = "";
    });
  } // getNextSessions

  void getClientRequest(String firebaseUIDValue) async {
    // listClientRequestMessages =
    //     await Provider.of<FirebaseServices>(context, listen: false)
    //         .getMessagesJsonClientRequest(firebaseUIDValue);

    List<UserGymClasses> listGymUserData = await getGymUserClasses(
        firebaseUIDValue, "0"); // list of new client request (status=0)

    List<UserGymClasses> listGymUserDataTaken =
        await getGymUserClasses(firebaseUIDValue, "1");

    setState(() {
      listGymUserClasses = listGymUserData;
      listGymUserClassesTaken = listGymUserDataTaken;
      clientRequestNumber = listGymUserClasses.length.toString();
      janClientNumber = clientNumberPerMonth(1, listGymUserClassesTaken);
      febClientNumber = clientNumberPerMonth(2, listGymUserClassesTaken);
      marClientNumber = clientNumberPerMonth(3, listGymUserClassesTaken);
      aprClientNumber = clientNumberPerMonth(4, listGymUserClassesTaken);
      mayClientNumber = clientNumberPerMonth(5, listGymUserClassesTaken);
      junClientNumber = clientNumberPerMonth(6, listGymUserClassesTaken);
      julClientNumber = clientNumberPerMonth(7, listGymUserClassesTaken);
      augClientNumber = clientNumberPerMonth(8, listGymUserClassesTaken);
      sepClientNumber = clientNumberPerMonth(9, listGymUserClassesTaken);
      octClientNumber = clientNumberPerMonth(10, listGymUserClassesTaken);
      novClientNumber = clientNumberPerMonth(11, listGymUserClassesTaken);
      decClientNumber = clientNumberPerMonth(12, listGymUserClassesTaken);
    });
  } // getClientRequest

  String clientNumberPerMonth(int month, List<UserGymClasses> listUserGym) {
    String stringNumber = "";

    stringNumber = listUserGym
        .where((gymUserData) =>
            DateTime.parse(gymUserData.date_time_trainer_approved).month ==
            month)
        .length
        .toString();

    return stringNumber;
  } // clientNumberPerMonth

  Future<List<GymUserSessionClass>> getGymUserSessions(
      String firebaseUID) async {
    List<GymUserSessionClass> listGymUserSessionsData = [];

    try {
      String url = dbUrl + "gym_session_users.json";
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        String trainerId = json['trainer_id'] ?? "";

        if (firebaseUID == trainerId)
          listGymUserSessionsData.add(GymUserSessionClass(
              gym_user_session_id: json['gym_user_session_id'] ?? "",
              gym_session_id: json['gym_session_id'] ?? "",
              gym_class_id: json['gym_class_id'] ?? "",
              date_time_meet: json['date_time_meet'] ?? "",
              price_per_day_net: json['price_per_day_net'] ?? "",
              fitup_service_price: json['fitup_service_price'] ?? "",
              rating: json['rating'] ?? "",
              review: json['review'] ?? "",
              status: json['status'] ?? "",
              trainer_id: json['trainer_id'] ?? "",
              user_id: json['user_id'] ?? "",
              price_per_day: json['price_per_day'] ?? "",
              fitup_service_percentage_from_price:
                  json['fitup_service_percentage_from_price'] ?? "",
              admin_remittance_date_time:
                  json['admin_remittance_date_time'] ?? "",
              is_trainer_remittance_confirm:
                  json['is_trainer_remittance_confirm'] ?? ""));
      });
    } catch (error) {
      throw error;
    }

    return listGymUserSessionsData;
  } //  getGymUserSessions

  Future<List<GymSessionClass>> getGymSessions(String firebaseUID) async {
    List<GymSessionClass> listGymSessionsData = [];

    try {
      String url = dbUrl + "gym_sessions.json";
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        String trainerId = json['trainer_id'] ?? "";

        if (firebaseUID == trainerId)
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
      });
    } catch (error) {
      throw error;
    }

    return listGymSessionsData;
  } //  getGymSessionsData

  Future<List<UserGymClasses>> getGymUserClasses(
      String firebaseUID, String status) async {
    List<UserGymClasses> listGymUserClassesData = [];

    try {
      String url = dbUrl + "user_gym_classes.json";
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        String trainerId = json['trainer_id'];
        String gymStatus = json['status'];
        if (firebaseUID == trainerId && gymStatus == status)
          listGymUserClassesData.add(UserGymClasses(
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
      });
    } catch (error) {
      throw error;
    }

    return listGymUserClassesData;
  } // getClientOrderRequest

  Future<String> getUserImageData(String firebaseUID) async {
    String imageUrl = "";
    String url = dbUrl + "user_images.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((id, data) {
        if (data['user_id'] ??
            "" == firebaseUID && data['status'] ??
            "" == "1") {
          imageUrl = data['image_url'] ?? "";
        }
      });
    } catch (error) {
      throw error;
    }

    return imageUrl;
  } // getUserImageData

  Future<void> getLatestProfile(String fUID) async {
    String? latestProfileURL = await getUserImageData(fUID);
    setState(() {
      profileImageUrl = latestProfileURL;
    });
  } // getLatestProfile()

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 90 &&
        subSelectedIndexLocal <= 100) {
      switch (subSelectedIndexLocal) {
        case 90:
          pageCurrent = const ClientOrders();
        case 91:
          pageCurrent = const TrainerBookingSessions();

        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = Container(
          child: Container(
              margin: const EdgeInsets.only(top: 65),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome Back,",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 28)),
                            getUserDetails(),
                          ]),
                      Container(
                          child: profileImageUrl == null
                              ? SvgPicture.asset(
                                  "assets/svg/user-profile-svgrepo-com.svg",
                                  height: 45)
                              : ClipOval(
                                  child: Image.network(profileImageUrl ?? "",
                                      fit: BoxFit.cover,
                                      height: 45,
                                      width: 45, errorBuilder:
                                          (context, error, StackTrace) {
                                  return SvgPicture.asset(
                                      "assets/svg/user-profile-svgrepo-com.svg",
                                      height: 45);
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
                                }))),
                    ]),
                SizedBox(height: 25),
                Column(children: [
                  Container(
                      child: Column(children: [
                    Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(
                            right: 25, left: 25, bottom: 10),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 7,
                              blurRadius: 10,
                              offset: Offset(0, 3))
                        ], color: Color.fromARGB(197, 247, 243, 248)),
                        child: nextSessionTime != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Next Session at",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 12)),
                                          Text(nextSessionTime ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24))
                                        ]),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(nextSessionClients ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 18)),
                                          Text(nextSessionDuration ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12))
                                        ])
                                  ])
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("No session for today",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 18)),
                                          Text(nextSessionDuration ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12))
                                        ])
                                  ])),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const InstructorMainMenu(
                              selectedInitIndex: 0, subSelectedInitIndex: 90);
                        }));
                      },
                      child: Container(
                          height: 85,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              right: 25, left: 25, bottom: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(200, 181, 26, 184)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                int.parse(clientRequestNumber ?? "") > 0
                                    ? Text(
                                        int.parse(clientRequestNumber ?? "") > 1
                                            ? "$clientRequestNumber new client requests"
                                            : "$clientRequestNumber new client request",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white))
                                    : Text("No new client requests",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                Text(
                                    int.parse(clientRequestNumber ?? "") > 0
                                        ? "Don't keep your potential clients waiting longer!"
                                        : "Clients are still looking for trainers like you",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white))
                              ])),
                    ),
                  ]))
                ]),
                Visibility(
                  visible: true,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(197, 247, 237, 245)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 15, top: 10),
                          child: Text("Client Stats",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 0, right: 25, top: 15, bottom: 5),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0,
                                        double.parse(janClientNumber ?? "0")),
                                    FlSpot(1,
                                        double.parse(febClientNumber ?? "0")),
                                    FlSpot(2,
                                        double.parse(marClientNumber ?? "0")),
                                    FlSpot(3,
                                        double.parse(aprClientNumber ?? "0")),
                                    FlSpot(4,
                                        double.parse(mayClientNumber ?? "0")),
                                    FlSpot(5,
                                        double.parse(junClientNumber ?? "0")),
                                    FlSpot(6,
                                        double.parse(julClientNumber ?? "0")),
                                    FlSpot(7,
                                        double.parse(augClientNumber ?? "0")),
                                    FlSpot(8,
                                        double.parse(sepClientNumber ?? "0")),
                                    FlSpot(9,
                                        double.parse(octClientNumber ?? "0")),
                                    FlSpot(10,
                                        double.parse(novClientNumber ?? "0")),
                                    FlSpot(11,
                                        double.parse(decClientNumber ?? "0")),
                                  ], // Data points for the line graph
                                  isCurved: true, // Makes the line curved
                                  color:
                                      Colors.purpleAccent, // Purple line color
                                  barWidth: 4, // Line thickness
                                  dotData: FlDotData(
                                    show:
                                        true, // Enable dots on intersection points
                                    // Color of the dots
                                  ), // Disable dots on data points
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 12, // Space for the labels
                                    getTitlesWidget:
                                        _buildMonthTitles, // Custom function for labels
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                    getTitlesWidget: _buildClientNumbersTitles,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: false,
                                )),
                              ),

                              // Shows X and Y titles
                              borderData: FlBorderData(
                                  show: false), // Hide borders around the chart
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    height: 175,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: BarChart(
                      BarChartData(
                        barGroups: _buildBarGroups(),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ])));
      ;
    }

    return pageCurrent;
  }
}

List<FlSpot> _getLineSpots() {
  return const [
    FlSpot(0, 1),
    FlSpot(1, 3),
    FlSpot(2, 2),
    FlSpot(3, 5),
    FlSpot(4, 3.5),
    FlSpot(5, 4),
    FlSpot(6, 7.5),
    FlSpot(7, 8),
    FlSpot(8, 10),
    FlSpot(9, 7),
    FlSpot(10, 15),
    FlSpot(11, 17),
  ];
}

Widget _buildClientNumbersTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10);

  return Text(value.toInt().toString(),
      style: style); // No label for undefined values
}

Widget _buildMonthTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  // Map values to month labels
  switch (value.toInt()) {
    case 0:
      return Text('Jan', style: style);
    case 1:
      return Text('Feb', style: style);
    case 2:
      return Text('Mar', style: style);
    case 3:
      return Text('Apr', style: style);
    case 4:
      return Text('May', style: style);
    case 5:
      return Text('Jun', style: style);
    case 6:
      return Text('Jul', style: style);
    case 7:
      return Text('Aug', style: style);
    case 8:
      return Text('Sep', style: style);
    case 9:
      return Text('Oct', style: style);
    case 10:
      return Text('Nov', style: style);
    case 11:
      return Text('Dec', style: style);
    default:
      return const SizedBox.shrink(); // No label for undefined values
  }
}

List<BarChartGroupData> _buildBarGroups() {
  return [
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 14)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15)]),
  ];
}
