import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:flutter_svg/svg.dart';

class UserPremiumSubscriptionPaymentThankYou extends StatefulWidget {
  const UserPremiumSubscriptionPaymentThankYou({super.key});

  @override
  State<UserPremiumSubscriptionPaymentThankYou> createState() =>
      userPremiumSubscriptionPaymentThankYouState();
}

class userPremiumSubscriptionPaymentThankYouState
    extends State<UserPremiumSubscriptionPaymentThankYou> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  bool isSelectedPlanFour = false;
  String? planString;
  String? rateString;

  void initState() {}

  Widget build(BuildContext) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Image.asset("assets/images/gymbg2.png", fit: BoxFit.cover)),
      Positioned.fill(
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, top: 20),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return UserMainMenu(
                              selectedInitIndex: 0, subSelectedInitIndex: 40);
                        }));
                      },
                      child: Container(
                          margin: const EdgeInsets.all(25),
                          padding: const EdgeInsets.all(5),
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.withOpacity(0.8)),
                          child: Container(
                              padding: const EdgeInsets.only(left: 7),
                              child: Icon(Icons.arrow_back_ios))),
                    ),
                    Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Text("Payment",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white),
                            textAlign: TextAlign.center))
                  ]),
                ),
                SizedBox(height: 30),
                Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2, color: Color.fromARGB(199, 167, 10, 180)),
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black87),
                    child: Icon(Icons.check,
                        color: Color.fromARGB(199, 167, 10, 180), size: 60)),
                SizedBox(height: 50),
                Container(
                    child: Text("Thank you for upgrading to FitUp Premium!",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                Container(
                    padding:
                        const EdgeInsets.only(top: 40, left: 65, right: 65),
                    child: Text(
                        "Get ready to experience seamless gym bookings, personalized workouts, and exclusive perks. Let's elevate your fitness journey together!",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300))),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMainMenu(
                          selectedInitIndex: 0, subSelectedInitIndex: 43);
                    }));
                  },
                  child: Container(
                      margin:
                          const EdgeInsets.only(top: 40, left: 60, right: 60),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, top: 15, bottom: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(197, 241, 38, 224)),
                      child: Text("Continue",
                          style: TextStyle(color: Colors.white))),
                ),
              ]))),
    ]));
  }
}
