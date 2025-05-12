import 'package:flutter/material.dart';
import 'package:fitup/classes/TransactionClass.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/UserDetails.dart';
import 'package:fitup/classes/AdminSettings.dart';

import 'package:fitup/pages/adminMainMenu.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/components/TextFieldNumberOnly.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminTransaction extends StatefulWidget {
  const AdminTransaction({super.key});

  State<AdminTransaction> createState() => _adminTransactionState();
}

String getTransactionType(String transactionTypeId) {
  String transactionTypeLabel = "";
  switch (transactionTypeId) {
    case "1":
      transactionTypeLabel = "Gym Session Payment";
    case "2":
      transactionTypeLabel = "Gym Premium Membership Payment";
    case "3":
      transactionTypeLabel = "Remittance to Trainer";
    case "4":
      transactionTypeLabel = "Remittance to FitUp Wallet";
    case "5":
      transactionTypeLabel = "Withdraw fund from FitUp Wallet";
    case "6":
      transactionTypeLabel = "Client Refund";
    case "7":
      transactionTypeLabel = "Subscription Payment Receipt Invalid";
    case "8":
      transactionTypeLabel = "Gym Session Payment Receipt Invalid";
    case "9":
      transactionTypeLabel = "Subscription Cancelled by Client";
    case "10":
      transactionTypeLabel = "Gym Program Cancelled by Client";
  }
  return transactionTypeLabel;
}

Future<List<GymUserSessionClass>> getUserSessions() async {
  List<GymUserSessionClass> listData = [];

  String url = dbUrl + "gym_session_users.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listData.add(GymUserSessionClass(
          gym_user_session_id: json['gym_user_session_id'] ?? "",
          gym_session_id: json['gym_session_id'] ?? "",
          gym_class_id: json['gym_class_id'] ?? "",
          date_time_meet: json['date_time_meet'] ?? "",
          price_per_day_net: json['price_per_day_net'] ?? "",
          fitup_service_price: json['fitup_service_price'] ?? "",
          rating: json['rating'] ?? "",
          review: json['review'] ?? "",
          status: json['status'] ?? "",
          trainer_id: json['trainer_id'] ?? "",
          user_id: json['user_id'] ?? "",
          price_per_day: json['price_per_day'] ?? "",
          fitup_service_percentage_from_price:
              json['fitup_service_percentage_from_price'] ?? "",
          admin_remittance_date_time: json['admin_remittance_date_time'] ?? "",
          is_trainer_remittance_confirm:
              json['is_trainer_remittance_confirm'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listData;
} //  getUserSessions()

Future<List<GymSessionClass>> getGymSessionClass() async {
  List<GymSessionClass> listData = [];

  String url = dbUrl + "gym_session_users.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listData.add(GymSessionClass(
          gym_session_id: json['gym_session_id'] ?? "",
          gym_class_id: json['gym_class_id'] ?? "",
          for_date_schedule: json['for_date_schedule'] ?? "",
          for_day_schedule: json['for_day_schedule'] ?? "",
          for_time_range_schedule: json['for_time_range_schedule'] ?? "",
          price_per_day: json['price_per_day'] ?? "",
          trainer_id: json['trainer_id'] ?? "",
          date_time_actual_finished: json['date_time_actual_finished'] ?? "",
          status: json['status'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listData;
} //  getSessionClass()

Future<List<GymTrainerClasses>> getGymTrainerClasses() async {
  List<GymTrainerClasses> listData = [];

  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listData.add(GymTrainerClasses(
          gym_trainer_class_id: json['gym_trainer_class_id'] ?? "",
          training_category_id: json['training_category_id'] ?? "",
          class_name: json['class_name'] ?? "",
          class_description: json['class_description'] ?? "",
          price_per_day: json['price_per_day'] ?? "",
          cover_photo_url: json['cover_photo_url'] ?? "",
          best_for: json['best_for'] ?? "",
          exercise_id: json['exercise_id'] ?? "",
          date_start: json['date_start'] ?? "",
          date_end: json['date_end'] ?? "",
          duration_in_mins: json['duration_in_mins'] ?? "",
          firebase_uid: json['firebase_uid'] ?? "",
          date_time_added: json['date_time_added'] ?? "",
          date_time_last_updated: json['date_time_last_updated'] ?? "",
          is_active: json['is_active'] ?? "",
          is_done: json['is_done'] ?? "",
          schedule_times: json['schedule_times'] ?? "",
          scheduled_days: json['scheduled_days'] ?? "",
          session_setup: json['session_setup'] ?? "",
          level: json['level'] ?? "",
          users_per_class_limit: json['users_per_class_limit'] ?? "",
          status: json['status'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listData;
} //  getGymTrainerClasses()

Future<List<UserDetails>> getAllUsers() async {
  List<UserDetails> listUsersData = [];
  String url = dbUrl + "users.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listUsersData.add(UserDetails(
          username: json['username'] ?? "",
          firebase_uid: json['firebase_uid'] ?? "",
          firstname: json['firstname'] ?? "",
          middlename: json['middlename'] ?? "",
          lastname: json['lastname'] ?? "",
          ext: json['ext'] ?? "",
          email: json['email'] ?? "",
          phone: json['phone'] ?? "",
          otp: json['otp'] ?? "",
          occupation: json['occupation'] ?? "",
          title: json['title'] ?? "",
          role: json['role'] ?? "",
          date_time_membership: json['date_time_membership'] ?? "",
          date_time_premium_activated: json['date_time_premium_actvated'] ?? "",
          date_time_registered: json['date_time_registered'] ?? "",
          email_verified: json['email_verified'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listUsersData;
} // getAllUsers

Future<List<TransactionClass>> getTransactions() async {
  List<TransactionClass> listTransaction = [];

  String url = dbUrl + "transaction.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }
    extractedData.forEach((key, json) {
      listTransaction.add(TransactionClass(
          transaction_id: json['transaction_id'] ?? "",
          transaction_set_id: json['transaction_set_id'] ?? "",
          subscription_plan_id: json['subscription_plan_id'] ?? "",
          gym_program_id: json['gym_program_id'] ?? "",
          gym_session_id: json['gym_session_id'] ?? "",
          transaction_type: json['transaction_type'] ?? "",
          payment_method: json['payment_method'] ?? "",
          total_price: json['total_price'] ?? "",
          amount_change: json['amount_change'] ?? "",
          total_paid: json['total_paid'] ?? "",
          image_receipt_url: json['image_receipt_url'] ?? "",
          discount_applied: json['discount_applied'] ?? "",
          date_time_transaction: json['date_time_transaction'] ?? "",
          trainer_id: json['trainer_id'] ?? "",
          user_id: json['user_id'] ?? "",
          from_transaction_id: json['from_transaction_id'] ?? "",
          status: json['status'] ?? "",
          admin_handled: json['admin_handled'] ?? "",
          admin_handled_date_time: json['admin_handled_date_time'] ?? "",
          remarks: json['remarks'] ?? ""));
    });

    listTransaction.sort((a, b) => DateTime.parse(b.date_time_transaction)
        .compareTo(DateTime.parse(a.date_time_transaction)));
  } catch (error) {
    throw error;
  }

  return listTransaction;
} // getTransactions

void confirmPayment(
    String transactionId,
    String transactionType,
    String userId,
    String trainerId,
    String classId,
    String sessionId,
    String userSessionId,
    String price_per_day,
    String amountPaid,
    String paymentMethod,
    String fitup_service_fee) {
  String url = dbUrl + "transaction/$transactionId.json";

  String firebaseUIDAdmin = FirebaseAuth.instance.currentUser!.uid.toString();

  String date_time_formatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  try {
    final response = http.patch(Uri.parse(url),
        body: json.encode({
          "status": "1",
          "total_paid": amountPaid,
          "payment_method": paymentMethod,
          "admin_handled_by": firebaseUIDAdmin,
          "admin_handled_date_time": date_time_formatted
        }));
  } catch (error) {
    throw error;
  }

  if (transactionType == "2") {
    updateUserSubscriptionPlanStatus(userId, "1");

    remitFeeToFitupWalletTransaction(transactionId, userId, trainerId, classId,
        sessionId, price_per_day, "0");
  } else {
    updateUserSessionStatus(userSessionId, "1");

    remitFeeToFitupWalletTransaction(transactionId, userId, trainerId, classId,
        sessionId, price_per_day, fitup_service_fee);

    remitPaymentToTrainerTransaction(transactionId, userId, trainerId, classId,
        sessionId, price_per_day, fitup_service_fee);
  }
} // confirmPayment

void updateUserSessionStatus(String userSessionId, String status) {
  String url = dbUrl + "gym_session_users/$userSessionId.json";
  try {
    final response =
        http.patch(Uri.parse(url), body: json.encode({"status": status}));
  } catch (error) {
    throw error;
  }
} // updateUserSessionStatus

void updateUserSubscriptionPlanStatus(String userId, String status) {
  String url = dbUrl + "user_premium_plan/$userId.json";
  try {
    final response =
        http.patch(Uri.parse(url), body: json.encode({"status": status}));
  } catch (error) {
    throw error;
  }
} // updateUserSubscriptionPlanStatus

void remitPaymentToTrainerTransaction(
    String fromTransactionId,
    String userId,
    String trainerId,
    String classId,
    String sessionId,
    String price_per_day,
    String fitup_service_fee_string) {
  final uuidValue = Uuid();
  String idValue = uuidValue.v4();

  double pricePerDayDouble = double.parse(price_per_day);
  double fitup_service_fee = double.parse(
      fitup_service_fee_string == "" ? "0" : fitup_service_fee_string);
  double service_fee_factor =
      fitup_service_fee < 1 ? 1 : fitup_service_fee / 100;
  double fitupFeeDouble = pricePerDayDouble * service_fee_factor;
  double netPriceDouble = pricePerDayDouble - fitupFeeDouble;

  String net_price = netPriceDouble.toString();

  String date_time_formatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  String firebaseUIDAdmin = FirebaseAuth.instance.currentUser!.uid.toString();

  String url = dbUrl + "transaction/$idValue.json";
  try {
    final response = http.put(Uri.parse(url),
        body: json.encode({
          "transaction_id": idValue,
          "transaction_set_id": "",
          "subscription_plan_id": "",
          "gym_program_id": classId,
          "gym_session_id": sessionId,
          "transaction_type": "3",
          "payment_method": "",
          "total_price": "",
          "amount_change": "",
          "total_paid": net_price,
          "image_receipt_url": "",
          "discount_applied": "",
          "date_time_transaction": date_time_formatted,
          "trainer_id": trainerId,
          "user_id": userId,
          "from_transaction_id": fromTransactionId,
          "status": "0",
          "admin_handled": firebaseUIDAdmin,
          "admin_handled_date_time": date_time_formatted,
          "remarks": ""
        }));
  } catch (error) {
    throw error;
  }
} // remitPaymentToTrainerTransaction

void remitFeeToFitupWalletTransaction(
    String fromTransactionId,
    String userId,
    String trainerId,
    String classId,
    String sessionId,
    String price_per_day,
    String fitup_service_fee_string) {
  final uuidValue = Uuid();
  String idValue = uuidValue.v4();

  double pricePerDayDouble = double.parse(price_per_day);
  double fitup_service_fee = double.parse(
      fitup_service_fee_string == "" ? "0" : fitup_service_fee_string);
  double service_fee_factor =
      fitup_service_fee < 1 ? 1 : fitup_service_fee / 100;
  double fitupFeeDouble = pricePerDayDouble * service_fee_factor;
  double netPriceDouble = 0;

  if (fitup_service_fee_string == "0") {
    netPriceDouble = pricePerDayDouble;
    updateFitUpWallet(netPriceDouble.toString());
  } else {
    netPriceDouble = pricePerDayDouble - fitupFeeDouble;
    updateFitUpWallet(fitupFeeDouble.toString());
    updateTrainerWallet(trainerId, netPriceDouble.toString());
  }

  String net_price = netPriceDouble.toString();

  String date_time_formatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

  String firebaseUIDAdmin = FirebaseAuth.instance.currentUser!.uid.toString();

  String url = dbUrl + "transaction/$idValue.json";
  try {
    final response = http.put(Uri.parse(url),
        body: json.encode({
          "transaction_id": idValue,
          "transaction_set_id": "",
          "subscription_plan_id": "",
          "gym_program_id": classId,
          "gym_session_id": sessionId,
          "transaction_type": "4",
          "payment_method": "",
          "total_price": "",
          "amount_change": "",
          "total_paid": fitupFeeDouble.toString(),
          "image_receipt_url": "",
          "discount_applied": "",
          "date_time_transaction": date_time_formatted,
          "trainer_id": trainerId,
          "user_id": userId,
          "from_transaction_id": fromTransactionId,
          "status": "1",
          "admin_handled": firebaseUIDAdmin,
          "admin_handled_date_time": date_time_formatted,
          "remarks": ""
        }));
  } catch (error) {
    throw error;
  }
} // remitPaymentToTrainerTransaction

void updateFitUpWallet(String remitAmount) async {
  String idValue = "fitup_wallet_id_1";
  String url = dbUrl + "fitup_wallet/$idValue.json";

  String? currentBalance = await getFitUpWallet();

  double currentBalanceDouble = double.parse(currentBalance ?? "1");
  double newBalanceDouble = currentBalanceDouble + double.parse(remitAmount);

  String newBalance = newBalanceDouble.toString();

  String dateTimeFormat =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "current_balance": newBalance,
          "date_time_last_updated": dateTimeFormat
        }));
  } catch (error) {
    throw error;
  }
} // updateFitUpWallet

Future<String> getTrainerWallet(String firebaseUID) async {
  String currentBalance = "";
  String url = dbUrl + "trainer_wallet.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == Null || response.body.isEmpty) {
      return "0";
    }

    extractedData.forEach((key, json) {
      String trainerWalletId = key;
      if (firebaseUID == trainerWalletId) {
        currentBalance = json['current_balance'] ?? "0";
      }
    });
  } catch (error) {
    return "0";
  }
  return currentBalance;
} // getTrainerWallet

Future<String> getFitUpWallet() async {
  String currentBalance = "";
  String url = dbUrl + "fitup_wallet.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((key, json) {
      currentBalance = json['current_balance'] ?? "";
    });
  } catch (error) {
    throw error;
  }

  return currentBalance;
} // getFitUpWallet

void updateTrainerWallet(String trainerFirebaseUID, String addedBalance) async {
  String currentBalance = await getTrainerWallet(trainerFirebaseUID);
  double newBalanceDouble =
      double.parse(currentBalance) + double.parse(addedBalance);

  String newBalance = newBalanceDouble.toStringAsFixed(2);

  String dateTimeNowFormatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String url = dbUrl + "trainer_wallet/$trainerFirebaseUID.json";
  try {
    final response = http.patch(Uri.parse(url),
        body: json.encode({
          "trainer_wallet_id": trainerFirebaseUID,
          "current_balance": newBalance,
          "date_time_last_updated": dateTimeNowFormatted,
          "trainer_id": trainerFirebaseUID
        }));
  } catch (error) {
    throw error;
  }
} // updateTrainerWallet

class _adminTransactionState extends State<AdminTransaction> {
  List<GymUserSessionClass> listGymUserSession = [];
  List<UserDetails> listUsers = [];
  List<AdminSettings> listAdminSettings = [];
  List<GymTrainerClasses> listGymTrainerClassesData = [];
  List<GymSessionClass> listGymSessionClassesData = [];

  void initState() {
    super.initState();
    getUserSessionClass();
    getUsersData();
    getAdminSettingsData();
    getGymTrainerClassesData();
    getGymSessionClasses();
  }

  void getUserSessionClass() async {
    List<GymUserSessionClass> listUserSessionData = await getUserSessions();
    setState(() {
      listGymUserSession = listUserSessionData;
    });
  } // getUserSessionClass

  void getGymSessionClasses() async {
    List<GymSessionClass> gymSessionClassesData = await getGymSessionClass();
    setState(() {
      listGymSessionClassesData = gymSessionClassesData;
    });
  } // getGymSessionClasses()

  void getUsersData() async {
    List<UserDetails> listUserData = await getAllUsers();
    setState(() {
      listUsers = listUserData;
    });
  } // getUsersData

  void getGymTrainerClassesData() async {
    List<GymTrainerClasses> listGymTrainerClassesValues =
        await getGymTrainerClasses();
    setState(() {
      listGymTrainerClassesData = listGymTrainerClassesValues;
    });
  } // getGymTrainerClassesData

  void getAdminSettingsData() async {
    List<AdminSettings> listAdminSettingsData =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getAdminSettings();
    setState(() {
      listAdminSettings = listAdminSettingsData;
    });
  } // getAdminSettingsData

  void viewTransaction(
      BuildContext context,
      String transactionId,
      String transactionType,
      String subscriptionPlan,
      String gymUserSessionId,
      String sessionId,
      String sessionLabel,
      String receiptUrl,
      String classTitle,
      String price,
      String userId,
      String trainerId,
      String classId,
      String fitup_service_fee) {
    final textAmountPaidController = TextEditingController();

    String? paymentMethod;

    void initState() {
      super.initState();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment for',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                        transactionType == "2"
                            ? subscriptionPlan
                            : "$sessionLabel\n$classTitle",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300))
                  ]),
              content: Container(
                width: MediaQuery.of(context).size.width - 150,
                height: MediaQuery.of(context).size.height - 150,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text("TOTAL PRICE",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text("PHP $price",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(height: 10),
                                    TextFieldNumberOnly(
                                        hint_text_value: "Amount Paid",
                                        textController:
                                            textAmountPaidController,
                                        obscure_text: false,
                                        iconPrefix: Icon(Icons.pin),
                                        iconSuffix: Icon(Icons.ac_unit,
                                            color: Colors.transparent)),
                                  ]),
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView(children: [
                            Image.network(receiptUrl,
                                height: 200,
                                width: MediaQuery.of(context).size.width - 250,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, StackTrace) {
                              return GestureDetector(
                                onTap: () {},
                                child: Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      Center(child: Text("No available image")),
                                    ])),
                              );
                            }, loadingBuilder: (context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: CircularProgressIndicator(
                                        value: loadingProgress != null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null));
                              }
                            })
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // receiptPhoto is the variable for receipt photo url uploaded to firebase storage

                    confirmPayment(
                        transactionId,
                        transactionType,
                        userId,
                        trainerId,
                        classId,
                        sessionId,
                        gymUserSessionId,
                        price,
                        textAmountPaidController.text.toString(),
                        paymentMethod ?? "",
                        fitup_service_fee);
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AdminMainMenu(
                          selectedInitIndex: 2, subSelectedInitIndex: 0);
                    }));
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromARGB(199, 167, 10, 180)),
                      child: Text('Confirm Payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white))),
                ),
              ],
            );
          },
        );
      },
    );
  } // addEventDialog

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new, color: Colors.transparent),
            centerTitle: true,
            title: Text("All Fit Up Transactions",
                style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                    stream: getTransactions().asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: const Text("No available data"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final rawList = snapshot.data!;
                      final deduplicated = <String, dynamic>{}; // Map by ID

                      for (var item in rawList) {
                        deduplicated[item.transaction_id] =
                            item; // always replaces older
                      }

                      final uniqueList = deduplicated.values.toList();

                      return ListView.builder(
                          itemCount: uniqueList.length,
                          itemBuilder: (context, index) {
                            final dataContent = uniqueList[index];

                            String transactionId = dataContent.transaction_id;
                            String gymProgramId = dataContent.gym_program_id;
                            String gymSessionId = dataContent.gym_session_id;
                            String remarks = dataContent.remarks;

                            String dateTimeTransaction =
                                dataContent.date_time_transaction;
                            String dateTimeTransactionFormatted =
                                DateFormat("MMM dd, yyyy h:mma").format(
                                    DateTime.parse(dateTimeTransaction));
                            String subscriptionPlanId =
                                dataContent.subscription_plan_id;
                            String totalPrice = dataContent.total_price;
                            String totalPaid = dataContent.total_paid;
                            String receiptUrl = dataContent.image_receipt_url;
                            String status = dataContent.status;
                            String userId = dataContent.user_id;
                            String trainerId = dataContent.trainer_id;
                            String transactionType =
                                dataContent.transaction_type;
                            String paymentMethod = dataContent.payment_method;
                            String transactionTypeLabel =
                                getTransactionType(transactionType);

                            String userFirstname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == userId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == userId)
                                    .toList()[0]
                                    .firstname
                                : "";

                            String fitup_service_fee =
                                listAdminSettings[0].fitup_service_fee;

                            String userLastname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == userId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == userId)
                                    .toList()[0]
                                    .lastname
                                : "";

                            String trainerFirstname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == trainerId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == trainerId)
                                    .toList()[0]
                                    .firstname
                                : "";

                            String trainerLastname = listUsers
                                        .where((userData) =>
                                            userData.firebase_uid == trainerId)
                                        .toList()
                                        .length >
                                    0
                                ? listUsers
                                    .where((userData) =>
                                        userData.firebase_uid == trainerId)
                                    .toList()[0]
                                    .lastname
                                : "";

                            String gymUserSessionIdValue = listGymUserSession
                                        .where((userSessionData) =>
                                            userSessionData.gym_session_id ==
                                            gymSessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSession
                                    .where((userSessionData) =>
                                        userSessionData.gym_session_id ==
                                        gymSessionId)
                                    .toList()[0]
                                    .gym_user_session_id
                                : "";

                            String gymUserSessionClassId = listGymUserSession
                                        .where((userSessionData) =>
                                            userSessionData.gym_session_id ==
                                            gymSessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSession
                                    .where((userSessionData) =>
                                        userSessionData.gym_session_id ==
                                        gymSessionId)
                                    .toList()[0]
                                    .gym_class_id
                                : "";

                            String gymDate = listGymSessionClassesData
                                        .where((gymSessionData) =>
                                            gymSessionData.gym_session_id ==
                                            gymSessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymSessionClassesData
                                    .where((gymSessionData) =>
                                        gymSessionData.gym_session_id ==
                                        gymSessionId)
                                    .toList()[0]
                                    .for_date_schedule
                                : "";

                            String gymTimeRange = listGymSessionClassesData
                                        .where((gymSessionData) =>
                                            gymSessionData.gym_session_id ==
                                            gymSessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymSessionClassesData
                                    .where((gymSessionData) =>
                                        gymSessionData.gym_session_id ==
                                        gymSessionId)
                                    .toList()[0]
                                    .for_time_range_schedule
                                : "";

                            String gymClassName = listGymTrainerClassesData
                                        .where((gymTrainerData) =>
                                            gymTrainerData
                                                .gym_trainer_class_id ==
                                            gymUserSessionClassId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymTrainerClassesData
                                    .where((gymTrainerData) =>
                                        gymTrainerData.gym_trainer_class_id ==
                                        gymUserSessionClassId)
                                    .toList()[0]
                                    .class_name
                                : "";

                            String trainerFullname =
                                trainerLastname.toUpperCase() +
                                    " " +
                                    trainerFirstname.toUpperCase();

                            String gymSessionLabel =
                                "Gym Session of Trainer\n$trainerFullname\nfor $gymClassName on $gymDate ($gymTimeRange)";

                            String fullname = "";
                            String operationSymbol = "";

                            if (transactionType == "1" ||
                                transactionType == "2") {
                              fullname = userFirstname + " " + userLastname;

                              if (status == "1") {
                                operationSymbol = "+ ";
                              }
                            }

                            if (transactionType == "3") {
                              fullname =
                                  trainerFirstname + " " + trainerLastname;

                              operationSymbol = "- ";
                            }

                            int fullnameLength = fullname.length;
                            int maxTrimFullname = 15;

                            String dotExcess = "   ";

                            if (fullnameLength <= maxTrimFullname) {
                              maxTrimFullname = fullnameLength;
                            } else {
                              dotExcess = "...";
                            }

                            String fullnameTrim =
                                fullname.substring(0, maxTrimFullname) +
                                    dotExcess;

                            Color iconBgColor = Colors.grey.withOpacity(0.3);
                            Color iconColor = Colors.black54;

                            if (status == "1" && transactionType == "1") {
                              iconBgColor = Colors.green;
                              iconColor = Colors.white;
                            }

                            if (status == "1" && transactionType == "2") {
                              iconBgColor = Colors.green;
                              iconColor = Colors.white;
                            }

                            if (status == "0" && transactionType == "1") {
                              iconBgColor = Colors.orangeAccent;
                              iconColor = Colors.white;
                            }

                            if (status == "0" && transactionType == "2") {
                              iconBgColor = Colors.orangeAccent;
                              iconColor = Colors.white;
                            }

                            if (status == "1" && transactionType == "3") {
                              iconBgColor = Colors.redAccent;
                              iconColor = Colors.white;
                            }

                            String subscriptionPlan = "";

                            if (subscriptionPlanId ==
                                "subscription_plan_id_1") {
                              subscriptionPlan = "Plan 275 for 1 Month";
                            }

                            if (subscriptionPlanId ==
                                "subscription_plan_id_2") {
                              subscriptionPlan = "Plan 515 for 3 Months";
                            }

                            if (subscriptionPlanId ==
                                "subscription_plan_id_3") {
                              subscriptionPlan = "Plan 1625 for 6 Months";
                            }

                            return GestureDetector(
                              onTap: () {
                                if (transactionType == "1") {
                                  if (status == "1") {
                                  } else {
                                    viewTransaction(
                                        context,
                                        transactionId,
                                        transactionType,
                                        subscriptionPlan,
                                        gymUserSessionIdValue,
                                        gymSessionId,
                                        gymSessionLabel,
                                        receiptUrl,
                                        "",
                                        totalPrice,
                                        userId,
                                        trainerId,
                                        gymProgramId,
                                        fitup_service_fee);
                                  }
                                }
                                if (transactionType == "2") {
                                  if (status == "1") {
                                  } else {
                                    viewTransaction(
                                        context,
                                        transactionId,
                                        transactionType,
                                        subscriptionPlan,
                                        gymUserSessionIdValue,
                                        gymSessionId,
                                        gymSessionId,
                                        receiptUrl,
                                        "",
                                        totalPrice,
                                        userId,
                                        trainerId,
                                        gymProgramId,
                                        fitup_service_fee);
                                  }
                                }
                              },
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: iconBgColor),
                                            child: Icon(Icons.currency_exchange,
                                                color: iconColor)),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.80,
                                          child: Row(children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.43,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(transactionTypeLabel,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Visibility(
                                                      visible:
                                                          transactionType == "4"
                                                              ? false
                                                              : true,
                                                      child: Text(
                                                          transactionType == "3"
                                                              ? "for " +
                                                                  fullnameTrim
                                                                      .toUpperCase()
                                                              : "from " +
                                                                  fullnameTrim
                                                                      .toUpperCase(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ),
                                                    Text(
                                                        dateTimeTransactionFormatted)
                                                  ]),
                                            ),
                                            Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32,
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        status == "0" &&
                                                                (transactionType ==
                                                                        "1" ||
                                                                    transactionType ==
                                                                        "2")
                                                            ? "Confirmation for\nPHP " +
                                                                totalPrice
                                                            : operationSymbol +
                                                                "PHP " +
                                                                totalPaid,
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic))
                                                  ]),
                                            )
                                          ]),
                                        )
                                      ])),
                            );
                          });
                    }))));
  }
}
