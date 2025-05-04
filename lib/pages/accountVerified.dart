import 'package:flutter/material.dart';
import 'package:fitup/pages/AdminMainMenu.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/onClockSplash.dart';
import 'package:fitup/pages/login.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fitup/pages/sendOTP.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AccountVerified extends StatefulWidget {
  final String accountRoleId;

  const AccountVerified({super.key, required this.accountRoleId});

  @override
  State<AccountVerified> createState() => _accountVerifiedState();
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

void updateUserDetails(String firebaseUID) async {
  String? uid = await getUIDByFirebaseUID(firebaseUID);
  String url = dbUrl + "users/$uid.json";
  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({"email_verified": "true"}));
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

class _accountVerifiedState extends State<AccountVerified> {
  String? roleAccountId;
  String? firebaseUIDValue;
  String? forAccountActivation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    roleAccountId = widget.accountRoleId;
    removeSession("otp");
    getSharedPreferencesValues();
  }

  void getSharedPreferencesValues() async {
    String? firebaseUID = await getSession("firebase_uid");
    String? accountActivation = await getSession("account_activation");
    setState(() {
      firebaseUIDValue = firebaseUID;
      forAccountActivation = accountActivation;
    });
  } // getSharedPreferencesValues

  Widget build(BuildContext context) {
    _timer = Timer(Duration(seconds: 3), () {
      if (roleAccountId == '') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            action: SnackBarAction(
                label: 'Back',
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SendOTP(roleIdSelected: roleAccountId ?? "");
                  }));
                }),
            content: const Text("An error occured",
                style: TextStyle(color: Colors.black87)),
            backgroundColor: Colors.grey));
      } else {
        updateUserDetails(firebaseUIDValue ?? "");
        if (roleAccountId == '1') {
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) {
          //   return const UserMainMenu(
          //       selectedInitIndex: 0, subSelectedInitIndex: 0);
          // }));

          if (forAccountActivation == "1") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return Login(loginRole: roleAccountId ?? "");
            }));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const OnClockSplash();
            }));
          }
        }

        if (roleAccountId == '2') {
          if (forAccountActivation == "1") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return Login(loginRole: roleAccountId ?? "");
            }));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const InstructorMainMenu(
                  selectedInitIndex: 0, subSelectedInitIndex: 0);
            }));
          }
        }

        if (roleAccountId == '3') {
          if (forAccountActivation == "1") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return Login(loginRole: roleAccountId ?? "");
            }));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const AdminMainMenu(
                  selectedInitIndex: 0, subSelectedInitIndex: 0);
            }));
          }
        }
      }

      _timer?.cancel();
    });

    return Scaffold(
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 10,
                                  color:
                                      const Color.fromARGB(255, 229, 151, 243)
                                          .withOpacity(0.9)),
                              borderRadius: BorderRadius.circular(95),
                              color: const Color.fromARGB(199, 118, 10, 160)),
                          child:
                              Icon(Icons.check, color: Colors.white, size: 55)),
                      SizedBox(height: 18),
                      const Text("Your Account is Verified",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      SizedBox(height: 4),
                      const Text("You will be directed to the main page",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                      const Text(" in a few moments",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16))
                    ]))));
  }
}
