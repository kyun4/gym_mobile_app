import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fitup/pages/privacyPolicy.dart';

import 'package:fitup/components/textField.dart';
import 'package:fitup/components/textFieldPhone.dart';
import 'package:fitup/components/textField_obscure.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/pages/signInAs.dart';
import 'package:fitup/pages/chooseSendOtp.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class RegisterUser extends StatefulWidget {
  final String registerRole;

  const RegisterUser({super.key, required this.registerRole});

  @override
  State<RegisterUser> createState() => _registerUserState();
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

Future<String> checkUserExist(
    String username, String email, String phone) async {
  var url = dbUrl + "users.json";

  bool isExistUsername = false;
  bool isExistEmail = false;
  bool isExistPhone = false;

  StringBuffer errorContactBuffer = new StringBuffer();

  try {
    final response = await http.get(Uri.parse(url));

    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, userData) {
      if (userData['username'] == username) {
        isExistUsername = true;
      }

      if (userData['email'] == email) {
        isExistEmail = true;
      }
      if (userData['phone'] == phone) {
        isExistPhone = true;
      }
    });
  } catch (error) {
    //throw error;
  }

  if (isExistUsername) {
    errorContactBuffer.write("Username Already Taken\n");
  }

  if (isExistEmail) {
    errorContactBuffer.write("Email Address Already Taken\n");
  }

  if (isExistPhone) {
    errorContactBuffer.write("Mobile Phone Already Taken\n");
  }

  return errorContactBuffer.toString();
}

Future<void> signUpWithEmail(
    String username,
    String email,
    String phone,
    String password,
    String retryPassword,
    String roleId,
    FocusNode passwordNode,
    FocusNode retryPasswordNode,
    BuildContext context) async {
  StringBuffer errorStringBuffer = new StringBuffer();

  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  String errors = "";

  RegExp regex = RegExp(pattern);

  if (username.isEmpty) {
    errorStringBuffer.write("Username is blank\n");
  }

  if (email.isEmpty) {
    errorStringBuffer.write("Email Address is blank\n");
  }

  if (!regex.hasMatch(email)) {
    errorStringBuffer.write("Email Address format is invalid\n");
  }

  if (phone.isEmpty) {
    errorStringBuffer.write("Mobile Phone is blank\n");
  }

  String contactError = await checkUserExist(username, email, phone);

  if (password.isEmpty) {
    errorStringBuffer.write("Password is not specified\n");
  }

  if (retryPassword.isEmpty) {
    errorStringBuffer.write("Confirm Password is not specified\n");
  }

  if (password != retryPassword) {
    errorStringBuffer.write("Password did not matched\n");
  }

  if (contactError != '') {
    errorStringBuffer.write(contactError);
  }

  errors = trimRightByCharacter(errorStringBuffer.toString(), "\n");

  if (errors.isEmpty) {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String firebase_uid = userCredential.user!.uid;
      String email_verified = userCredential.user!.emailVerified.toString();

      writeData(username, email, phone, firebase_uid, roleId, email_verified,
          context);
      print(
          'User details saved for registration: ${userCredential.user!.email}');

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text("Successfull Registered! ${userCredential.user!.email}",
      //         style: TextStyle(color: Colors.white)),

      //     backgroundColor: const Color.fromARGB(199, 118, 10, 160)));
    } on FirebaseAuthException catch (e) {
      print('Failed to sign up: $e');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errors)));
    retryPasswordNode.requestFocus();
  }
} // signUpWithEmail

void writeData(String username, String email, String phone, String firebaseUID,
    String roleID, String email_verified, BuildContext context) async {
  // Please replace the Database URL
  // which we will get in “Add Realtime
  // Database” step with DatabaseURL
  var url = dbUrl + "users.json";

  String otp = generateRandomSixDigitNumber().toString();

  // (Do not remove “data.json”,keep it as it is)
  try {
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'username': username,
        'firstname': username + ' firstname',
        'middlename': username + ' middlename',
        'lastname': username + ' lastname',
        'ext': '',
        'email': email,
        'email_verified': email_verified,
        'firebase_uid': firebaseUID,
        'otp': otp,
        'phone': phone,
        'title': '',
        'occupation': '',
        'role': roleID,
        'date_time_membership': '',
        'date_time_premium_activated': '',
        'date_time_registered': ''
      }),
    );

    String fullname = username;
    setSession("fullname", fullname);
    setSession("otp", otp);
    setSession("phone", phone);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return ChooseSendOtp(roleIdSelected: roleID);
    }));
  } catch (error) {
    throw error;
  }
} // writeData

String trimRightByCharacter(String input, String character) {
  int index = input.lastIndexOf(character);

  if (index != -1) {
    return input.substring(
        0, index); // Return substring up to (but not including) the character
  }

  return input; // If character not found, return the original string
} // trimRightByCharacter

int generateRandomSixDigitNumber() {
  Random random = Random();
  return 100000 +
      random.nextInt(900000); // Generates a number from 100000 to 999999
}

class _registerUserState extends State<RegisterUser> {
  final textUsernameController = TextEditingController();
  final textEmailController = TextEditingController();
  final textPasswordController = TextEditingController();
  final textRetryPasswordController = TextEditingController();
  final textPhoneController = TextEditingController();

  FocusNode? passwordFocusNode;
  FocusNode? retryPasswordFocusNode;

  //final _form = GlobalKey<FormState>();

  String? registerRoleId;
  String? roleRegister;

  @override
  void initState() {
    super.initState();
    registerRoleId = widget.registerRole;
    //roleRegister = registerRoleId == '1' ? "Gym Enthusiast" : "Gym Trainer";

    if (registerRoleId == "1") {
      setState(() {
        roleRegister = "Gym Enthusiast Login";
      });
    }

    if (registerRoleId == "2") {
      setState(() {
        roleRegister = "Gym Trainer Login";
      });
    }

    if (registerRoleId == "3") {
      setState(() {
        roleRegister = "FitUp Admin Login";
      });
    }
  }

  Widget build(BuildContext context) {
    final FocusNode nullNode = new FocusNode();

    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const PrivacyPolicy();
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: const Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160)))))),
        body: SafeArea(
            child: Container(
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(top: 3, bottom: 3, left: 25),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Hello! Register to get",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700)),
                              const Text("started",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 2),
                              Text("You are registering as $roleRegister",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300))
                            ]),
                      ),
                      SizedBox(child: Container(height: 10)),
                      TextFieldCustom(
                          textController: textUsernameController,
                          obscure_text: false,
                          hint_text_value: "Username",
                          iconPrefix: const Icon(Icons.person_rounded,
                              color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                              color: Colors.transparent)),
                      TextFieldCustom(
                          textController: textEmailController,
                          obscure_text: false,
                          hint_text_value: "Email",
                          iconPrefix:
                              const Icon(Icons.email, color: Colors.black12),
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
                      TextFieldObscureCustom(
                          textController: textPasswordController,
                          hint_text_value: "Password",
                          iconPrefix:
                              const Icon(Icons.lock, color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye)),
                      TextFieldObscureCustom(
                          textController: textRetryPasswordController,
                          hint_text_value: "Confirm Password",
                          iconPrefix:
                              const Icon(Icons.lock, color: Colors.black12),
                          iconSuffix: const Icon(Icons.remove_red_eye)),
                      SizedBox(child: Container(height: 15)),
                      GestureDetector(
                        onTap: () {
                          signUpWithEmail(
                              textUsernameController.text,
                              textEmailController.text,
                              textPhoneController.text,
                              textPasswordController.text,
                              textRetryPasswordController.text,
                              registerRoleId ?? "",
                              passwordFocusNode ?? nullNode,
                              retryPasswordFocusNode ?? nullNode,
                              context);
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
                                child: const Text("Register",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)))),
                      ),
                      Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  height: 1,
                                  width:
                                      MediaQuery.of(context).size.width / 3.2,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          199, 118, 10, 160))),
                              Text("Or Register With",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black26)),
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  height: 1,
                                  width:
                                      MediaQuery.of(context).size.width / 3.2,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          199, 118, 10, 160))),
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
                                          color: const Color.fromARGB(
                                              199, 118, 10, 160)),
                                      margin: const EdgeInsets.all(10),
                                      height: 50,
                                      width: MediaQuery.of(context).size.width /
                                          3.8,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  199, 118, 10, 160),
                                              width: 1.0,
                                              style: BorderStyle.solid))),
                                  Container(
                                      padding: const EdgeInsets.all(14),
                                      child: SvgPicture.asset(
                                          "assets/svg/googlelogo1.svg",
                                          color: const Color.fromARGB(
                                              199, 118, 10, 160),
                                          height: 12,
                                          width: 12),
                                      margin: const EdgeInsets.all(10),
                                      height: 50,
                                      width: MediaQuery.of(context).size.width /
                                          3.8,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  199, 118, 10, 160),
                                              width: 1.0,
                                              style: BorderStyle.solid))),
                                  GestureDetector(
                                      onTap: () {
                                        // Navigator.pushReplacement(context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) {
                                        //   return const UserMainMenu();
                                        // }));
                                      },
                                      child: Container(
                                          child: Icon(Icons.apple,
                                              color: const Color.fromARGB(
                                                  199, 118, 10, 160)),
                                          margin: const EdgeInsets.all(10),
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.8,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      199, 118, 10, 160),
                                                  width: 1.0,
                                                  style: BorderStyle.solid))))
                                ])),
                            SizedBox(
                                height: MediaQuery.of(context).size.height -
                                    (MediaQuery.of(context).size.height *
                                        0.50)),
                            Container(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                  Text("Already have an account? ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12,
                                          color: Colors.black87)),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return SignInAs();
                                        }));
                                      },
                                      child: Text("Login Now",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  199, 118, 10, 160))))
                                ])),
                          ])
                    ]))));
  }
}
