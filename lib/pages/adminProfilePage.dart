import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/adminMainMenu.dart';
import 'package:fitup/pages/adminSettings.dart';
import 'package:fitup/classes/Users.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _adminProfilePageState();
} // ProfilePage

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

Stream<List<Users>> getUsers() {
  final dbref = FirebaseDatabase.instance.ref("users");

  return dbref.onValue.map((event) {
    final List<Users> listUsers = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((userId, userData) {
      listUsers.add(Users(
          firebase_uid: userData['firebase_uid'],
          username: userData['username'],
          firstname: userData['firstname'],
          middlename: userData['middlename'],
          lastname: userData['lastname'],
          ext: userData['ext'],
          otp: userData['otp'],
          phone: userData['phone'],
          email: userData['email'],
          email_verified: userData['email_verified'],
          role: userData['role'],
          title: userData['title'],
          occupation: userData['occupation'],
          date_time_membership: userData['date_time_membership'],
          date_time_registered: userData['date_time_registered'],
          date_time_premium_activated:
              userData['date_time_premium_activated']));
    });

    return listUsers;
  });
}

Future<List<Users>> getDataUsersJson() async {
  final List<Users> listUsersData = [];
  var url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((userId, userData) {
      listUsersData.add(Users(
          firebase_uid: userData['firebase_uid'] ?? '',
          username: userData['username'] ?? '',
          firstname: userData['firstname'] ?? '',
          middlename: userData['middlename'] ?? '',
          lastname: userData['lastname'] ?? '',
          ext: userData['ext'] ?? '',
          otp: userData['otp'] ?? '',
          phone: userData['phone'] ?? '',
          email: userData['email'] ?? '',
          email_verified: userData['email_verified'] ?? '',
          role: userData['role'] ?? '',
          title: userData['title'] ?? '',
          occupation: userData['occupation'] ?? '',
          date_time_membership: userData['date_time_membership'] ?? '',
          date_time_registered: userData['date_time_registered'] ?? '',
          date_time_premium_activated:
              userData['date_time_premium_activated'] ?? ''));
    });
  } catch (error) {
    throw error;
  }
  return listUsersData;
} // getDataUsersJson

class _adminProfilePageState extends State<AdminProfilePage> {
  List<Users> listUserDetails = [];
  String? FirebaseUIDValue;
  String? profileImageUrl;

  void initState() {
    super.initState();

    FirebaseUIDValue = FirebaseAuth.instance.currentUser!.uid.toString();
    getAllUserJson();
    getLatestProfile();
  }

  Future<void> getLatestProfile() async {
    String? latestProfileURL = await getUserImageData(FirebaseUIDValue ?? "");
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
    }

    return imageUrl;
  } // getUserImageData

  Future<void> getAllUserJson() async {
    List<Users> listUserTemp = await getDataUsersJson();
    setState(() {
      listUserDetails = listUserTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const Splash();
      }));
    }

    return Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () {
                setSession("role", "1");
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return UserMainMenu(
                      selectedInitIndex: 4, subSelectedInitIndex: 11);
                }));
              },
              child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey),
                  child: ClipOval(
                    child: Image.network(
                        height: 100,
                        width: 100,
                        profileImageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, StackTrace) {
                      return Center(child: const Icon(Icons.person_2));
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
                    }),
                  )),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  listUserDetails
                              .where((dataUser) =>
                                  dataUser.firebase_uid == FirebaseUIDValue)
                              .toList()
                              .length >
                          0
                      ? listUserDetails
                          .where((dataUser) =>
                              dataUser.firebase_uid == FirebaseUIDValue)
                          .toList()[0]
                          .username
                      : "[Username]",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(children: [
                Icon(Icons.phone_android_outlined),
                Text(
                  listUserDetails
                              .where((dataUser) =>
                                  dataUser.firebase_uid == FirebaseUIDValue)
                              .toList()
                              .length >
                          0
                      ? listUserDetails
                          .where((dataUser) =>
                              dataUser.firebase_uid == FirebaseUIDValue)
                          .toList()[0]
                          .phone
                      : "[Phone]",
                )
              ]),
              SizedBox(height: 5),
              Row(children: [
                Icon(Icons.message_outlined),
                Text(
                  listUserDetails
                              .where((dataUser) =>
                                  dataUser.firebase_uid == FirebaseUIDValue)
                              .toList()
                              .length >
                          0
                      ? listUserDetails
                          .where((dataUser) =>
                              dataUser.firebase_uid == FirebaseUIDValue)
                          .toList()[0]
                          .email
                      : "[Email]",
                )
              ])
            ]),
            GestureDetector(
                onTap: () {
                  setSession("role", "3");
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AdminMainMenu(
                        selectedInitIndex: 0, subSelectedInitIndex: 102);
                  }));
                },
                child: Container(child: Icon(Icons.edit)))
          ]),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return AdminSettings();
              }));
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.black87.withOpacity(0.3), width: 1)),
                  color: const Color.fromARGB(137, 255, 255, 255)),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Icon(Icons.settings_outlined, size: 30),
                SizedBox(width: 20),
                Text("General Settings",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              ]),
            ),
          ),
        ]));
  }
}
