import 'package:flutter/material.dart';

import 'package:fitup/pages/UserMainMenu.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/Users.dart';
import 'package:fitup/classes/GymTrainerProfileClass.dart';

import 'package:fitup/components/textField.dart';
import 'package:fitup/components/textFieldPhone.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class EditTrainerDetails extends StatefulWidget {
  const EditTrainerDetails({super.key});

  State<EditTrainerDetails> createState() => _editTrainerDetailsState();
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

void updateUserDetails(
    String bio_one,
    String bio_two,
    String specialty,
    String cover_photos,
    String gymId,
    String profileDescription,
    String socialsInstagram,
    String socialsFacebook,
    String socialsX,
    String socialsWhatsapp,
    String socialsTiktok,
    String socialsRednote,
    String socialsLinkedin,
    String socialsViber) async {
  String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
  String url = dbUrl + "gym_trainer_profile/$firebaseUID.json";

  String date_time_added =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "bio_one": bio_one,
          "bio_two": bio_two,
          "specialty": specialty,
          "cover_photos": cover_photos,
          "date_time_added": date_time_added,
          "date_time_last_updated": "",
          "firebase_uid": firebaseUID,
          "gym_id": gymId,
          "gym_trainer_profile_id": firebaseUID,
          "profile_description": profileDescription,
          "socials_facebook": socialsFacebook,
          "socials_instagram": socialsInstagram,
          "socials_x": socialsX,
          "socials_whatsapp": socialsWhatsapp,
          "socials_tiktok": socialsTiktok,
          "socials_rednote": socialsRednote,
          "socials_linkedin": socialsLinkedin,
          "socials_viber": socialsViber
        }));
  } catch (error) {
    throw error;
  }
} // updateUserDetails

Future<String> getUIDByFirebaseUID(String firebaseUID) async {
  String? uid;
  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['firebase_uid'] == firebaseUID) {
        uid = userId;
      }
    });
  } catch (error) {
    throw error;
  }
  return uid ?? "";
} // getUIDByFirebaseUID

class _editTrainerDetailsState extends State<EditTrainerDetails> {
  TextEditingController textLongBioController = new TextEditingController();
  TextEditingController textShortBioController = new TextEditingController();

  String? firebaseUID;
  String? roleId;

  String? specialtyValues;
  String? coverPhotosValues;
  String? gymId;
  String? profileDescriptionValue;
  String? socialsInstagramValue;
  String? socialsFacebookValue;
  String? socialsXValue;
  String? socialsWhatsappValue;
  String? socialsTiktokValue;
  String? socialsRednoteValue;
  String? socialsLinkedinValue;
  String? socialsViberValue;

  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getSharedPreferencesValues();
  }

  void getSharedPreferencesValues() async {
    String? roleIDValue = await getSession("role");
    setState(() {
      roleId = roleIDValue;
    });
  } // getSharedPreferencesValues

  Stream<List<Users>> getUsers(String firebaseUID) {
    final dbref = FirebaseDatabase.instance.ref("users");

    return dbref.onValue.map((event) {
      final List<Users> listUsers = [];

      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((key, json) {
        if (firebaseUID == json['firebase_uid']) {
          listUsers.add(Users(
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
              date_time_premium_activated:
                  json['date_time_premium_actvated'] ?? "",
              date_time_registered: json['date_time_registered'] ?? "",
              email_verified: json['email_verified'] ?? ""));
        }
      });

      return listUsers;
    });
  } // getUsers

  Future<List<GymTrainerProfileClass>> listGymTrainerProfile() async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<GymTrainerProfileClass> listGymTrainerProfileData = [];
    String url = dbUrl + "gym_trainer_profile.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == Null ||
          extractedData == null ||
          response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        String trainerID = json['firebase_uid'] ?? "";

        if (trainerID == firebaseUID) {
          listGymTrainerProfileData.add(GymTrainerProfileClass(
              gym_trainer_profile_id: json['gym_trainer_profile_id'] ?? "",
              gym_id: json['gym_id'] ?? "",
              specialty: json['specialty'] ?? "",
              bio_one: json['bio_one'],
              bio_two: json['bio_two'],
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

    return listGymTrainerProfileData;
  } // listGymTrainerProfile

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Edit Profile Details", style: TextStyle(fontSize: 16)),
            leading: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const InstructorMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 0);
                  }));
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(199, 118, 60, 180)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 60, 180))))),
        body: SafeArea(
            child: StreamBuilder(
                stream: listGymTrainerProfile().asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Center(
                            child: Text("No trainer profile available")));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.length > 0) {
                    textLongBioController.text = snapshot.data![0].bio_one;
                    textShortBioController.text = snapshot.data![0].bio_two;
                  }

                  return ListView(children: [
                    SizedBox(height: 25),
                    Container(
                        child: Column(children: [
                      TextFieldCustom(
                          textController: textLongBioController,
                          obscure_text: false,
                          hint_text_value: "Bio (Tell about yourself)",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textShortBioController,
                          obscure_text: false,
                          hint_text_value:
                              "Short Bio (e.g Years of experience, Title or Personality etc.)",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          updateUserDetails(
                              textLongBioController.text,
                              textShortBioController.text,
                              specialtyValues ?? "",
                              coverPhotosValues ?? "",
                              gymId ?? "",
                              profileDescriptionValue ?? "",
                              socialsInstagramValue ?? "",
                              socialsFacebookValue ?? "",
                              socialsXValue ?? "",
                              socialsWhatsappValue ?? "",
                              socialsTiktokValue ?? "",
                              socialsRednoteValue ?? "",
                              socialsLinkedinValue ?? "",
                              socialsViberValue ?? "");

                          textLongBioController.text = "";
                          textShortBioController.text = "";

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return InstructorMainMenu(
                                selectedInitIndex: 4, subSelectedInitIndex: 0);
                          }));

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Trainer Details Successfully Updated!")));
                        },
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(199, 118, 10, 160)),
                            child: GestureDetector(
                                onTap: () {},
                                child: const Text("Update",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)))),
                      ),
                    ])),
                  ]);
                })));
  }
}
