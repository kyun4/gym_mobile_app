import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:fitup/classes/GymTrainerProfileClass.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserTrainerProfile extends StatefulWidget {
  const UserTrainerProfile({super.key});

  @override
  State<UserTrainerProfile> createState() => _userTrainerProfileState();
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

Stream<List<GymTrainerClasses>> getStreamTrainerClasses(
    String trainerFirebaseUID, String trainingVenue) {
  final databaseRef = FirebaseDatabase.instance.ref("gym_trainer_classes");

  return databaseRef.onValue.map((event) {
    final List<GymTrainerClasses> gymTrainerClasses = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((gymClassesId, data) {
      if (trainerFirebaseUID == data['firebase_uid'] &&
          data['status'] == "1" &&
          trainingVenue == data['session_setup']) {
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

class _userTrainerProfileState extends State<UserTrainerProfile> {
  String? trainerName;
  String? trainerId;
  List<Users> userList = [];
  List<UserImagesClass> userImagesList = [];
  List<GymTrainerProfileClass> gymTrainerProfileList = [];
  String? clientUsername;
  String? clientFullname;
  String? trainerUsername;
  String? trainerFullname;
  String? trainerCoverPhoto;
  String? firebaseUIDValue;
  String? profileImageUrl;
  String? sessionSetup;
  String? profileDescription;
  String? facebookProfileID;
  String? tiktokProfileID;
  String? specialtySkills;

  void initState() {
    super.initState();

    firebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();

    getAllUsers();
    getTrainerDetailsFromSession();
    getSessionSetup();
  }

  void getSessionSetup() async {
    String? session_setup = await getSession("training_venue");
    setState(() {
      sessionSetup = session_setup!.toLowerCase();
    });
  } // getSessionSetup

  void getTrainerProfileData(String trainerIdValue) async {
    List<GymTrainerProfileClass> listTrainerClass =
        await getTrainerProfile(trainerIdValue);
    setState(() {
      gymTrainerProfileList = listTrainerClass;
      trainerCoverPhoto = gymTrainerProfileList.length > 0
          ? gymTrainerProfileList[0].cover_photos
          : "";
      facebookProfileID = gymTrainerProfileList.length > 0
          ? gymTrainerProfileList[0].socials_facebook
          : "";
      tiktokProfileID = gymTrainerProfileList.length > 0
          ? gymTrainerProfileList[0].socials_tiktok
          : "";
      specialtySkills = gymTrainerProfileList.length > 0
          ? gymTrainerProfileList[0].specialty
          : "";
      profileDescription = gymTrainerProfileList.length > 0
          ? gymTrainerProfileList[0].profile_description
          : "";
    });
  } // getTrainerProfileData

  Future<List<GymTrainerProfileClass>> getTrainerProfile(
      String trainerIDValue) async {
    List<GymTrainerProfileClass> listTrainerProfile = [];
    String url = dbUrl + "gym_trainer_profile.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null ||
          extractedData == Null ||
          response.body.isEmpty) {
        return [];
      }
      extractedData.forEach((key, json) {
        String trainerID = key;
        if (trainerIDValue == trainerID) {
          listTrainerProfile.add(GymTrainerProfileClass(
              gym_trainer_profile_id: json['gym_trainer_profile_id'] ?? "",
              gym_id: json['gym_id'] ?? "",
              specialty: json['specialty'] ?? "",
              bio_one: json['bio_one'] ?? "",
              bio_two: json['bio_two'] ?? "",
              socials_facebook: json['socials_facebook'] ?? "",
              socials_linkedin: json['socials_linkedin'] ?? "",
              socials_instagram: json['socials_instagram'] ?? "",
              socials_rednote: json['socials_rednote'] ?? "",
              socials_tiktok: json['socials_tiktok'] ?? "",
              socials_whatsapp: json['socials_whatsapp'] ?? "",
              socials_viber: json['socials_viber'] ?? "",
              socials_x: json['socials_x'] ?? "",
              firebase_uid: json['firebase_uid'] ?? "",
              date_time_added: json['date_time_added'] ?? "",
              date_time_last_updated: json['date_time_last_updated'] ?? "",
              cover_photos: json['cover_photos'] ?? "",
              profile_description: json['profile_description'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }
    return listTrainerProfile;
  } // getTrainerProfile

  Future<void> getTrainerLatestProfileImage(String trainerIDValue) async {
    String? latestProfileURL = await getUserImageData(trainerIDValue);
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

      if (extractedData == null ||
          extractedData == Null ||
          response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((id, data) {
        String status = data['status'] ?? "";
        String userId = data['user_id'] ?? "";
        String dataImage = data['image_url'] ?? "";
        if (userId == firebaseUID && status == "1") {
          imageUrl = dataImage;
        }
      });
    } catch (error) {
      return "";
    } // getUserImageData

    return imageUrl;
  } // getUserImageData

  Future<void> getTrainerDetailsFromSession() async {
    String? fullname = await getSession("receiverName");
    String? trainerFirebaseUid = await getSession("trainerFirebaseUid");

    setState(() {
      trainerName = fullname;
      trainerId = trainerFirebaseUid;
    });

    getTrainerLatestProfileImage(trainerId ?? "");
    getTrainerProfileData(trainerId ?? "");
  } // getTrainerDetailsFromSession

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: 565,
                          child: Stack(children: [
                            Positioned.fill(
                                child: Column(children: [
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                        Color.fromARGB(199, 190, 38, 170),
                                        Color.fromARGB(199, 240, 111, 99)
                                      ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.graphic_eq_rounded,
                                            color: Colors.white, size: 30),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text("Hi ${clientUsername}!",
                                                style: TextStyle(
                                                    fontSize: 28,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Icon(Icons.back_hand,
                                                color: Colors.amberAccent)
                                          ],
                                        ),
                                        Text(
                                            "Let us know if we can help you with anything at all",
                                            style:
                                                TextStyle(color: Colors.white))
                                      ]))
                            ])),
                            Positioned(
                                bottom: 15,
                                left: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.all(10),
                                        height: 235,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border(
                                              top: BorderSide(
                                                  width: 2,
                                                  color: Color.fromARGB(
                                                      199, 116, 10, 180))),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 30,
                                                  right: 30,
                                                  bottom: 20,
                                                  top: 25),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Start a Conversation",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                    SizedBox(height: 12),
                                                    Row(children: [
                                                      Container(
                                                          height: 50,
                                                          width: 50,
                                                          margin: const EdgeInsets.only(
                                                              right: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      50),
                                                              color: Color.fromARGB(
                                                                  199, 167, 111, 157)),
                                                          child: profileImageUrl ==
                                                                  null
                                                              ? Icon(Icons.person_2_outlined,
                                                                  color: Colors
                                                                      .white)
                                                              : ClipOval(
                                                                  child: Image.network(
                                                                      profileImageUrl ?? "",
                                                                      height: 25,
                                                                      width: 25, errorBuilder: (context, error, StackTrace) {
                                                                  return Icon(
                                                                      Icons
                                                                          .person_2_outlined,
                                                                      color: Colors
                                                                          .white);
                                                                }, loadingBuilder: (context, Widget child, ImageChunkEvent? loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  } else {
                                                                    return Container(
                                                                      height:
                                                                          200,
                                                                      child: Center(
                                                                          child:
                                                                              CircularProgressIndicator(value: loadingProgress != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null)),
                                                                    );
                                                                  }
                                                                }))),
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                "${trainerName}'s usual reply",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            Row(children: [
                                                              Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          199,
                                                                          190,
                                                                          38,
                                                                          170),
                                                                  size: 20),
                                                              Text("1 Hour",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12))
                                                            ])
                                                          ])
                                                    ]),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setSession("receiverId",
                                                            trainerId ?? "");
                                                        setSession(
                                                            "receiverName",
                                                            trainerName ?? "");

                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return UserMainMenu(
                                                              selectedInitIndex:
                                                                  1,
                                                              subSelectedInitIndex:
                                                                  27);
                                                        }));
                                                      },
                                                      child: Container(
                                                          height: 40,
                                                          width: 220,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8,
                                                                  bottom: 8,
                                                                  left: 18,
                                                                  right: 18),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 15),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          45),
                                                              color: Color
                                                                  .fromARGB(
                                                                      199,
                                                                      167,
                                                                      10,
                                                                      180)),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Icon(Icons.send,
                                                                    color: Colors
                                                                        .white),
                                                                Text(
                                                                    "Send ${trainerName} a Message",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white))
                                                              ])),
                                                    ),
                                                  ]),
                                            ),
                                            Container(
                                                height: 1,
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.5))),
                                            GestureDetector(
                                              onTap: () {
                                                setSession("receiverId",
                                                    trainerId ?? "");
                                                setSession("receiverName",
                                                    trainerName ?? "");

                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
                                                        builder: (context) {
                                                  return UserMainMenu(
                                                      selectedInitIndex: 1,
                                                      subSelectedInitIndex: 27);
                                                }));
                                              },
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    left: 30,
                                                    bottom: 10),
                                                child: Text(
                                                    "See all your conversations",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color.fromARGB(
                                                            199,
                                                            190,
                                                            38,
                                                            170))),
                                              ),
                                            )
                                          ],
                                        )),
                                    Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 10,
                                            bottom: 10),
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border(
                                              top: BorderSide(
                                                  width: 2,
                                                  color: Colors.amber)),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 30,
                                                  bottom: 5,
                                                  top: 5),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "Frequent FAQ Answered",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                    SizedBox(height: 12),
                                                    Container(
                                                      height: 40,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      child: Row(children: [
                                                        Container(
                                                          height: 35,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.490,
                                                          child: TextField(
                                                              decoration: InputDecoration(
                                                                  hintText:
                                                                      'Search our articles',
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.6),
                                                                      fontSize:
                                                                          16),
                                                                  filled: true,
                                                                  fillColor: Colors
                                                                      .white,
                                                                  contentPadding:
                                                                      const EdgeInsets.all(
                                                                          7),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors.grey.withOpacity(
                                                                              0.5))),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))))),
                                                        ),
                                                        Container(
                                                            height: 35,
                                                            width: 35,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            199,
                                                                            167,
                                                                            10,
                                                                            180)),
                                                            child: Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color: Colors
                                                                    .white))
                                                      ]),
                                                    )
                                                  ]),
                                            ),
                                          ],
                                        ))
                                  ],
                                )),
                          ])));
                });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Custom shape
          ),
          mini: false,
          child: Icon(Icons.messenger, color: Colors.white),
          backgroundColor: Color.fromARGB(199, 116, 10, 180)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
          child: ListView(children: [
        Column(
          children: [
            Container(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 30, right: 30),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          removeSession("receiverId");
                          removeSession("receiverName");
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const UserMainMenu(
                                selectedInitIndex: 1, subSelectedInitIndex: 25);
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
                            child: Icon(Icons.share,
                                color: Colors.white, size: 22),
                          ))
                    ])),
            Column(children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  decoration: BoxDecoration(
                      color: trainerCoverPhoto == ""
                          ? Colors.grey.withOpacity(0.05)
                          : Colors.transparent),
                  child: Stack(children: [
                    Positioned.fill(
                      child: Image.network(trainerCoverPhoto ?? "",
                          errorBuilder: (context, error, StackTraceError) {
                        return Center(child: Icon(Icons.image, size: 55));
                      }, loadingBuilder: (context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                                  value: loadingProgress != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null));
                        }
                      }, fit: BoxFit.cover),
                    ),
                    Visibility(
                      visible: trainerCoverPhoto == "" ? false : true,
                      child: Positioned.fill(
                          top: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  trainerFullname == null
                                      ? ""
                                      : trainerFullname!.toUpperCase(),
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
                                    Text(facebookProfileID ?? "",
                                        style: TextStyle(color: Colors.white))
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.tiktok, color: Colors.white),
                                    Text(tiktokProfileID ?? "",
                                        style: TextStyle(color: Colors.white))
                                  ])
                            ],
                          )),
                    )
                  ])),
              Container(
                margin: const EdgeInsets.all(35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(199, 116, 10, 180))),
                    Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: specialtySkills!.split(",").length > 0
                              ? specialtySkills!.split(",").length
                              : 0,
                          itemBuilder: (context, index) {
                            return Container(
                                height: 45,
                                width:
                                    specialtySkills!.split(",")[index].length *
                                        12,
                                margin: const EdgeInsets.only(top: 7),
                                child: Container(
                                    width: 100,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        right: 10, top: 5, bottom: 5),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(45),
                                        border: Border.all(
                                            width: 2.0,
                                            color: Color.fromARGB(
                                                199, 116, 10, 180))),
                                    child: Text(
                                        specialtySkills!
                                            .split(",")[index]
                                            .toString(),
                                        style: TextStyle(fontSize: 12.5))));
                          }),
                    ),
                    SizedBox(height: 10),
                    Text(profileDescription ?? ""),
                    Text("See all",
                        style: TextStyle(
                            color: Color.fromARGB(199, 116, 10, 180))),
                    Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          SizedBox(height: 30),
                          Text("Classes",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(199, 116, 10, 180))),
                          SizedBox(height: 25),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                sessionSetup == "onsite"
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            sessionSetup = "onsite";
                                          });
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        width: 2.0,
                                                        color: Color.fromARGB(
                                                            199,
                                                            116,
                                                            10,
                                                            180)))),
                                            child: Text("In-person",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))))
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            sessionSetup = "onsite";
                                          });
                                        },
                                        child: Container(
                                            child: Text("In-person",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)))),
                                sessionSetup == "offsite"
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            sessionSetup = "offsite";
                                          });
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        width: 2.0,
                                                        color: Color.fromARGB(
                                                            199,
                                                            116,
                                                            10,
                                                            180)))),
                                            child: Text("Online",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))))
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            sessionSetup = "offsite";
                                          });
                                        },
                                        child: Container(
                                            child: Text("Online",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)))),
                              ]),
                          SizedBox(height: 20),
                          StreamBuilder(
                              stream: getStreamTrainerClasses(
                                  trainerId ?? "", sessionSetup ?? ""),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container(
                                      height: 250,
                                      width:
                                          MediaQuery.of(context).size.width - 5,
                                      child: Center(
                                          child: Text(
                                              "Something went wrong, reload this page")));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, ndx) {
                                      final dataContent = snapshot.data![ndx];
                                      DateTime dateStart = DateTime.parse(
                                          dataContent.date_start);
                                      String formattedDateStart =
                                          DateFormat('MMM d').format(dateStart);

                                      DateTime dateEnd =
                                          DateTime.parse(dataContent.date_end);
                                      String formattedDateEnd =
                                          DateFormat('MMM d').format(dateEnd);

                                      String timeStart = dataContent
                                          .schedule_times
                                          .split(",")[0]
                                          .toString();

                                      return GestureDetector(
                                        onTap: () {
                                          setSession("gym_class_start_date",
                                              dateStart.toString());
                                          setSession("gym_class_start_time",
                                              timeStart);
                                          setSession("trainer_name",
                                              "trainer full name");
                                          setSession(
                                              "class_id",
                                              snapshot.data![ndx]
                                                  .gym_trainer_class_id);
                                          setSession("exerciseId",
                                              snapshot.data![ndx].exercise_id);
                                          setSession(
                                              "class_image_url",
                                              snapshot
                                                  .data![ndx].cover_photo_url);
                                          setSession(
                                              "training_venue",
                                              snapshot
                                                  .data![ndx].session_setup);
                                          setSession("level",
                                              snapshot.data![ndx].level);
                                          setSession("best_for",
                                              snapshot.data![ndx].best_for);
                                          setSession("class_name",
                                              snapshot.data![ndx].class_name);
                                          setSession(
                                              "class_description",
                                              snapshot.data![ndx]
                                                  .class_description);

                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return const UserMainMenu(
                                                selectedInitIndex: 1,
                                                subSelectedInitIndex: 29);
                                          }));
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          height: 250,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              5,
                                          child: Stack(children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                    height: 250,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            5,
                                                    fit: BoxFit.cover,
                                                    dataContent.cover_photo_url,
                                                    errorBuilder: (context,
                                                        error, StackTrace) {
                                                  return Center(
                                                      child: Container(
                                                          height: 200,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              5,
                                                          child: Icon(Icons
                                                              .image_not_supported)));
                                                }, loadingBuilder: (context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return Container(
                                                      height: 200,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              5,
                                                      child: Center(
                                                          child: CircularProgressIndicator(
                                                              value: loadingProgress !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      (loadingProgress
                                                                              .expectedTotalBytes ??
                                                                          1)
                                                                  : null)),
                                                    );
                                                  }
                                                }),
                                              ),
                                            ),
                                            Container(
                                                padding: const EdgeInsets.only(
                                                    left: 15,
                                                    right: 15,
                                                    top: 20,
                                                    bottom: 10),
                                                height: 250,
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
                                                              Text("4.80",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                              SizedBox(
                                                                  width: 5),
                                                              Icon(Icons.star,
                                                                  color: Colors
                                                                      .white)
                                                            ]),
                                                            SvgPicture.asset(
                                                                "assets/svg/heart-svgrepo-com.svg"),
                                                          ]),
                                                      SizedBox(height: 105),
                                                      Row(children: [
                                                        Icon(
                                                            Icons
                                                                .location_history,
                                                            color:
                                                                Color.fromARGB(
                                                                    199,
                                                                    167,
                                                                    10,
                                                                    180)),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            dataContent
                                                                .class_name,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18)),
                                                      ]),
                                                      Text(
                                                          formattedDateStart +
                                                              " to " +
                                                              formattedDateEnd +
                                                              " - " +
                                                              dataContent.level
                                                                  .toUpperCase(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      SizedBox(height: 15),
                                                      Text(
                                                          dataContent
                                                                  .price_per_day +
                                                              " / day",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white))
                                                    ])),
                                          ]),
                                        ),
                                      );
                                    });
                              }),
                        ]))
                  ],
                ),
              ),
              Container(
                  height: 100,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        blurRadius: 25,
                        spreadRadius: 7,
                        color: Colors.black38,
                        offset: Offset(10, 10))
                  ]),
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    SizedBox(height: 12),
                    Text("See what $trainerName has to offer"),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return UserMainMenu(
                              selectedInitIndex: 1, subSelectedInitIndex: 28);
                        }));
                      },
                      child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13.5),
                              color: Color.fromARGB(199, 167, 10, 180)),
                          child: Text("View Schedule",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white))),
                    )
                  ]))
            ])
          ],
        ),
      ])),
    );
  }
}
