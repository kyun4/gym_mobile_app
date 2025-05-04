import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/SubscriptionPlan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/firebase_services.dart';

import 'package:fitup/classes/AppConfig.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

String dbUrl = AppConfig.dbUrl;

class UserPremiumSubscriptionPaymentSummary extends StatefulWidget {
  const UserPremiumSubscriptionPaymentSummary({super.key});

  @override
  State<UserPremiumSubscriptionPaymentSummary> createState() =>
      userPremiumSubscriptionPaymentSummaryState();
}

void addTransactionRecord(String transactionId, String price,
    String firebaseUID, String subscription_plan, String imageReceipt) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  String url = dbUrl + "transaction/$transactionId.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "transaction_id": transactionId,
          "transaction_set_id": "",
          "subscription_plan_id": subscription_plan,
          "gym_program_id": "",
          "gym_session_id": "",
          "transaction_type": "2",
          "payment_method": "",
          "total_price": price,
          "amount_change": "",
          "total_paid": price,
          "image_receipt_url": imageReceipt,
          "discount_applied": "",
          "date_time_transaction": date_time_formatted,
          "trainer_id": "",
          "user_id": firebaseUID,
          "from_transaction_id": "",
          "status": "0",
          "admin_handled": "",
          "admin_handled_date_time": "",
          "remarks": ""
        }));
  } catch (error) {
    throw error;
  }
} // addTransactionRecord

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

Stream<List<SubscriptionPlan>> getSubscriptionPlans() {
  final databaseRef = FirebaseDatabase.instance.ref('subscription_plan');

  return databaseRef.onValue.map((event) {
    final List<SubscriptionPlan> subscriptionPlanList = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((dataId, data) {
      subscriptionPlanList.add(SubscriptionPlan(
          subscription_plan_id: data['subscription_plan_id'],
          subscription_name: data['subscription_name'],
          details: data['details'],
          price_per_unit: data['price_per_unit'],
          unit: data['unit'],
          date_time_added: data['date_time_added'],
          added_by: data['added_by'],
          date_time_last_updated: data['date_time_last_updated'],
          last_updated_by: data['last_updated_by']));
    });

    subscriptionPlanList.sort(
        (a, b) => a.subscription_plan_id.compareTo(b.subscription_plan_id));

    return subscriptionPlanList;
  });
} // getSubscriptionPlans

class userPremiumSubscriptionPaymentSummaryState
    extends State<UserPremiumSubscriptionPaymentSummary> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  bool isSelectedPlanFour = false;
  String? planString;
  String? rateString;
  String? selectedPlan;
  String? selectedPrice;
  String? receiptImageUrl;

  void initState() {
    super.initState();
    getSelectedPlan();
  }

  void getSelectedPlan() async {
    String? planSelectedIndex = await getSession("premium_plan");
    String? planSelectedId = await getSession("premium_activated");
    String? planSelectedPrice = await getSession("price_plan_selected");
    String? downloadURL = await getSession("uploaded_receipt_url");

    setState(() {
      receiptImageUrl = downloadURL;
      selectedPrice = planSelectedPrice;
      if (planSelectedId != null) {
        selectedPlan = planSelectedId;
      } else {
        selectedPlan = "subscription_plan_id_" + planSelectedIndex! + "";
      }
    });
  } // getSelectedPlan

  Widget build(BuildContext) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Image.asset("assets/images/gymbg2.png", fit: BoxFit.cover)),
      Positioned.fill(
          child: ListView(children: [
        Container(
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              SizedBox(height: 50),
              Container(
                child: Row(children: [
                  Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: Text("My Subscription",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                          textAlign: TextAlign.center))
                ]),
              ),
              SizedBox(height: 50),
              Container(
                  child: Text("Thank you for upgrading to FitUp Premium!",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              Container(
                  padding: const EdgeInsets.only(top: 40, left: 65, right: 65),
                  child: Text(
                      "Get ready to experience seamless gym bookings, personalized workouts, and exclusive perks. Let's elevate your fitness journey together!",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300))),
              SizedBox(height: 20),
              Container(
                  height: MediaQuery.of(context).size.height - 370,
                  child: StreamBuilder(
                      stream: getSubscriptionPlans(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        int subItemCount = snapshot.data!.length;

                        return ListView.builder(
                            itemCount: subItemCount,
                            itemBuilder: (context, index) {
                              final data = snapshot.data!;
                              String subscriptionName =
                                  data[index].subscription_name;

                              String details = data[index].details;
                              String planId = data[index].subscription_plan_id;

                              return Container(
                                  margin: const EdgeInsets.only(
                                      top: 2.5, left: 50, right: 50),
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.black87,
                                      border: Border.all(
                                          color: planId == selectedPlan
                                              ? Color.fromARGB(
                                                  199, 167, 10, 180)
                                              : Colors.transparent)),
                                  child: Column(children: [
                                    Text(subscriptionName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(details,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w200))
                                  ]));
                            });
                      })),
              GestureDetector(
                onTap: () async {
                  await removeSession("premium_plan");
                  await removeSession("selected_payment_method");
                  await removeSession("premium_activated");

                  String firebaseUID =
                      FirebaseAuth.instance.currentUser!.uid.toString();

                  String transactionId = "";

                  final UUIDNew = Uuid();
                  transactionId = UUIDNew.v4();

                  addTransactionRecord(transactionId, selectedPrice ?? "",
                      firebaseUID, selectedPlan ?? "", receiptImageUrl ?? "");

                  String intervalMonth = "1";

                  if (selectedPlan == "subscription_plan_id_1") {
                    intervalMonth = "1";
                  }

                  if (selectedPlan == "subscription_plan_id_2") {
                    intervalMonth = "3";
                  }

                  if (selectedPlan == "subscription_plan_id_3") {
                    intervalMonth = "6";
                  }

                  Provider.of<FirebaseServices>(context, listen: false)
                      .addSubscriptionHistory(
                          DateFormat("yyyy-MM-dd HH:mm:ss")
                              .format(DateTime.now()),
                          firebaseUID,
                          transactionId,
                          intervalMonth,
                          selectedPrice ?? "",
                          selectedPlan ?? "",
                          selectedPlan ?? "");

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return UserMainMenu(
                        selectedInitIndex: 0, subSelectedInitIndex: 0);
                  }));
                },
                child: Container(
                    margin: const EdgeInsets.only(left: 55, right: 55),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 15, bottom: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(197, 241, 38, 224)),
                    child: Text("Done", style: TextStyle(color: Colors.white))),
              ),
              SizedBox(height: 75)
            ])),
      ])),
    ]));
  }
}
