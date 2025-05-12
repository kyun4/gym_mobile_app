import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/TrainerWallet.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class InstructorProfileMenu extends StatefulWidget {
  const InstructorProfileMenu({super.key});

  @override
  State<InstructorProfileMenu> createState() => _instructorProfileMenuState();
}

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} //

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<List<GymTrainerClasses>> getTrainerClasses() async {
  List<GymTrainerClasses> listGymTrainerData = [];
  String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      if (firebaseUID == json['firebase_uid']) {
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
      }
    });
  } catch (error) {
    throw error;
  }

  return listGymTrainerData;
} // getTrainerClasses

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return num.tryParse(s) != null;
}

class _instructorProfileMenuState extends State<InstructorProfileMenu> {
  String? firebaseUID;
  List<Users> listUsersData = [];
  String? fullname;
  String? profileImageUrl;
  String? clientNumbers;
  String? sessionNumbers;
  String? trainerBalance;

  void initState() {
    super.initState();
    setState(() {
      firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    });

    getUserDetails();
    getLatestProfile();
    getTotalClientNumbers();
    getTotalSessionNumbers();
    getTrainerBalance();
  }

  void getTotalClientNumbers() async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<UserGymClasses> listGymTrainerData =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getStreamUserGymClasses(firebaseUID);

    int clientNumberInt = listGymTrainerData.length;

    setState(() {
      clientNumbers = clientNumberInt.toString();
    });
  } // getTotalClientNumbers

  void getTotalSessionNumbers() async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<GymSessionClass> listGymSessionData =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getStreamGymSessions();

    int sessionNumberInt = listGymSessionData
        .where((gymSession) =>
            gymSession.trainer_id == firebaseUID && gymSession.status == "1")
        .length;
    setState(() {
      sessionNumbers = sessionNumberInt.toString();
    });
  } // getTotalSessionNumbers

  void getTrainerBalance() async {
    String? trainerBalanceValue = await getTrainerBalanceValue();
    setState(() {
      trainerBalance = trainerBalanceValue;
    });
  } // getTrainerBalance

  Future<String> getTrainerBalanceValue() async {
    String firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    String? trainerWalletBalance;
    String url = dbUrl + "trainer_wallet.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == Null ||
          extractedData == null ||
          response.body.isEmpty) {
        return "0";
      }

      extractedData.forEach((key, json) {
        if (json['trainer_id'] == firebaseUIDValue) {
          trainerWalletBalance = json['current_balance'] ?? "0";
        }
      });
    } catch (error) {
      return "0";
    }

    return trainerWalletBalance ?? "";
  } // getTrainerBalanceValue

  Future<void> getLatestProfile() async {
    String? latestProfileURL = await getUserImageData(firebaseUID ?? "");
    setState(() {
      profileImageUrl = latestProfileURL;
    });
  } // getLatestProfile()

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
        if (data['user_id'] == firebaseUID && data['status'] == "1") {
          imageUrl = data['image_url'] ?? "";
        }
      });
    } catch (error) {
      throw error;
    } // getUserImageData

    return imageUrl;
  } // getUserImageData

  Future<void> getUserDetails() async {
    List<Users> list_users =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getUsersJson();

    setState(() {
      var firstname = list_users
          .where((userData) => userData.firebase_uid == firebaseUID)
          .toList()[0]
          .firstname;

      var middlename = list_users
          .where((userData) => userData.firebase_uid == firebaseUID)
          .toList()[0]
          .middlename;

      var lastname = list_users
          .where((userData) => userData.firebase_uid == firebaseUID)
          .toList()[0]
          .lastname;

      var ext = list_users
          .where((userData) => userData.firebase_uid == firebaseUID)
          .toList()[0]
          .ext;

      var username = list_users
          .where((userData) => userData.firebase_uid == firebaseUID)
          .toList()[0]
          .username;

      //fullname = firstname + ' ' + middlename + ' ' + lastname + ' ' + ext;
      fullname = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height / 7,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(199, 118, 10, 160),
                Color.fromARGB(197, 29, 0, 30)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )))
      ])),
      Positioned.fill(
          child: Container(
        child: ListView(children: [
          SizedBox(height: MediaQuery.of(context).size.height / 10),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setSession("role", "2");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return InstructorMainMenu(
                              selectedInitIndex: 4, subSelectedInitIndex: 11);
                        }));
                      },
                      child: Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(199, 118, 10, 160),
                              borderRadius: BorderRadius.circular(110)),
                          child: profileImageUrl == null
                              ? Icon(Icons.person_2_outlined,
                                  color: Colors.white)
                              : ClipOval(
                                  child: Image.network(profileImageUrl ?? "",
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100, errorBuilder:
                                          (context, error, StackTrace) {
                                  return Center(
                                      child: Icon(Icons.person_2,
                                          color: Colors.white));
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
                    ),
                    Column(children: [
                      SizedBox(height: 20),
                      Text(clientNumbers ?? "",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Clients")
                    ]),
                    Column(children: [
                      SizedBox(height: 20),
                      Text(sessionNumbers ?? "",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Sessions")
                    ])
                  ])),
          Container(
              margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullname ?? "[Trainer]",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Fitness and Nutrition Trainer"),
                          Text("15+ years of experience",
                              style: TextStyle(fontSize: 12)),
                        ]),
                    SizedBox(height: 20),
                    Container(
                        height: 10,
                        decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.black45)),
                        )),
                    Container(
                      margin: const EdgeInsets.only(top: 25, bottom: 25),
                      child: Text("Specializes in:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                        height: 100,
                        child: GridView.builder(
                            itemCount: 5,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 3),
                            itemBuilder: (context, index) {
                              return Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text("Fitness Training",
                                      style: TextStyle(fontSize: 10)));
                            })),
                    GestureDetector(
                      onTap: () {
                        setSession("role", "2");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return InstructorMainMenu(
                              selectedInitIndex: 4, subSelectedInitIndex: 13);
                        }));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(199, 118, 10, 160)),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit,
                                  color: Color.fromARGB(199, 118, 10, 160)),
                              Text(" Edit Trainer Details",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(199, 118, 10, 160))),
                            ],
                          )),
                    ),
                    SizedBox(height: 25),
                    Container(
                        margin: const EdgeInsets.only(top: 11, bottom: 15),
                        height: 135,
                        width: MediaQuery.of(context).size.width - 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 16.5,
                                  spreadRadius: 2,
                                  color: Colors.grey.withOpacity(0.05),
                                  offset: Offset(5, 5))
                            ]),
                        child: Container(
                          height: 115,
                          margin: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Your Fit Up Wallet Balance",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400)),
                                    Text(
                                        trainerBalance != null
                                            ? isNumeric(trainerBalance) == true
                                                ? "PHP " +
                                                    double.parse(
                                                            trainerBalance!)
                                                        .toStringAsFixed(2)
                                                : "--- --.--"
                                            : "--- --.--",
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold))
                                  ]),
                              Container(
                                  height: 35,
                                  margin: const EdgeInsets.only(top: 3),
                                  width: MediaQuery.of(context).size.width - 25,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(3.5),
                                                  child: Icon(Icons.history,
                                                      color: Color.fromARGB(
                                                          199, 167, 10, 180))),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(3.5),
                                                child: Text("See history",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            199,
                                                            167,
                                                            10,
                                                            180))),
                                              )
                                            ]),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(3.5),
                                                  child: Icon(
                                                      Icons.outbond_outlined,
                                                      color: Color.fromARGB(
                                                          199, 167, 10, 180))),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(3.5),
                                                child: Text("Withdraw/Cash Out",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            199,
                                                            167,
                                                            10,
                                                            180))),
                                              )
                                            ])
                                      ]))
                            ],
                          ),
                        )),
                    SizedBox(height: 25),
                    Container(
                        margin: const EdgeInsets.only(top: 11, bottom: 15),
                        child: Text("Your Gym Classes",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        width: MediaQuery.of(context).size.width - 25,
                        height: 70,
                        child: StreamBuilder(
                            stream: getTrainerClasses().asStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text("No available data"));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              var rawData = snapshot.data!;
                              final deduplicated = <String, dynamic>{};

                              for (var item in rawData) {
                                deduplicated[item.gym_trainer_class_id] = item;
                              }

                              final uniqueList = deduplicated.values.toList();

                              return ListView.builder(
                                  itemCount: uniqueList.length,
                                  itemBuilder: (context, index) {
                                    final dataContent = uniqueList[index];
                                    String className = dataContent.class_name;
                                    String classDescription =
                                        dataContent.class_description;
                                    String pricePerDay =
                                        dataContent.price_per_day;

                                    return Container(
                                        height: 25,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(className.toUpperCase(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14)),
                                              Text("PHP $pricePerDay per Day",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 14))
                                            ]));
                                  });
                            })),
                    GestureDetector(
                      onTap: () {
                        setSession("role", "2");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return InstructorMainMenu(
                              selectedInitIndex: 4, subSelectedInitIndex: 10);
                        }));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(top: 12, bottom: 12),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(199, 118, 10, 160)),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.settings_outlined,
                                  color: Color.fromARGB(199, 118, 10, 160)),
                              Text(" Settings",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(199, 118, 10, 160))),
                            ],
                          )),
                    )
                  ]))
        ]),
      ))
    ]));
  }
}
