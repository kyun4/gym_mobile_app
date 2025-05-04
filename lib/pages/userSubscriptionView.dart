import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserSubscriptionView extends StatefulWidget {
  const UserSubscriptionView({super.key});

  @override
  State<UserSubscriptionView> createState() => _userSubscriptionViewState();
}

class _userSubscriptionViewState extends State<UserSubscriptionView> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            title: Text("1 month subscriber",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const UserMainMenu(
                        selectedInitIndex: 2, subSelectedInitIndex: 0);
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160)))))),
        body: Stack(children: [
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2)),
                  child: Image.asset("assets/images/giftcoupons1.png"))),
          Positioned.fill(
              child: Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 250),
                  child: Image.asset("assets/images/subscribeabstract1.png",
                      fit: BoxFit.cover))),
          Positioned.fill(
              child: Container(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 270,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Column(children: [
                  Text("Are you a 1 month subscriber?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text(
                      "Unlock a month of boundless fitness possibilities with our subscription service! Get exclusive access to a myriad of fitness classes, all at your fingertips. With our user-friendly booking app, you can effortlessly schedule your favorite classes at top-rated studios in your area. Dive into a month of wellness and discovery, as you explore new fitness modalities, connect with like-minded enthusiasts, and embark on a journey towards a healthier, happier you. Join the fitness revolution today!",
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 15),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const UserMainMenu(
                                  selectedInitIndex: 2,
                                  subSelectedInitIndex: 16);
                            }));
                          },
                          child: Container(
                              width: 175,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      const Color.fromARGB(255, 189, 12, 159)),
                              child: Text("See rewards",
                                  style: TextStyle(color: Colors.white))),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const UserMainMenu(
                                  selectedInitIndex: 2,
                                  subSelectedInitIndex: 16);
                            }));
                          },
                          child: Container(
                              width: 175,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      const Color.fromARGB(255, 189, 12, 159)),
                              child: Text("See discounts",
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ])
                ]),
              ),
            ],
          )))
        ]));
  }
}
