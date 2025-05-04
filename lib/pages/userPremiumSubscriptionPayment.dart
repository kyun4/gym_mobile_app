import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserPremiumSubscriptionPayment extends StatefulWidget {
  const UserPremiumSubscriptionPayment({super.key});

  @override
  State<UserPremiumSubscriptionPayment> createState() =>
      userPremiumSubscriptionPaymentState();
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

void addPaymentMethodGCash(String firebaseUid, String accountNumber) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "user_payment_method/$firebaseUid.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "gcash": accountNumber,
          "gcash_date_time_add": date_time_formatted,
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid,
          "credit_card": "",
          "credit_card_cvc": "",
          "credit_card_date_time_add": "",
          "credit_card_expiry": "",
          "apple_pay": "",
          "apple_pay_date_time_add": "",
        }));
  } catch (error) {
    throw Error;
  }
} // addPaymentMethodGCash

void addPaymentMethodCreditCard(
    String firebaseUid, String accountNumber, String expiry, String cvc) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "user_payment_method/$firebaseUid.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "gcash": accountNumber,
          "gcash_date_time_add": date_time_formatted,
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid,
          "credit_card": accountNumber,
          "credit_card_cvc": cvc,
          "credit_card_date_time_add": date_time_formatted,
          "credit_card_expiry": expiry,
          "apple_pay": "",
          "apple_pay_date_time_add": "",
          "user_id": firebaseUid,
          "user_payment_method_id": firebaseUid
        }));
  } catch (error) {
    throw Error;
  }
} // addPaymentMethodCreditCard

class userPremiumSubscriptionPaymentState
    extends State<UserPremiumSubscriptionPayment> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  bool isSelectedPlanFour = false;
  String? planString;
  String? rateString;
  String? paymentMethodSelected;
  String? subscriptionPlanId;
  String? firebaseUID;
  String? gcashNumber;
  TextEditingController GCashTextController = TextEditingController();
  TextEditingController creditCardNumberTextController =
      TextEditingController();
  TextEditingController cvcTextController = TextEditingController();
  TextEditingController expiryDateTextController = TextEditingController();

  void initState() {
    firebaseUID = FirebaseAuth.instance.currentUser?.uid.toString();
    getSubscriptionPlan();
  } // initState()

  void getSubscriptionPlan() async {
    String? subIndex = await getSession("premium_plan");
    subscriptionPlanId = "subscription_plan_id_" + subIndex! + "";
  } // getSubscriptionPlan

  void _toggleWidthPlan() {
    setState(() {
      _widthPlan = _widthPlan == 280 ? _widthPlan = 0 : _widthPlan = 280;
    });
  }

  void _togglePlanButtonOne() {
    setState(() {
      isSelectedPlanOne = !isSelectedPlanOne;

      isSelectedPlanThree = false;
      isSelectedPlanTwo = false;
      isSelectedPlanFour = false;

      paymentMethodSelected = "Credit Card";

      setSession("selected_payment_method", "Credit Card");
    });
  }

  void _togglePlanButtonTwo() {
    setState(() {
      isSelectedPlanTwo = !isSelectedPlanTwo;

      isSelectedPlanOne = false;
      isSelectedPlanThree = false;
      isSelectedPlanFour = false;

      paymentMethodSelected = "Paypal";

      setSession("selected_payment_method", "Paypal");
    });
  }

  void _togglePlanButtonThree() {
    setState(() {
      isSelectedPlanThree = !isSelectedPlanThree;

      isSelectedPlanOne = false;
      isSelectedPlanTwo = false;
      isSelectedPlanFour = false;

      paymentMethodSelected = "Apple Pay";

      setSession("selected_payment_method", "Apple Pay");
    });
  }

  void _togglePlanButtonFour() {
    setState(() {
      isSelectedPlanFour = !isSelectedPlanFour;

      isSelectedPlanOne = false;
      isSelectedPlanTwo = false;
      isSelectedPlanThree = false;

      paymentMethodSelected = "GCash";

      setSession("selected_payment_method", "GCash");
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
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Text("Payment",
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
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonOne();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(12),
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
                                                ? Icons.credit_card
                                                : Icons.credit_card,
                                            color: isSelectedPlanOne
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("Credit Card",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Icon(
                                            isSelectedPlanOne
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanOne
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                      ])),
                            ),
                            Visibility(
                              visible: isSelectedPlanOne ? true : false,
                              child: Container(
                                  height: 165,
                                  margin: const EdgeInsets.only(
                                      top: 15, bottom: 15),
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  padding: const EdgeInsets.only(
                                      left: 25, top: 20, right: 25),
                                  decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Card Information",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white)),
                                        SizedBox(height: 15),
                                        Container(
                                            height: 75,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: TextField(
                                                        controller:
                                                            creditCardNumberTextController,
                                                        keyboardType: TextInputType
                                                            .number,
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets.all(
                                                                    8.5),
                                                            suffixIcon: SvgPicture.asset(
                                                                "assets/svg/visa-svgrepo-com.svg"),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            enabledBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            hintStyle: TextStyle(
                                                                color: Colors.black45),
                                                            hintText: "Credit Card Number")),
                                                  ),
                                                  Container(
                                                      height: 1,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 2,
                                                              bottom: 2),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.black87)),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            height: 20,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.30,
                                                            child: TextField(
                                                                controller:
                                                                    expiryDateTextController,
                                                                decoration: InputDecoration(
                                                                    contentPadding: const EdgeInsets.all(5),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white)),
                                                                    hintStyle: TextStyle(color: Colors.black45),
                                                                    hintText: "MM/YY")),
                                                          ),
                                                          Container(
                                                              height: 30,
                                                              width: 1,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .black87)),
                                                          Container(
                                                            height: 20,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.3,
                                                            child: TextField(
                                                                controller:
                                                                    cvcTextController,
                                                                decoration: InputDecoration(
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .credit_card),
                                                                    contentPadding:
                                                                        const EdgeInsets.all(
                                                                            5),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color: Colors
                                                                                .white)),
                                                                    enabledBorder: OutlineInputBorder(
                                                                        borderSide: const BorderSide(
                                                                            color: Colors
                                                                                .white)),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black45),
                                                                    hintText:
                                                                        "CVC")),
                                                          ),
                                                        ]),
                                                  )
                                                ])),
                                      ])),
                            ),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonTwo();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(top: 5),
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
                                                ? Icons.paypal
                                                : Icons.paypal,
                                            color: isSelectedPlanTwo
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("Paypal",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Icon(
                                            isSelectedPlanTwo
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanTwo
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                      ])),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonThree();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(12),
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
                                                ? Icons.apple_sharp
                                                : Icons.apple_sharp,
                                            color: isSelectedPlanThree
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                        Text("Apple Pay",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Icon(
                                            isSelectedPlanThree
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanThree
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                      ])),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _togglePlanButtonFour();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelectedPlanFour
                                              ? Color.fromARGB(
                                                  198, 212, 45, 198)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black87),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/svg/gcash-svgrepo-com.svg",
                                          height: 18,
                                          color: isSelectedPlanFour
                                              ? Color.fromARGB(
                                                  198, 212, 45, 198)
                                              : Colors.white,
                                        ),
                                        Text("GCash",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Icon(
                                            isSelectedPlanFour
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelectedPlanFour
                                                ? Color.fromARGB(
                                                    198, 212, 45, 198)
                                                : Colors.white,
                                            size: 15),
                                      ])),
                            ),
                            Visibility(
                              visible: isSelectedPlanFour ? true : false,
                              child: Container(
                                  height: 125,
                                  margin: const EdgeInsets.only(
                                      top: 15, bottom: 15),
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  padding: const EdgeInsets.only(
                                      left: 25, top: 20, right: 25),
                                  decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("GCash Registered Number",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white)),
                                        SizedBox(height: 15),
                                        Container(
                                            height: 50,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: TextField(
                                                        controller:
                                                            GCashTextController,
                                                        keyboardType: TextInputType
                                                            .number,
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(8.5),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .white)),
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black45),
                                                            hintText:
                                                                "Registered GCash Phone Number")),
                                                  ),
                                                ])),
                                      ])),
                            ),
                            SizedBox(height: 50),
                            GestureDetector(
                              onTap: () {
                                String gcashNumber = "";
                                String creditCardNumber = "";
                                String cvc = "";
                                String expiryDate = "";

                                if (paymentMethodSelected == 'GCash') {
                                  gcashNumber = GCashTextController.text;

                                  addPaymentMethodGCash(
                                      firebaseUID ?? "", gcashNumber);
                                } // paymentMethodSelected GCash

                                if (paymentMethodSelected == 'Credit Card') {
                                  creditCardNumber =
                                      creditCardNumberTextController.text;

                                  cvc = cvcTextController.text;

                                  expiryDate = expiryDateTextController.text;

                                  addPaymentMethodCreditCard(firebaseUID ?? "",
                                      creditCardNumber, cvc, expiryDate);
                                } // paymentMethodSelected Credit Card

                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return UserMainMenu(
                                      selectedInitIndex: 0,
                                      subSelectedInitIndex: 40);
                                }));
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(
                                      left: 40, right: 40, top: 15, bottom: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(197, 241, 38, 224)),
                                  child: Text("Choose this Payment Method",
                                      style: TextStyle(color: Colors.white))),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                )
              ]))),
    ]));
  }
}
