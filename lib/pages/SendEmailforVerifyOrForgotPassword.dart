import 'package:flutter/material.dart';
import 'package:fitup/pages/signInAs.dart';
import 'package:fitup/pages/SendOTP.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/components/textFieldFocusNode.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class SendEmailForVerifyOrForgotPassword extends StatefulWidget {
  final String roleId;
  const SendEmailForVerifyOrForgotPassword({super.key, required this.roleId});

  State<SendEmailForVerifyOrForgotPassword> createState() =>
      _sendEmailForVerifyOrForgotPasswordState();
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

Future<String> getOTPByFirebaseEmail(String firebaseEmail) async {
  String? otp;
  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['email'] == firebaseEmail) {
        otp = json['otp'] ?? "";
      }
    });
  } catch (error) {
    throw error;
  }
  return otp ?? "";
} // getOTPByFirebaseEmail

Future<String> getFirebaseUIDByFirebaseEmail(String firebaseEmail) async {
  String? firebaseuid;
  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['email'] == firebaseEmail) {
        firebaseuid = json['firebase_uid'] ?? "";
      }
    });
  } catch (error) {
    throw error;
  }
  return firebaseuid ?? "";
} // getFirebaseUIDByFirebaseEmail

Future<String> getEmailVerificationStatusByFirebaseEmail(
    String firebaseEmail) async {
  String? emailVerified;
  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['email'] == firebaseEmail) {
        emailVerified = json['email_verified'] ?? "";
      }
    });
  } catch (error) {
    throw error;
  }
  return emailVerified ?? "";
} // getEmailVerificationStatusByFirebaseEmail

sendEmail(String emailSend, String username, String otp, context) async {
  // SMTP server configuration
  final smtpServer = gmail('fitupmobile@gmail.com', 'ofbm ddkq oeru gkml');

  // Create the message
  final message = Message()
    ..from = Address('fitupmobile@gmail.com', 'Fit Up')
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(p.code.toString() + " " + p.msg.toString())));
    }
  }
} // sendEmail

class _sendEmailForVerifyOrForgotPasswordState
    extends State<SendEmailForVerifyOrForgotPassword> {
  TextEditingController textEmailController = new TextEditingController();
  String? textTitle, textSubtitle, textButtonLabel, textWarning;
  String? roleIDValue;

  FocusNode emailFocusNode = new FocusNode();
  bool buttonVisibility = false;

  void initState() {
    super.initState();
    setState(() {
      textTitle = "Forgot Password";
      textSubtitle = "Enter email address you have registered";
      textButtonLabel = "Send Email";
      roleIDValue = widget.roleId;
    });
    getSharedPreferencesValues();

    textEmailController.addListener(emailTextListener);
  }

  void emailTextListener() async {
    bool emailFormatValid = false;
    String? isEmailVerified;

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(textEmailController.text.toString().trim())) {
      setState(() {
        emailFormatValid = false;
        textWarning = "Email Address format is invalid";
      });
    } else {
      setState(() {
        emailFormatValid = true;
        textWarning = "";
      });
    }

    if (textWarning!.isEmpty) {
      setState(() {
        buttonVisibility = true;
      });
    } else {
      setState(() {
        buttonVisibility = false;
      });
    }
  } // emailTextListener

  void getSharedPreferencesValues() async {
    String? textTitleValue = await getSession("send_email_title");
    String? textSubtitleValue = await getSession("send_email_subtitle");
    String? textButtonLabelValue = await getSession("send_email_button_label");
    setState(() {
      textTitle = textTitleValue;
      textSubtitle = textSubtitleValue;
      textButtonLabel = textButtonLabelValue;
    });
  } // getSharedPreferencesValues

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Text(textTitle ?? "",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(textSubtitle ?? "",
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                SizedBox(height: 15),
                TextFieldFocusNode(
                    textController: textEmailController,
                    fieldFocusNode: emailFocusNode,
                    obscure_text: false,
                    hint_text_value: "Email Address",
                    iconPrefix: const Icon(Icons.email, color: Colors.black12),
                    iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                        color: Colors.transparent)),
                Center(
                    child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Text(textWarning ?? "",
                            style: TextStyle(fontSize: 12)))),
                Visibility(
                  visible: buttonVisibility,
                  child: GestureDetector(
                    onTap: () async {
                      // String otp = "000111";

                      String otp = await getOTPByFirebaseEmail(
                          textEmailController.text.toString().trim());

                      setSession("otp", otp);

                      String email_verified =
                          await getEmailVerificationStatusByFirebaseEmail(
                              textEmailController.text.toString().trim());

                      String fuid = await getFirebaseUIDByFirebaseEmail(
                          textEmailController.text.toString().trim());

                      setSession("firebase_uid", fuid);

                      if (email_verified! == "false") {
                        setState(() {
                          textWarning = "";
                        });
                      } else if (email_verified! == "true") {
                        setState(() {
                          textWarning = "Email already verified";
                        });
                      } else {
                        setState(() {
                          textWarning = "Not yet registered";
                        });
                      }

                      if (textWarning!.isEmpty) {
                        sendEmail(
                            textEmailController.text.toString().trim(),
                            textEmailController.text.toString().trim(),
                            otp,
                            context);

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return SendOTP(roleIdSelected: roleIDValue ?? "");
                        }));
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(199, 118, 10, 160)),
                        child: Text(textButtonLabel ?? "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                            color:
                                const Color.fromARGB(199, 118, 10, 160)))))));
  }
}
