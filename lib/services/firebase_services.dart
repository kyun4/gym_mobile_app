import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/classes/users.dart';
import 'package:fitup/classes/messages.dart';
import 'package:fitup/classes/UserGymClasses.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:fitup/classes/TransactionClass.dart';
import 'package:fitup/classes/AdminSettings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class FirebaseServices with ChangeNotifier {
  List<Users> listUsers = [];
  List<Users> get _listUsers => listUsers;

  List<Messages> listMessages = [];
  List<Messages> get _listMessages => listMessages;

  List<UserGymClasses> listUserGymClasses = [];
  List<UserGymClasses> get _listUserGymClasses => listUserGymClasses;

  List<GymTrainerClasses> listGymTrainerClasses = [];
  List<GymTrainerClasses> get _listGymTrainerClasses => listGymTrainerClasses;

  void acceptReservation(String trainerId, String clientId, String classId,
      String gymUserClassId) {
    DateTime dateTimeNowRaw = DateTime.now();
    var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    String dateTimeNow = formatter.format(dateTimeNowRaw);

    String url = dbUrl + "user_gym_classes/$gymUserClassId.json";
    try {
      final response = http.patch(Uri.parse(url),
          body: json.encode({
            "status": "1",
            "date_time_trainer_approved": dateTimeNow,
          }));
    } catch (error) {
      throw error;
    }
  } // acceptReservation

  void addGymSessionRecordsToSessionUsers(
      String trainerId,
      String clientId,
      String classId,
      String gymUserClassId,
      String fitup_service_fee_percentage) async {
    String url = dbUrl + "gym_sessions.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {}

      extractedData.forEach((key, value) {
        String gymClassId = value['gym_class_id'] ?? "";

        if (classId == gymClassId) {
          String gymSessionId = key;
          String price_per_day = value['price_per_day'] ?? "";

          double fitupServicePercentage =
              double.parse(fitup_service_fee_percentage);

          double pricePerDay = double.parse(price_per_day);

          double fitupServicePrice =
              pricePerDay * (fitupServicePercentage / 100);

          double pricePerDayNet = (pricePerDay - fitupServicePrice);

          String fitup_service_price = fitupServicePrice.toString();
          String price_per_day_net = pricePerDayNet.toString();

          // String fitup_service_price = "";
          // String price_per_day_net = "";

          addSessionsToUser(
              trainerId,
              clientId,
              classId,
              gymUserClassId,
              gymSessionId,
              price_per_day,
              fitup_service_fee_percentage,
              fitup_service_price,
              price_per_day_net);
        }
      });
    } catch (error) {
      throw error;
    }
  } // addGymSessionRecordsToSessionUsers

  void addSessionsToUser(
      String trainerId,
      String clientId,
      String classId,
      String gymUserClassId,
      String gymSessionId,
      String price_per_day,
      String fitup_percentage,
      String fitup_service_price,
      String price_per_day_net) {
    // DateTime dateTimeNowRaw = DateTime.now();
    // var formatter = DateFormat("yyyy-MM-dd hh:mm:ss");
    // String dateTimeNow = formatter.format(dateTimeNowRaw);

    var uuidString = new Uuid();
    String idValue = uuidString.v4();

    String url = dbUrl + "gym_session_users/$idValue.json";
    try {
      final response = http.put(Uri.parse(url),
          body: json.encode({
            "gym_user_session_id": idValue,
            "gym_session_id": gymSessionId,
            "gym_class_id": classId,
            "date_time_meet": "",
            "price_per_day_net": price_per_day_net,
            "price_per_day": price_per_day,
            "fitup_service_price": fitup_service_price,
            "fitup_service_percentage_from_price": fitup_percentage,
            "rating": "",
            "review": "",
            "status": "",
            "trainer_id": trainerId,
            "user_id": clientId,
            "admin_remittance_date_time": "",
            "is_trainer_remittance_confirm": ""
          }));
    } catch (error) {
      throw error;
    }
  } // addSessionsToUser

  void addSubscriptionHistory(
      String currentPeriodPaymentDateTime,
      String firebaseUID,
      String transactionId,
      String interval_month,
      String amount,
      String subscription_plan_id,
      String next_subscription_plan_id) {
    String next_payment_date = "";
    int interval = int.parse(interval_month);

    String currentPaymentDateTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .format(DateTime.parse(currentPeriodPaymentDateTime));
    int MonthCurrentPayment = DateTime.parse(currentPaymentDateTime).month;
    int dayCurrentPayment = DateTime.parse(currentPaymentDateTime).day;

    int nextMonth = 0;
    int nextDate = 0;
    int nextYear = 0;

    int monthsTotal = MonthCurrentPayment + interval;

    nextMonth = monthsTotal <= 12 ? monthsTotal : monthsTotal - 12;

    nextDate = dayCurrentPayment;
    nextYear = MonthCurrentPayment < 12
        ? DateTime.now().year
        : DateTime.now().year + 1;

    next_payment_date = nextYear.toString() +
        "-" +
        nextMonth.toString() +
        "-" +
        nextDate.toString();

    String url = dbUrl + "subscription_history.json";
    try {
      final response = http.post(Uri.parse(url),
          body: json.encode({
            "amount": amount,
            "interval_month": interval_month,
            "next_payment_date": next_payment_date,
            "next_subscription_plan_id": next_subscription_plan_id,
            "status": "0",
            "subscription_plan_id": subscription_plan_id,
            "transaction_id": transactionId,
            "user_id": firebaseUID
          }));
    } catch (error) {
      throw error;
    }
  } // addSubscriptionHistory

  Future<List<GymTrainerClasses>> getGymTrainerClasses() async {
    String url = dbUrl + "gym_trainer_classes.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        listGymTrainerClasses.add(GymTrainerClasses(
            gym_trainer_class_id: json['gym_trainer_class_id'],
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

    return listGymTrainerClasses;
  } // getGymTrainerClasses

  Future<List<GymSessionClass>> getStreamGymSessions() async {
    List<GymSessionClass> listGymSessionsData = [];

    String url = dbUrl + "gym_sessions.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        listGymSessionsData.add(GymSessionClass(
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

      listGymSessionsData.sort((a, b) => DateTime.parse(b.for_date_schedule)
          .compareTo(DateTime.parse(a.for_date_schedule)));
    } catch (error) {
      throw error;
    }

    return listGymSessionsData;
  } // getStreamGymSessions

  Future<List<AdminSettings>> getAdminSettings() async {
    List<AdminSettings> listAdminSettingsData = [];
    String url = dbUrl + "admin_settings.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        listAdminSettingsData.add(AdminSettings(
            admin_settings_id: json['admin_settings_id'] ?? "",
            fitup_service_fee: json['fitup_service_fee'] ?? "",
            apple_pay_payment_account: json['apple_pay_payment_account'] ?? "",
            apple_pay_payment_date_time_last_updated:
                json['apple_pay_payment_date_time_last_updated'] ?? "",
            apple_pay_updated_by: json['apple_pay_updated_by,'] ?? "",
            gcash_payment_account: json['gcash_payment_account'] ?? "",
            gcash_payment_date_time_last_updated:
                json['gcash_payment_date_time_last_updated'] ?? "",
            gcash_payment_updated_by: json['gcash_payment_updated_by'] ?? "",
            paypal_payment_account: json['paypal_payment_account'] ?? "",
            paypal_payment_date_time_last_updated:
                json['paypal_payment_date_time_last_updated'] ?? "",
            paypal_payment_updated_by:
                json[' paypal_payment_updated_by'] ?? ""));
      });
    } catch (error) {
      throw error;
    }

    return listAdminSettingsData;
  } // getAdminSettings

  Future<List<GymUserSessionClass>> getStreamGymSessionsUsers(
      String firebaseUID) async {
    List<GymUserSessionClass> listGymUserSessionsData = [];

    String url = dbUrl + "gym_session_users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        if (firebaseUID.trim() == json['trainer_id']) {
          listGymUserSessionsData.add(GymUserSessionClass(
              gym_user_session_id: json['gym_user_session_id'] ?? "",
              gym_session_id: json['gym_session_id'] ?? "",
              gym_class_id: json['gym_class_id'],
              date_time_meet: json['date_time_meet'] ?? "",
              price_per_day_net: json['price_per_day_net'] ?? "",
              price_per_day: json['price_per_day'] ?? "",
              fitup_service_percentage_from_price:
                  json['fitup_service_percentage_from_price'] ?? "",
              fitup_service_price: json['fitup_service_price'] ?? "",
              rating: json['rating'] ?? "",
              review: json['review'] ?? "",
              status: json['status'] ?? "",
              trainer_id: json['trainer_id'] ?? "",
              user_id: json['user_id'] ?? "",
              admin_remittance_date_time:
                  json['admin_remittance_date_time'] ?? "",
              is_trainer_remittance_confirm:
                  json['is_trainer_remittance_confirm'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    return listGymUserSessionsData;
  } // getStreamGymSessionsUsers

  Future<List<TransactionClass>> getTransactions() async {
    List<TransactionClass> listData = [];
    try {
      String url = dbUrl + "transactions.json";
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        listData.add(TransactionClass(
            transaction_id: json['transaction_id'] ?? "",
            transaction_set_id: json['transaction_set_id'] ?? "",
            subscription_plan_id: json['subscription_plan_id'] ?? "",
            gym_program_id: json['gym_program_id'] ?? "",
            gym_session_id: json['gym_session_id'] ?? "",
            transaction_type: json['transaction_type'] ?? "",
            payment_method: json['payment_method'] ?? "",
            total_price: json['total_price'] ?? "",
            amount_change: json['amount_change'] ?? "",
            total_paid: json[' total_paid'] ?? "",
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
    } catch (error) {
      throw error;
    }

    return listData;
  } // getTransactions

  Future<List<UserGymClasses>> getStreamUserGymClasses(
      String firebaseUID) async {
    List<UserGymClasses> listGymUserClassesData = [];

    String url = dbUrl + "user_gym_classes.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        if (firebaseUID.trim() == json['trainer_id']) {
          listGymUserClassesData.add(UserGymClasses(
              user_gym_class_id: json['user_gym_class_id'] ?? "",
              gym_class_id: json['gym_class_id'] ?? "",
              user_id: json['user_id'] ?? "",
              trainer_id: json['trainer_id'] ?? "",
              transaction_id: json['transaction_id'] ?? "",
              status: json['status'] ?? "",
              payment_status: json['payment_status'] ?? "",
              date_time_trainer_approved:
                  json['date_time_trainer_approved'] ?? "",
              date_time_booked: json['date_time_booked'] ?? "",
              date_time_admin_approved: json['date_time_admin_approved'] ?? "",
              approved_by_admin: json['approved_by_admin'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    listGymUserClassesData.sort((a, b) => DateTime.parse(b.date_time_booked)
        .compareTo(DateTime.parse(a.date_time_booked)));

    return listGymUserClassesData;
  } // getStreamUserGymClasses

  Future<List<Messages>> getMessagesJsonClientRequest(String trainerId) async {
    List<Messages> listMessages = [];

    var url = dbUrl + "messages.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((msgId, json) {
        if (trainerId == json['receiver'] && json['is_client_request'] == "1") {
          listMessages.add(Messages(
              message_id: json['message_id'],
              message_session_id: json['message_session_id'],
              message_content: json['message_content'],
              date_time: json['date_time'],
              sender: json['sender'],
              receiver: json['receiver'],
              is_seen: json['is_seen'],
              is_client_request: json['is_client_request'],
              is_deleted: json['is_deleted']));
        }
      });
    } catch (error) {
      throw error;
    }

    return listMessages;
  } // getMessagesJsonClientRequest

  Future<List<Users>> getUsersJson() async {
    List<Users> listUsersData = [];

    var url = dbUrl + "users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      extractedData.forEach((userId, userData) {
        listUsersData.add(Users(
            firebase_uid: userData['firebase_uid'] ?? '',
            username: userData['username'] ?? '',
            firstname: userData['firstname'] ?? '',
            middlename: userData['middlename'] ?? '',
            lastname: userData['lastname'] ?? '',
            ext: userData['ext'] ?? '',
            role: userData['role'] ?? '',
            phone: userData['phone'] ?? '',
            email: userData['email'] ?? '',
            otp: userData['otp'] ?? '',
            email_verified: userData['email_verified'] ?? '',
            occupation: userData['occupation'] ?? '',
            title: userData['title'] ?? '',
            date_time_registered: userData['date_time_registered'] ?? '',
            date_time_premium_activated: userData['date_time_activated'] ?? '',
            date_time_membership: userData['date_time_membership'] ?? ''));
      });
    } catch (error) {
      throw error;
    }

    return listUsersData;
  }

  Future<List<Users>> getUsers() async {
    final dbref = FirebaseDatabase.instance.ref("users");

    dbref.onValue.map((event) {
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((userId, userData) {
        listUsers.add(Users(
            firebase_uid: userData['firebase_uid'] ?? '',
            username: userData['username'] ?? '',
            firstname: userData['firstname'] ?? '',
            middlename: userData['middlename'] ?? '',
            lastname: userData['lastname'] ?? '',
            ext: userData['ext'] ?? '',
            role: userData['role'] ?? '',
            phone: userData['phone'] ?? '',
            email: userData['email'] ?? '',
            otp: userData['otp'] ?? '',
            email_verified: userData['email_verified'] ?? '',
            occupation: userData['occupation'] ?? '',
            title: userData['title'] ?? '',
            date_time_registered: userData['date_time_registered'] ?? '',
            date_time_premium_activated: userData['date_time_activated'] ?? '',
            date_time_membership: userData['date_time_membership'] ?? ''));
      });
    });

    notifyListeners();

    return listUsers;
  }
}
