import 'package:flutter/material.dart';

import 'package:fitup/pages/UserMainMenu.dart';
import 'package:fitup/pages/adminMainMenu.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/Users.dart';

import 'package:fitup/components/textField.dart';
import 'package:fitup/components/textFieldPhone.dart';
import 'package:fitup/components/textField_obscure.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    String firebaseUID,
    String username,
    String phone,
    String firstname,
    String middlename,
    String lastname,
    String occupation,
    String title) async {
  String? uid = await getUIDByFirebaseUID(firebaseUID);
  String url = dbUrl + "users/$uid.json";
  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "username": username,
          "firstname": firstname,
          "middlename": middlename,
          "lastname": lastname,
          "phone": phone,
          "title": title,
          "occupation": occupation
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
  TextEditingController textFirstnameController = new TextEditingController();
  TextEditingController textMiddlenameController = new TextEditingController();
  TextEditingController textLastnameController = new TextEditingController();
  TextEditingController textExtnameController = new TextEditingController();
  TextEditingController textOccupationController = new TextEditingController();
  TextEditingController textPhoneController = new TextEditingController();
  TextEditingController textTitleController = new TextEditingController();
  TextEditingController textUsernameController = new TextEditingController();

  String? firebaseUID;
  String? roleId;

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

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Edit Details", style: TextStyle(fontSize: 16)),
            leading: GestureDetector(
                onTap: () {
                  if (roleId == "1") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMainMenu(
                          selectedInitIndex: 4, subSelectedInitIndex: 0);
                    }));
                  }

                  if (roleId == "2") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const InstructorMainMenu(
                          selectedInitIndex: 4, subSelectedInitIndex: 10);
                    }));

                    if (roleId == "3") {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const AdminMainMenu(
                            selectedInitIndex: 0, subSelectedInitIndex: 101);
                      }));
                    }
                  }
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
                stream: getUsers(firebaseUID ?? ""),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  textUsernameController.text = snapshot.data![0].username;
                  textFirstnameController.text = snapshot.data![0].firstname;
                  textMiddlenameController.text = snapshot.data![0].middlename;
                  textLastnameController.text = snapshot.data![0].lastname;
                  textExtnameController.text = snapshot.data![0].ext;
                  textPhoneController.text = snapshot.data![0].phone;
                  textOccupationController.text = snapshot.data![0].occupation;
                  textTitleController.text = snapshot.data![0].title;

                  return ListView(children: [
                    SizedBox(height: 25),
                    Container(
                        child: Column(children: [
                      TextFieldCustom(
                          textController: textUsernameController,
                          obscure_text: false,
                          hint_text_value: "Username",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textFirstnameController,
                          obscure_text: false,
                          hint_text_value: "First Name",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textMiddlenameController,
                          obscure_text: false,
                          hint_text_value: "Middle Name",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textLastnameController,
                          obscure_text: false,
                          hint_text_value: "Last Name",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textExtnameController,
                          obscure_text: false,
                          hint_text_value:
                              "Extension Name (e.g. Jr, Sr, III ...)",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldPhone(
                          textController: textPhoneController,
                          obscure_text: false,
                          hint_text_value: "Phone",
                          iconPrefix: const Icon(Icons.phone_android,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.phone,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textOccupationController,
                          obscure_text: false,
                          hint_text_value: "Occupation",
                          iconPrefix:
                              const Icon(Icons.work, color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textTitleController,
                          obscure_text: false,
                          hint_text_value: "Title",
                          iconPrefix: const Icon(Icons.work_history,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          updateUserDetails(
                              firebaseUID ?? "",
                              textUsernameController.text,
                              textPhoneController.text,
                              textFirstnameController.text,
                              textMiddlenameController.text,
                              textLastnameController.text,
                              textOccupationController.text,
                              textTitleController.text);

                          textFirstnameController.text = "";
                          textMiddlenameController.text = "";
                          textLastnameController.text = "";
                          textUsernameController.text = "";
                          textOccupationController.text = "";
                          textTitleController.text = "";

                          if (roleId == "1") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return UserMainMenu(
                                  selectedInitIndex: 4,
                                  subSelectedInitIndex: 0);
                            }));
                          }

                          if (roleId == "2") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const InstructorMainMenu(
                                  selectedInitIndex: 4,
                                  subSelectedInitIndex: 10);
                            }));
                          }

                          if (roleId == "3") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const AdminMainMenu(
                                  selectedInitIndex: 0,
                                  subSelectedInitIndex: 101);
                            }));
                          }

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Personal Details Successfully updated!")));
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
