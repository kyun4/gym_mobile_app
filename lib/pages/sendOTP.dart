import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/pages/signUpAs.dart';
import 'package:fitup/pages/accountVerified.dart';
import 'package:fitup/components/DigitCustomNumberOnly.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:fitup/pages/SendEmailforVerifyOrForgotPassword.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;
String gmailServer = AppConfig.emailServer;
String gmailServerPass = AppConfig.emailServerPass;

class SendOTP extends StatefulWidget {
  final String roleIdSelected;
  const SendOTP({super.key, required this.roleIdSelected});

  @override
  State<SendOTP> createState() => _sendOTPState();
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

class _sendOTPState extends State<SendOTP> {
  User? user = FirebaseAuth.instance.currentUser;
  String? secondsCount;
  int secondsLimit = 60;
  int currentSeconds = 0;

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  FocusNode _focusNode4 = FocusNode();
  FocusNode _focusNode5 = FocusNode();
  FocusNode _focusNode6 = FocusNode();
  FocusNode _focusButton = FocusNode();

  String? emailGet;
  String? roleID;
  String? phoneSend;
  String? usernameGet;
  String? firebaseUID;
  bool buttonFocused = false;
  bool enableTimer = false;
  bool incorrectOTP = false;
  String? correctOTP;

  final textDigit1Controller = TextEditingController();
  final textDigit2Controller = TextEditingController();
  final textDigit3Controller = TextEditingController();
  final textDigit4Controller = TextEditingController();
  final textDigit5Controller = TextEditingController();
  final textDigit6Controller = TextEditingController();

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const SignUpAs();
    }));
  }

  void sendEmail(String emailSend, String username, String otp, context) async {
    // SMTP server configuration
    final smtpServer = gmail(gmailServer, gmailServerPass);

    // Create the message
    final message = Message()
      ..from = Address(gmailServer, 'Fit Up')
      ..recipients.add(emailSend.trim()) // can add more with .addAll()
      ..subject = 'Fit Up OTP for Verification'
      ..text =
          'Welcome to Fit Up, $username!\nThis is your OTP: $otp. \nDO NOT SHARE THIS TO ANYONE';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Email not sent. \n${e.toString()}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(p.code.toString() + " " + p.msg.toString())));
      }
    }
  } // sendEmail

  @override
  void initState() {
    super.initState();

    setState(() {
      roleID = widget.roleIdSelected;
    });

    getSharedPreferencesValues();
    setSession("account_activation", "1");

    if (textDigit1Controller.text == '') {
      _focusNode1.requestFocus();
      buttonFocused = false;
    }

    textDigit6Controller.addListener(_onTextChange);
    textDigit5Controller.addListener(_onTextChange);
    textDigit4Controller.addListener(_onTextChange);
    textDigit3Controller.addListener(_onTextChange);
    textDigit2Controller.addListener(_onTextChange);
    textDigit1Controller.addListener(_onTextChange);

    // _focusButton.addListener(() {});
  }

  void getSharedPreferencesValues() async {
    String? otp = await getSession("otp");
    String? phone = await getSession("phone");
    String? username = await getSession("fullname");

    setState(() {
      correctOTP = otp;
      phoneSend = phone;
      usernameGet = username;
    });
  } // getSharedPreferencesValues

  void _onTextChange() {
    if (textDigit6Controller.text != '' &&
        textDigit5Controller.text != '' &&
        textDigit4Controller.text != '' &&
        textDigit3Controller.text != '' &&
        textDigit2Controller.text != '' &&
        textDigit1Controller.text != '') {
      setState(() {
        buttonFocused = true;
      });
    } else {
      setState(() {
        buttonFocused = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Account Verification",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SendEmailForVerifyOrForgotPassword(
                        roleId: widget.roleIdSelected);
                  }));
                },
                child: Container(
                    height: 25,
                    width: 75,
                    child: Container(
                        child: Icon(Icons.arrow_back,
                            color: Color.fromARGB(199, 118, 10, 160)),
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color.fromARGB(
                                    199, 118, 10, 160))))))),
        body: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20),
              child: const Text(
                  "Enter 6-Digit verification code sent to your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16))),
          SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DigitCustomNumberOnly(
                    textDigitController: textDigit1Controller,
                    focusNode: _focusNode1,
                    focusNextNode: _focusNode2),
                DigitCustomNumberOnly(
                    textDigitController: textDigit2Controller,
                    focusNode: _focusNode2,
                    focusNextNode: _focusNode3),
                DigitCustomNumberOnly(
                    textDigitController: textDigit3Controller,
                    focusNode: _focusNode3,
                    focusNextNode: _focusNode4),
                DigitCustomNumberOnly(
                    textDigitController: textDigit4Controller,
                    focusNode: _focusNode4,
                    focusNextNode: _focusNode5),
                DigitCustomNumberOnly(
                    textDigitController: textDigit5Controller,
                    focusNode: _focusNode5,
                    focusNextNode: _focusNode6),
                DigitCustomNumberOnly(
                    textDigitController: textDigit6Controller,
                    focusNode: _focusNode6,
                    focusNextNode: _focusButton),
              ]),
          Visibility(
            visible: incorrectOTP,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("OTP is incorrect",
                  style: TextStyle(color: Colors.redAccent.withOpacity(0.7)))
            ]),
          ),
          Visibility(
            visible: false,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    //enableTimer = true;
                    sendEmail(emailGet ?? "", usernameGet ?? "",
                        correctOTP ?? "", context);
                  });
                },
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.center,
                    child: Text("Resend Code",
                        style: TextStyle(color: Colors.black45),
                        textAlign: TextAlign.center))),
          ),
          GestureDetector(
            onTap: () {
              if (buttonFocused) {
                String otpInput = "";
                otpInput = textDigit1Controller.text.toString().trim() +
                    "" +
                    textDigit2Controller.text.toString().trim() +
                    "" +
                    textDigit3Controller.text.toString().trim() +
                    "" +
                    textDigit4Controller.text.toString().trim() +
                    "" +
                    textDigit5Controller.text.toString().trim() +
                    "" +
                    textDigit6Controller.text.toString().trim();

                if (correctOTP == otpInput) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return AccountVerified(accountRoleId: roleID ?? "");
                  }));
                } else {
                  setState(() {
                    incorrectOTP = true;
                  });
                }
              }
            },
            child: Visibility(
              visible: buttonFocused ? true : false,
              child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(199, 118, 10, 160)),
                  child: const Text("Confirm",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
            ),
          ),
        ])));
  }
}
