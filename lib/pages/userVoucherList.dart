import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:flutter_dash/flutter_dash.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserVoucherList extends StatefulWidget {
  const UserVoucherList({super.key});

  @override
  State<UserVoucherList> createState() => _userVoucherListState();
}

class _userVoucherListState extends State<UserVoucherList> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            title: Text("Reward Lists",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const UserMainMenu(
                        selectedInitIndex: 2, subSelectedInitIndex: 15);
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
        body: Container(
            padding: const EdgeInsets.only(top: 25),
            child: Container(
                child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: Row(children: [
                            Container(
                                width: 55,
                                child: Icon(Icons.verified_rounded, size: 35)),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.69,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Optimum Nutrition",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("Gold",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("Ends Mar 1, 2025",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    Text("Claim Voucher",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 189, 12, 159),
                                            fontSize: 12))
                                  ]),
                            ),
                          ])),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          margin: const EdgeInsets.only(
                              right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          width: 30,
                          child: Dash(
                              direction: Axis.vertical,
                              length: 75,
                              dashLength: 10,
                              dashColor: Colors.purple,
                              dashThickness: 1))
                    ],
                  ),
                );
              },
            )),
            decoration:
                BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2))));
  }
}
