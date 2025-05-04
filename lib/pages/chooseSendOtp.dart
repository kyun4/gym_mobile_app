import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/pages/signUpAs.dart';
import 'package:fitup/pages/accountVerificationRegistration.dart';
import 'package:fitup/components/textField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class ChooseSendOtp extends StatefulWidget {
  final String roleIdSelected;
  const ChooseSendOtp({super.key, required this.roleIdSelected});

  @override
  State<ChooseSendOtp> createState() => _chooseSendOtpState();
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

void sendEmail(String emailSend, String username, String otp, context) async {
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

class _chooseSendOtpState extends State<ChooseSendOtp> {
  User? user = FirebaseAuth.instance.currentUser;
  final textEmailController = TextEditingController();
  String? emailGet;
  String? phoneGet;
  String? selectedRoleID;
  String? fullname;
  String? otp;
  bool isEmail = true;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const SignUpAs();
    }));
  }

  void getSharedPreferencesValues() async {
    String? fullNameValue = await getSession("fullname");
    String? phoneNumberValue = await getSession("phone");
    String? otpValue = await getSession("otp");
    setState(() {
      fullname = fullNameValue;
      otp = otpValue;
      phoneGet = phoneNumberValue;
    });
  } // getSharedPreferencesValues

  @override
  void initState() {
    super.initState();
    emailGet = user?.email;

    selectedRoleID = widget.roleIdSelected;
    getSharedPreferencesValues();

    textEmailController.text = isEmail ? emailGet ?? "" : phoneGet ?? "";
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Account Authentication",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  // Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) {
                  //   return Splash();
                  // }));
                  signOut();
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
              margin: const EdgeInsets.only(left: 30, top: 20),
              child: const Text(
                  "Please choose where to send your\nauthentication code",
                  style: TextStyle(fontSize: 18))),
          SizedBox(height: 25),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEmail = true;
                });

                textEmailController.text =
                    isEmail ? emailGet ?? "" : phoneGet ?? "";
              },
              child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isEmail
                          ? Color.fromARGB(199, 118, 10, 160)
                          : Color.fromARGB(198, 243, 231, 247)),
                  child: isEmail
                      ? const Text("Email",
                          style: TextStyle(color: Colors.white))
                      : const Text("Email",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 104, 90, 110)))),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEmail = false;
                });

                textEmailController.text =
                    isEmail ? emailGet ?? "" : phoneGet ?? "";
              },
              child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isEmail
                          ? Color.fromARGB(198, 243, 231, 247)
                          : Color.fromARGB(199, 118, 10, 160)),
                  child: isEmail
                      ? const Text("Phone",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 104, 90, 110)))
                      : const Text("Phone",
                          style: TextStyle(color: Colors.white))),
            ),
          ]),
          TextFieldCustom(
              textController: textEmailController,
              obscure_text: false,
              hint_text_value: isEmail ? "example@gmail.com" : "09XXXXXXXXX",
              iconPrefix: isEmail
                  ? const Icon(Icons.email, color: Colors.black12)
                  : const Icon(Icons.phone_android, color: Colors.black12),
              iconSuffix: const Icon(Icons.remove_red_eye_rounded,
                  color: Colors.transparent)),
          GestureDetector(
            onTap: () {
              setSession("otp", otp ?? "");

              if (isEmail) {
                sendEmail(textEmailController.text, fullname ?? "", otp ?? "",
                    context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP is sent to your phone")));
              }

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return AccountVerificationRegistration(
                    roleIdSelected: selectedRoleID ?? "");
              }));
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(199, 118, 10, 160)),
                child: const Text("Send OTP",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
          ),
        ])));
  }
}
