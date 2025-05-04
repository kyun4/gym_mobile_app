import 'package:flutter/material.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fitup/pages/signUpAs.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final ScrollController _scrollTextController = ScrollController();
  String? privacyPolicyText;

  bool _hasReachedEnd = false;

  void initState() {
    super.initState();

    StringBuffer bufferPolicy = StringBuffer();
    bufferPolicy.write(
        "1. Types of data we collect\n\nIn our gym booking application, we diligently collect various types of personal data to ensure seamless service provision. This encompasses essential information such as names, contact details, dates of birth, and pertinent health details crucial for crafting tailored fitness regimens. Furthermore, we may also gather usage data, including IP addresses and cookies, to enhance the functionality and user experience of our platform while ensuring compliance with Philippine data privacy laws.");
    bufferPolicy.write(
        "\n\n\n\n2. Use of your personal data\n\nPersonal data is used to facilitate gym bookings, communicate updates, and personalize user experiences. Health information is strictly utilized for fitness assessments and ensuring safety during workouts. We do not use personal data for marketing without explicit consent.");
    bufferPolicy.write(
        "\n\n\n\n3. Discolosure of your personal data\n\nTransparency and accountability govern our practices concerning the disclosure of personal data. While we may engage trusted third-party service providers to facilitate operational functions such as payment processing or customer support, we do not compromise on safeguarding user privacy. Under no circumstances do we engage in selling or renting personal data to external entities. Any disclosure of personal data is strictly limited to situations necessitated by legal obligations or vital interests, ensuring compliance with Philippine laws and regulations while prioritizing the rights and safety of our valued users.");

    privacyPolicyText = bufferPolicy.toString();

    _scrollTextController.addListener(() {
      if (_scrollTextController.position.atEdge) {
        bool isEnd = _scrollTextController.position.pixels ==
            _scrollTextController.position.maxScrollExtent;

        if (isEnd) {
          setState(() {
            _hasReachedEnd = true;
          });
        } else {
          setState(() {
            _hasReachedEnd = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Privacy and Policy",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: const Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160)))))),
        body: Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if (_hasReachedEnd) {}

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return SignUpAs();
                }));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            controller: _scrollTextController,
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(privacyPolicyText ?? "Loading ...",
                                    style: TextStyle(fontSize: 12))))),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.82,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      const Color.fromARGB(199, 118, 10, 160)),
                              child: const Text("Continue",
                                  style: TextStyle(color: Colors.white)))
                        ])
                  ]),
            )));
  }
}
