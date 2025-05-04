import 'package:flutter/material.dart';

import 'package:fitup/components/textFieldWithStatus.dart';
import 'package:fitup/components/textField_obscure_with_status.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/pages/signInAs.dart';
import 'package:fitup/pages/SendEmailforVerifyOrForgotPassword.dart';
import 'package:fitup/pages/instructorMainMenu.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/AdminMainMenu.dart';
import 'package:fitup/pages/signUpAs.dart';
import 'package:fitup/pages/registerUser.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/classes/AppConfig.dart';

bool isLoading = true;
List<String> userList = [];

String? email_status_label;
String? password_status_label;

FocusNode _focusNodeEmail = FocusNode();
FocusNode _focusNodePassword = FocusNode();

String dbUrl = AppConfig.dbUrl;

class Login extends StatefulWidget {
  final String loginRole;

  const Login({super.key, required this.loginRole});

  @override
  State<Login> createState() => _LoginState();
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

Future<void> signInWithEmail(String email, String password, String loginRole,
    BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (loginRole == "2") {
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Successfully Logged In! ${email}!")));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const InstructorMainMenu(
            selectedInitIndex: 0, subSelectedInitIndex: 0);
      }));
    }

    if (loginRole == "3") {
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Successfully Logged In! ${email}!")));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const AdminMainMenu(
            selectedInitIndex: 0, subSelectedInitIndex: 0);
      }));
    }

    if (loginRole == "1") {
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Successfully Logged In! ${email}!")));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const UserMainMenu(
            selectedInitIndex: 0, subSelectedInitIndex: 0);
      }));
    }
  } on FirebaseAuthException catch (e) {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(e.toString())));

    password_status_label = 'Sign-in Error, Invalid Password';
  }
}

Future<void> getUsersData(String email, String password, String loggedInRole,
    BuildContext context) async {
  var url = dbUrl + "users.json";

  bool userFound = false;
  bool emailVerified = false;
  bool differentRole = false;

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((userId, userData) {
      String emailString = userData['email'] ?? "";
      if (emailString == email) {
        String roleId = userData['role'] ?? "";
        if (loggedInRole == roleId) {
          userFound = true;

          final emailVerifiedRaw = userData['email_verified'];

          if (emailVerifiedRaw == true ||
              emailVerifiedRaw?.toString().toLowerCase() == 'true') {
            emailVerified = true;
          }
        } else {
          differentRole = true;
        }
      }
    });

    if (userFound) {
      if (emailVerified == false) {
        email_status_label = "Please verify account, Check your E-mail or SMS";
      } else {
        signInWithEmail(email, password, loggedInRole, context);
      }
    } else {
      if (differentRole) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("You cannot login other role here")));

        email_status_label = "You cannot login other role here";
      } else {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text("User ${email} not found")));

        email_status_label = "User ${email} not found";
      }
    }
  } catch (error) {
    throw error;
  }
}

class _LoginState extends State<Login> {
  final textEmailController = TextEditingController();
  final textPasswordController = TextEditingController();

  String? loggedInRole = '';
  String? loginRoleLabel = '';

  void initState() {
    super.initState();
    loggedInRole = widget.loginRole;
    if (loggedInRole == "1") {
      setState(() {
        loginRoleLabel = "Gym Enthusiast Login";
      });
    }

    if (loggedInRole == "2") {
      setState(() {
        loginRoleLabel = "Gym Trainer Login";
      });
    }

    if (loggedInRole == "3") {
      setState(() {
        loginRoleLabel = "FitUp Admin Login";
      });
    }
  }

  Widget build(BuildContext context) {
    void _onEmailChange() {
      email_status_label = '';
    }

    void _onPasswordChange() {
      password_status_label = '';
    }

    textEmailController.addListener(_onEmailChange);
    textPasswordController.addListener(_onPasswordChange);

    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SignInAs();
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160)))))),
        body: SafeArea(
            child: Center(
                child: ListView(children: [
          Center(
            child: Text("Welcome to",
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w300)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.asset('assets/images/fituplogosplash2.png',
                  fit: BoxFit.cover, height: 100),
            ),
          ),
          Center(
            child: Text(loginRoleLabel ?? "",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(child: Container(height: 10)),
          TextFieldWithStatus(
              focusNode: _focusNodeEmail,
              textController: textEmailController,
              obscure_text: false,
              hint_text_value: "Enter your Email",
              status_label: email_status_label ?? "",
              iconPrefix: const Icon(Icons.email, color: Colors.black12),
              iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                  color: Colors.transparent)),
          TextFieldObscureCustomWithStatus(
              focusNode: _focusNodePassword,
              textController: textPasswordController,
              hint_text_value: "Enter your Password",
              status_label: password_status_label ?? "",
              iconPrefix: const Icon(Icons.lock, color: Colors.black12),
              iconSuffix: const Icon(Icons.remove_red_eye)),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return SendEmailForVerifyOrForgotPassword(
                    roleId: loggedInRole ?? "");
              }));
            },
            child: Center(
              child: Text("Forgot Password?",
                  style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(child: Container(height: 15)),
          GestureDetector(
            onTap: () {
              FutureBuilder<void>(
                  future: getUsersData(
                      textEmailController.text,
                      textPasswordController.text,
                      loggedInRole ?? "0",
                      context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error ${snapshot.error}");
                    } else {
                      return const Text("");
                    }
                  });

              if (email_status_label != "" || email_status_label != null) {
                FocusScope.of(context).requestFocus(_focusNodeEmail);
              }

              if (password_status_label != "" ||
                  password_status_label != null) {
                FocusScope.of(context).requestFocus(_focusNodePassword);
              }
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(199, 118, 10, 160)),
                child: const Text("Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  height: 1,
                  width: MediaQuery.of(context).size.width / 3.2,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(199, 118, 10, 160))),
              Text("Or Login With",
                  style: TextStyle(fontSize: 12, color: Colors.black26)),
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  height: 1,
                  width: MediaQuery.of(context).size.width / 3.2,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(199, 118, 10, 160))),
            ]),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.facebook_outlined,
                              color: const Color.fromARGB(199, 118, 10, 160)),
                          margin: const EdgeInsets.all(10),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 3.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(199, 118, 10, 160),
                                  width: 1.0,
                                  style: BorderStyle.solid))),
                      Container(
                          padding: const EdgeInsets.all(14),
                          child: SvgPicture.asset("assets/svg/googlelogo1.svg",
                              color: const Color.fromARGB(199, 118, 10, 160),
                              height: 12,
                              width: 12),
                          margin: const EdgeInsets.all(10),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 3.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(199, 118, 10, 160),
                                  width: 1.0,
                                  style: BorderStyle.solid))),
                      GestureDetector(
                          onTap: () {},
                          child: Container(
                              child: Icon(Icons.apple,
                                  color:
                                      const Color.fromARGB(199, 118, 10, 160)),
                              margin: const EdgeInsets.all(10),
                              height: 50,
                              width: MediaQuery.of(context).size.width / 3.8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          199, 118, 10, 160),
                                      width: 1.0,
                                      style: BorderStyle.solid))))
                    ])),
                SizedBox(
                    height: MediaQuery.of(context).size.height -
                        (MediaQuery.of(context).size.height * 0.95)),
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      Text("Don't have an account? ",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 11.5,
                              color: Colors.black87)),
                      GestureDetector(
                          onTap: () {
                            if (widget.loginRole == "3") {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return const RegisterUser(registerRole: "3");
                              }));
                            } else {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return SignUpAs();
                              }));
                            }
                          },
                          child: Text("Register Now",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 11.5,
                                  color: Color.fromARGB(199, 118, 10, 160))))
                    ])),
                SizedBox(height: 15),
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      Text("NOT YET VERIFIED? ",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                              color: Colors.black87)),
                      GestureDetector(
                          onTap: () {
                            setSession("send_email_title", "Verify Account");
                            setSession("send_email_subtitle",
                                "Enter email address you have registered");
                            setSession(
                                "send_email_button_label", "Send OTP to Email");
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return SendEmailForVerifyOrForgotPassword(
                                  roleId: loggedInRole ?? "");
                            }));
                          },
                          child: Text("VERIFY NOW",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                  color: Color.fromARGB(199, 118, 10, 160))))
                    ])),
                SizedBox(height: 25)
              ])
        ]))));
  }
}
