import 'package:flutter/material.dart';
import 'package:fitup/pages/getVoucherSplash.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class QualityTrainerSplash extends StatefulWidget {
  const QualityTrainerSplash({super.key});

  State<QualityTrainerSplash> createState() => _qualityTrainerSplash();
}

class _qualityTrainerSplash extends State<QualityTrainerSplash> {
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/qualitytrainers1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(0.7), // Black color with 50% opacity
            ),
          ),
          // Overlay content (text in this case)
          Container(
              margin: const EdgeInsets.only(bottom: 85),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                            alignment: Alignment.bottomLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text("\nQuality Trainers",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 25)))),
                    SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                            alignment: Alignment.bottomLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            child: const Text(
                                "Experts in different field helping to\nachieve your fitness goals",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)))),
                    SizedBox(height: 35),
                    Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 262),
                          Container(
                              height: 5.5,
                              width: 20,
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2.5, bottom: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3.5))),
                          Container(
                              height: 5.5,
                              width: 35,
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2.5, bottom: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3.5))),
                          Container(
                              height: 5.5,
                              width: 20,
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2.5, bottom: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3.5))),
                          SizedBox(
                              width: MediaQuery.of(context).size.width - 262),
                        ])),
                    SizedBox(height: 35),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(_createRouteGetVouchers());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: MediaQuery.of(context).size.width - 85,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(199, 167, 10, 180)),
                          child: const Text("Get started",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                )
              ])),
        ],
      ),
    );
  }

  Route _createRouteGetVouchers() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const GetVoucherSplash(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start the animation from the right
        const end = Offset.zero; // End at the current position
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
