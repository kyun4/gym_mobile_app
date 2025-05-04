import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:provider/provider.dart';
import 'package:fitup/pages/userMainMenu.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserVouchers extends StatefulWidget {
  const UserVouchers({super.key});

  @override
  State<UserVouchers> createState() => _userVouchersState();
}

class _userVouchersState extends State<UserVouchers> {
  void initState() {
    super.initState();
    getProductImages();
  }

  Future<void> getProductImages() async {
    await Provider.of<StorageService>(context, listen: false)
        .fetchProductImages();
  }

  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
        body: Stack(children: [
      Positioned(
          top: 5,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              child: Container(
                  child: SvgPicture.asset("assets/svg/star-rounded-icon.svg",
                      height: 400,
                      color: Colors.purpleAccent.withOpacity(0.2))),
            ),
          )),
      Positioned.fill(
          child: Container(
              decoration:
                  BoxDecoration(color: Color.fromARGB(75, 118, 10, 160)),
              child: Container())),
      Positioned(
        bottom: 15,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                  margin:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Get rewarded",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("See all",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400))
                      ])),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    height: 100,
                    child: ListView.builder(
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white),
                                child: Row(children: [
                                  Container(
                                      width: 55,
                                      child: Icon(Icons.verified_rounded,
                                          size: 35)),
                                  Container(
                                    width: 155,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  color: Colors.amber,
                                                  fontSize: 12))
                                        ]),
                                  ),
                                ])),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 7),
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
                        );
                      },
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          top: 16, left: 25, right: 25, bottom: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Grab Supplement Discounts",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ])),
                  Consumer<StorageService>(
                      builder: (context, storageService, child) {
                    final urlProducts = storageService.productImageUrls;
                    return Container(
                        height: 120,
                        margin: const EdgeInsets.only(left: 20, top: 10),
                        child: ListView.builder(
                            itemCount: storageService.productImageUrls.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Image.network(
                                              urlProducts[index],
                                              fit: BoxFit.cover),
                                          height: 85,
                                          width: 80,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white),
                                        ),
                                        SizedBox(height: 5),
                                        Text("Whey Protein",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        Text("Get Now",
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400))
                                      ]));
                            }));
                  })
                ],
              ),
            ],
          ),
        ),
      ),
      Positioned(
          top: 150,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Center(
                    child: Text("My Vouchers",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 189, 12, 159),
                            fontSize: 42)),
                  ),
                  SizedBox(height: screenHeight / 22),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return UserMainMenu(
                            selectedInitIndex: 2, subSelectedInitIndex: 15);
                      }));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 189, 12, 159)),
                        width: 155,
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: Text("View",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                  )
                ])),
          )),
    ]));
  }
}
