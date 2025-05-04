import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserPremiumSubscriptionDone extends StatefulWidget {
  const UserPremiumSubscriptionDone({super.key});

  @override
  State<UserPremiumSubscriptionDone> createState() =>
      userPremiumSubscriptionDoneState();
}

class userPremiumSubscriptionDoneState
    extends State<UserPremiumSubscriptionDone> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  String? planString;
  String? rateString;

  void initState() {}

  void _toggleWidthPlan() {
    setState(() {
      _widthPlan = _widthPlan == 280 ? _widthPlan = 0 : _widthPlan = 280;

      if (isSelectedPlanOne == true) {
        planString = "1 Month";
        rateString = "PHP 275/Month";
      } else if (isSelectedPlanTwo == true) {
        planString = "3 Months";
        rateString = "PHP 515 for 3 Months";
      } else if (isSelectedPlanThree == true) {
        planString = "6 Months";
        rateString = "PHP 1,625 for 6 Months";
      } else {
        planString = "";
        rateString = "";
      }
    });
  }

  void _togglePlanButtonOne() {
    setState(() {
      isSelectedPlanOne = !isSelectedPlanOne;

      isSelectedPlanThree = false;
      isSelectedPlanTwo = false;
    });
  }

  void _togglePlanButtonTwo() {
    setState(() {
      isSelectedPlanTwo = !isSelectedPlanTwo;

      isSelectedPlanOne = false;
      isSelectedPlanThree = false;
    });
  }

  void _togglePlanButtonThree() {
    setState(() {
      isSelectedPlanThree = !isSelectedPlanThree;

      isSelectedPlanOne = false;
      isSelectedPlanTwo = false;
    });
  }

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
                              selectedInitIndex: 0, subSelectedInitIndex: 0);
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
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Text("Fit Up Premium",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white),
                            textAlign: TextAlign.center))
                  ]),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView(children: [
                    Visibility(
                      visible: true,
                      child: Container(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                    textAlign: TextAlign.left,
                                    "Elevate your fitness journey\nwith seamless bookings.\nSubscribe now for limitles\n gains!",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white))),
                            Container(
                                padding:
                                    const EdgeInsets.only(right: 0, top: 35),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: const EdgeInsets.only(
                                                    top: 3, right: 3),
                                                child: Icon(Icons.diamond,
                                                    color: Colors.cyan,
                                                    size: 18)),
                                            Text.rich(
                                              TextSpan(
                                                  text: ' Exclusive Deals:',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Enjoy special discounts\nand offers',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                  ]),
                                            )
                                          ]),
                                      SizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: const EdgeInsets.only(
                                                    top: 3, right: 3),
                                                child: Icon(Icons.diamond,
                                                    color: Colors.cyan,
                                                    size: 18)),
                                            Text.rich(
                                              TextSpan(
                                                  text:
                                                      ' Personalized Recommendations:',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Enjoy special\ndiscountsand offers reserved for subscribers.',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                  ]),
                                            )
                                          ]),
                                      SizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: const EdgeInsets.only(
                                                    top: 3, right: 3),
                                                child: Icon(Icons.diamond,
                                                    color: Colors.cyan,
                                                    size: 18)),
                                            Text.rich(
                                              TextSpan(
                                                  text: ' Ad Free Experience:',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Subscribe for ad-free\naccess and seamless bookings',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                  ]),
                                            )
                                          ]),
                                      SizedBox(height: 10),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding: const EdgeInsets.only(
                                                    top: 3, right: 3),
                                                child: Icon(Icons.diamond,
                                                    color: Colors.cyan,
                                                    size: 18)),
                                            Text.rich(
                                              TextSpan(
                                                  text:
                                                      ' Community Engagement:',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Connect with\nlike-minded fitness enthusiasts and\nstay motivated together',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                  ]),
                                            )
                                          ]),
                                    ])),
                            SizedBox(height: 65),
                            Container(
                                child: Column(children: [
                              Text("Choose your own plan",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))
                            ])),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonOne();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelectedPlanOne
                                              ? Color.fromARGB(
                                                  198, 212, 45, 198)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black87),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                            isSelectedPlanOne
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanOne
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("1 Month",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text("PHP 275",
                                            style:
                                                TextStyle(color: Colors.white))
                                      ])),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonTwo();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelectedPlanTwo
                                              ? Color.fromARGB(
                                                  198, 212, 45, 198)
                                              : Colors.white,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black87),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                            isSelectedPlanTwo
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanTwo
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("3 Months",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text("PHP 515",
                                            style:
                                                TextStyle(color: Colors.white))
                                      ])),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonThree();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelectedPlanThree
                                              ? Color.fromARGB(
                                                  198, 212, 45, 198)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black87),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                            isSelectedPlanThree
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanThree
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("6 Months",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text("PHP 1,635",
                                            style:
                                                TextStyle(color: Colors.white))
                                      ])),
                            ),
                            SizedBox(height: 50),
                            GestureDetector(
                              onTap: () {
                                _toggleWidthPlan();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(
                                      left: 40, right: 40, top: 15, bottom: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(197, 241, 38, 224)),
                                  child: Text("Go Premium",
                                      style: TextStyle(color: Colors.white))),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return UserMainMenu(
                                        selectedInitIndex: 0,
                                        subSelectedInitIndex: 0);
                                  }));
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                        left: 40,
                                        right: 40,
                                        top: 15,
                                        bottom: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text("No thanks",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                197, 241, 38, 224)))))
                          ],
                        ),
                      ),
                    )
                  ]),
                )
              ]))),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Visibility(
            visible: true,
            child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 100),
                padding: const EdgeInsets.all(20),
                height: _widthPlan,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: Colors.black87),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child:
                                Icon(Icons.close, color: Colors.transparent)),
                        Container(
                            child: Text("Fit Up Premium ${planString}",
                                style: TextStyle(color: Colors.white))),
                        GestureDetector(
                            onTap: () {
                              _toggleWidthPlan();
                            },
                            child: Container(
                                child: Icon(Icons.close, color: Colors.white)))
                      ]),
                  SizedBox(height: 30),
                  Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        Text("Starting today",
                            style: TextStyle(color: Colors.white)),
                        Text("${rateString}",
                            style: TextStyle(color: Colors.white))
                      ])),
                  SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return UserMainMenu(
                            selectedInitIndex: 0, subSelectedInitIndex: 41);
                      }));
                    },
                    child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 25, left: 75, right: 75),
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(197, 241, 38, 224)),
                        child: Text("Add Payment Methods",
                            style: TextStyle(color: Colors.white))),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 5, left: 40, right: 40),
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, top: 15, bottom: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(197, 241, 38, 224)),
                        child: Text("Subscribe",
                            style: TextStyle(color: Colors.white))),
                  ),
                ])),
          ))
    ]));
  }
}
