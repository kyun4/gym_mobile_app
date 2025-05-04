import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/classes/UserPaymentMethod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';
import 'package:uuid/uuid.dart';

String dbUrl = AppConfig.dbUrl;

List<UserPaymentMethod> userPaymentMethodList = [];

class UserPremiumSubscription extends StatefulWidget {
  const UserPremiumSubscription({super.key});

  @override
  State<UserPremiumSubscription> createState() =>
      userPremiumSubscriptionState();
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

Future<List<UserPaymentMethod>> getUserPaymentMethod(String firebaseUID) async {
  List<UserPaymentMethod> listUserPayment = [];

  String url = dbUrl + "user_payment_method.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((dataId, data) {
      if (firebaseUID == data['user_id']) {
        listUserPayment.add(UserPaymentMethod(
            user_payment_method_id: data['user_payment_method_id'] ?? '',
            user_id: data['user_id'] ?? '',
            gcash: data['gcash'] ?? '',
            gcash_date_time_add: data['gcash_date_time_add'] ?? '',
            paypal: data['paypal'] ?? '',
            paypal_date_time_add: data['paypal_date_time_add'] ?? '',
            apple_pay: data['apple_pay'] ?? '',
            apple_pay_date_time_add: data['apple_pay_date_time_add'] ?? '',
            credit_card: data['credit_card'] ?? '',
            credit_card_date_time_add: data['credit_card_date_time_add'] ?? '',
            credit_card_cvc: data['credit_card_cvc'] ?? '',
            credit_card_expiry: data['credit_card_expiry'] ?? ''));
      }
    });
  } catch (error) {
    throw error;
  }

  return listUserPayment;
} // getUserPaymentMethod

// getUserPaymentMethod

void addUserPlan(String firebaseUID, String subscription_plan) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  String url = dbUrl + "user_premium_plan/$firebaseUID.json";

  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "user_id": firebaseUID,
          "date_time_joined": date_time_formatted,
          "date_time_activated": "",
          "activated_by": "",
          "status": "0",
          "subscription_plan_id": subscription_plan,
          "user_premium_plan_id": firebaseUID
        }));
  } catch (error) {
    throw error;
  }
} // addUserPlan

class userPremiumSubscriptionState extends State<UserPremiumSubscription> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  bool hasPlanSelected = false;
  bool planSelectionOpen = false;
  String? planString;
  String? rateString;
  String? selectedPaymentMethod;
  String? selectedPaymentAccountNumber;
  String? planSelected;
  String? firebaseUID;
  String? subscriptionPlanId;
  String? pricePlanSelected;
  List<UserPaymentMethod> userListPayment = [];

  void initState() {
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getPaymentSelection();
    getPlanSelection();
  } // initState

  void getPaymentMethod(String selectedPayment) async {
    List<UserPaymentMethod> listPayment = [];
    listPayment = await getUserPaymentMethod(firebaseUID ?? "");

    setState(() {
      userListPayment = listPayment;

      if (userListPayment.length > 0) {
        if (selectedPayment == "GCash") {
          selectedPaymentAccountNumber = userListPayment[0].gcash;
          setSession("accountNumber", selectedPaymentAccountNumber ?? "");
        }

        if (selectedPayment == "Credit Card") {
          selectedPaymentAccountNumber = userListPayment[0].credit_card;
          setSession("accountNumber", selectedPaymentAccountNumber ?? "");
        }

        if (selectedPayment == "Apple Pay") {
          selectedPaymentAccountNumber = userListPayment[0].apple_pay;
          setSession("accountNumber", selectedPaymentAccountNumber ?? "");
        }

        if (selectedPayment == "Paypal") {
          selectedPaymentAccountNumber = userListPayment[0].paypal;
          setSession("accountNumber", selectedPaymentAccountNumber ?? "");
        }
      }
    });
  } // getPaymentMethod()

  Future<void> getPlanSelection() async {
    planSelected = await getSession("premium_plan");
    subscriptionPlanId = "subscription_plan_id_" + planSelected! + "";

    if (planSelected == "1") {
      isSelectedPlanOne = true;
      _toggleWidthPlan();
    }

    if (planSelected == "2") {
      isSelectedPlanTwo = true;
      _toggleWidthPlan();
    }

    if (planSelected == "3") {
      isSelectedPlanThree = true;
      _toggleWidthPlan();
    }
  } // getPlanSelection

  Future<void> getPaymentSelection() async {
    selectedPaymentMethod = await getSession("selected_payment_method");
    getPaymentMethod(selectedPaymentMethod ?? "");
  } // getPlanSelection

  void _toggleWidthPlan() {
    setState(() {
      _widthPlan = _widthPlan == 280 ? _widthPlan = 0 : _widthPlan = 280;

      if (isSelectedPlanOne == true) {
        planString = "1 Month";
        rateString = "PHP 275/Month";

        setSession("premium_plan", "1");
        setSession("plan_description", rateString ?? "");

        pricePlanSelected = "275";
        setSession("price_plan_selected", pricePlanSelected ?? "");
      } else if (isSelectedPlanTwo == true) {
        planString = "3 Months";
        rateString = "PHP 515 for 3 Months";

        setSession("premium_plan", "2");
        setSession("plan_description", rateString ?? "");

        pricePlanSelected = "515";
        setSession("price_plan_selected", pricePlanSelected ?? "");
      } else if (isSelectedPlanThree == true) {
        planString = "6 Months";
        rateString = "PHP 1,625 for 6 Months";

        setSession("premium_plan", "3");
        setSession("plan_description", rateString ?? "");

        pricePlanSelected = "1625";
        setSession("price_plan_selected", pricePlanSelected ?? "");
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

      pricePlanSelected = "275";

      hasPlanSelected = isSelectedPlanOne;
    });
  }

  void _togglePlanButtonTwo() {
    setState(() {
      isSelectedPlanTwo = !isSelectedPlanTwo;

      isSelectedPlanOne = false;
      isSelectedPlanThree = false;

      pricePlanSelected = "515";
      hasPlanSelected = isSelectedPlanTwo;
    });
  }

  void _togglePlanButtonThree() {
    setState(() {
      isSelectedPlanThree = !isSelectedPlanThree;

      isSelectedPlanOne = false;
      isSelectedPlanTwo = false;

      pricePlanSelected = "1625";

      hasPlanSelected = isSelectedPlanThree;
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
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Enjoy special discounts\n and offers',
                                                        style: TextStyle(
                                                            fontSize: 12,
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
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Enjoy special\n discountsand offers reserved for subscribers.',
                                                        style: TextStyle(
                                                            fontSize: 12,
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
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Subscribe for ad-free\naccess and seamless bookings',
                                                        style: TextStyle(
                                                            fontSize: 12,
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
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ' Connect with\n like-minded fitness enthusiasts and\nstay motivated together',
                                                        style: TextStyle(
                                                            fontSize: 12,
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
                              Text("Choose your own plan  ",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))
                            ])),
                            SizedBox(height: 15),
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
                                        Text("PHP 275    ",
                                            style:
                                                TextStyle(color: Colors.white)),
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
                                        Text("PHP 515    ",
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
                                        Text("PHP 1,635  ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.8))
                                      ])),
                            ),
                            SizedBox(height: 50),
                            Visibility(
                              visible: hasPlanSelected,
                              child: GestureDetector(
                                onTap: () {
                                  _toggleWidthPlan();
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
                                        color:
                                            Color.fromARGB(197, 241, 38, 224)),
                                    child: Text("Go Premium",
                                        style: TextStyle(color: Colors.white))),
                              ),
                            ),
                            Visibility(
                              visible: hasPlanSelected,
                              child: GestureDetector(
                                  onTap: () {
                                    removeSession("selected_payment_method");
                                    removeSession("premium_plan");
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
                                                  197, 241, 38, 224))))),
                            )
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
                              removeSession("selected_payment_method");
                              removeSession("premium_plan");
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
                    child: selectedPaymentMethod != null
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 10, top: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.white)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(selectedPaymentMethod ?? "",
                                      style: TextStyle(color: Colors.white)),
                                  Text(selectedPaymentAccountNumber ?? "",
                                      style: TextStyle(color: Colors.white))
                                ]))
                        : Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 25, left: 75, right: 75),
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(197, 241, 38, 224)),
                            child: Text("Add Payment Method",
                                style: TextStyle(color: Colors.white))),
                  ),
                  GestureDetector(
                    onTap: () async {
                      addUserPlan(firebaseUID ?? "", subscriptionPlanId ?? "");

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return UserMainMenu(
                            selectedInitIndex: 0, subSelectedInitIndex: 44);
                      }));
                    },
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
