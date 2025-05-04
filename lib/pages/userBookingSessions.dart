import 'package:flutter/material.dart';
import 'package:fitup/pages/UserMainMenu.dart';

import 'package:fitup/classes/GymUserSessionClass.dart';
import 'package:fitup/classes/GymSessionClass.dart';
import 'package:fitup/classes/AdminSettings.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fitup/services/firebase_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingSessions extends StatefulWidget {
  const UserBookingSessions({super.key});

  State<UserBookingSessions> createState() => _userBookingSessionsState();
}

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

void updateGymUserSession(
    String userSessionId, String dateTimeFinished, String status) async {
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var url = dbUrl + "gym_session_users/$userSessionId.json";

  try {
    final response = await http.patch(Uri.parse(url),
        body: json
            .encode({"status": status, "date_time_meet": dateTimeFinished}));
  } catch (error) {
    throw Error;
  }
} // updateGymUserSession

void submitUploadedPayment(
    String classId,
    String userSessionId,
    String sessionId,
    String trainerId,
    String price_per_day,
    String dateTimeFinished,
    String receiptPhoto,
    String gymUserSessionStatus) async {
  updateGymUserSession(userSessionId, dateTimeFinished, gymUserSessionStatus);
  var date_time = DateTime.now();
  var formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  var date_time_formatted = formatter.format(date_time);

  var UuidValue = Uuid();
  String idValue = UuidValue.v4();

  String firebaseUserId = FirebaseAuth.instance.currentUser!.uid.toString();

  var url = dbUrl + "transaction/$idValue.json";

  try {
    final response = await http.put(Uri.parse(url),
        body: json.encode({
          "transaction_id": idValue,
          "transaction_set_id": "",
          "subscription_plan_id": "",
          "gym_program_id": classId,
          "gym_session_id": sessionId,
          "transaction_type": "1",
          "payment_method": "",
          "total_price": price_per_day,
          "amount_change": "",
          "total_paid": "",
          "image_receipt_url": receiptPhoto,
          "discount_applied": "",
          "date_time_transaction": date_time_formatted,
          "trainer_id": trainerId,
          "user_id": firebaseUserId,
          "from_transaction_id": "",
          "status": "0",
          "admin_handled": "",
          "admin_handled_date_time": "",
          "remarks": ""
        }));
  } catch (error) {
    throw Error;
  }
} // submitUploadedPayment

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} // setSession

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

class _userBookingSessionsState extends State<UserBookingSessions> {
  String? trainerFullname;
  String? classTitle;
  String? trainerUsername;
  String? classId;
  String? firebaseUID;
  String? gcashAdmin;
  String? gymUserSessionStatus;
  String? gymUserSessionPaymentStatus;
  List<GymSessionClass> listGymSessionData = [];
  List<GymUserSessionClass> listGymUserSessionData = [];
  List<AdminSettings> listAdminSettingsData = [];

  void initState() {
    super.initState();
    getSharedPreferences();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getSessions();
    getAdminSettings();
  }

  void payUserSession(
      BuildContext context,
      String gcashAdmin,
      String price,
      String classId,
      String classTitle,
      String sessionLabel,
      String sessionId,
      String trainerId,
      String dateTimeFinished,
      String userSessionId) {
    final eventController = TextEditingController();
    final noteController = TextEditingController();

    XFile? _image;
    String? _downloadURL;
    double _progress = 0.0; //

    String? exerciseId,
        trainingCategoryId,
        sessionSetup,
        exerciseLevel,
        receiptPhoto,
        classLimit,
        mayaAdmin;

    Future<XFile?> _pickImage() async {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    }

    Future<String?> _uploadImage(XFile image) async {
      String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
      try {
        FirebaseStorage storage = FirebaseStorage.instance;

        final uniqueId = new Uuid();
        String uniqueIdValue = uniqueId.v4();
        String receiptFileName = firebaseUID + "_" + uniqueIdValue + "";

        Reference ref =
            storage.ref().child("receipts/" + receiptFileName + ".jpg");
        TaskSnapshot uploadTask = await ref.putFile(File(image.path));

        UploadTask uploadTasking = ref.putFile(File(image.path));

        // Listen to upload progress
        uploadTasking.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            _progress = progress; // Update the progress value
          });
        });

        String downloadURL = await uploadTask.ref.getDownloadURL();

        return downloadURL;
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    } // _uploadImage

    Future<void> _pickAndUploadImage() async {
      // Pick an image
      XFile? image = await _pickImage();
      if (image != null) {
        // Upload the image and get the download URL
        String? downloadURL = await _uploadImage(image);
        if (downloadURL != null) {
          setState(() {
            _image = image;
            receiptPhoto = downloadURL;
            _progress = 0.0;
          });
        }
      }
    } // _pickAndUploadImage

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
                    Text("$sessionLabel Session\nof $classTitle",
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
                                    Text("Send your payment to this account:"),
                                    SizedBox(height: 15),
                                    Row(children: [
                                      Text("GCash: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(gcashAdmin ?? "k")
                                    ]),
                                    SizedBox(height: 15),
                                    Text("Send the exact amount of: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400)),
                                    Text("PHP $price",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView(children: [
                            Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05)),
                              child: Center(
                                child: Image.network(receiptPhoto ?? "",
                                    height: 200,
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, StackTrace) {
                                  return GestureDetector(
                                    onTap: () {
                                      _pickAndUploadImage();
                                    },
                                    child: Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                          Icon(Icons.upload_file,
                                              color: Colors.black54, size: 75),
                                          SizedBox(height: 5),
                                          Text("Click to Upload Receipt Photo",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54))
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
                                }),
                              ),
                            ),
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
                    submitUploadedPayment(
                        classId ?? "",
                        userSessionId,
                        sessionId,
                        trainerId,
                        price,
                        dateTimeFinished,
                        receiptPhoto ?? "",
                        "2");
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMainMenu(
                          selectedInitIndex: 4, subSelectedInitIndex: 13);
                    }));
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color.fromARGB(199, 167, 10, 180)),
                      child: Text('Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white))),
                ),
              ],
            );
          },
        );
      },
    );
  } // payUserSession

  void getSessions() async {
    List<GymSessionClass> listGymSessionsDataValues =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getStreamGymSessions();

    List<GymUserSessionClass> listGymSessionUsers =
        await getUserSessions(firebaseUID ?? "", classId ?? "");
    setState(() {
      listGymSessionData = listGymSessionsDataValues;
      listGymUserSessionData = listGymSessionUsers;
    });
  } // getSessions

  void getAdminSettings() async {
    List<AdminSettings> listAdminSettingsValue =
        await Provider.of<FirebaseServices>(context, listen: false)
            .getAdminSettings();
    setState(() {
      listAdminSettingsData = listAdminSettingsValue;
      gcashAdmin = listAdminSettingsData.toList()[0].gcash_payment_account;
    });
  } // getAdminSettings

  void getSharedPreferences() async {
    String? trainerFullnameValue = await getSession("trainerFullname");
    String? classTitleValue = await getSession("classTitle");
    String? classIdValue = await getSession("classId");
    String? trainerUsernameValue = await getSession("trainerUsername");
    String? gymUserSessionStatusValue =
        await getSession("gymUserSessionStatus");
    String? gymUserSessionPaymentStatusValue =
        await getSession("gymUserSessionPaymentStatus");

    setState(() {
      trainerFullname = trainerFullnameValue;
      classTitle = classTitleValue;
      classId = classIdValue;
      trainerUsername = trainerUsernameValue;
      gymUserSessionStatus = gymUserSessionStatusValue;
      gymUserSessionPaymentStatus = gymUserSessionPaymentStatusValue;
    });
  } // getSharedPreferences

  Future<List<GymUserSessionClass>> getUserSessions(
      String firebaseUID, String gymClassId) async {
    List<GymUserSessionClass> listGymUserSessionsData = [];
    String url = dbUrl + "gym_session_users.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        if (firebaseUID.trim() == json['user_id'] &&
            gymClassId == json['gym_class_id']) {
          listGymUserSessionsData.add(GymUserSessionClass(
              gym_user_session_id: json['gym_user_session_id'] ?? "",
              gym_session_id: json['gym_session_id'] ?? "",
              gym_class_id: json['gym_class_id'] ?? "",
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
  } // getUserSessions

  Stream<List<GymSessionClass>> getStreamSession(String gymClassId) {
    final dbref = FirebaseDatabase.instance.ref("gym_sessions");

    return dbref.onValue.map((event) {
      final List<GymSessionClass> listGymSessionsData = [];
      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((key, json) {
        if (gymClassId == json['gym_class_id']) {
          listGymSessionsData.add(GymSessionClass(
              gym_session_id: json['gym_session_id'] ?? "",
              gym_class_id: json['gym_class_id'] ?? "",
              for_date_schedule: json['for_date_schedule'] ?? "",
              for_day_schedule: json['for_day_schedule'] ?? "",
              for_time_range_schedule: json['for_time_range_schedule'] ?? "",
              price_per_day: json['price_per_day'] ?? "",
              trainer_id: json['trainer_id'] ?? "",
              date_time_actual_finished:
                  json['date_time_actual_finished'] ?? "",
              status: json['status'] ?? ""));
        }
      });

      listGymSessionsData.sort((
        a,
        b,
      ) =>
          DateTime.parse(a.for_date_schedule)
              .compareTo(DateTime.parse(b.for_date_schedule)));

      return listGymSessionsData;
    });
  } // getStreamSession

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const UserMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 13);
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160))))),
            centerTitle: true,
            title: Column(children: [
              Text("Your Sessions with",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(trainerFullname ?? "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(classTitle!.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12))
            ])),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
                    stream: getStreamSession(classId ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                "Sessions still empty, Wait for trainer confirmation"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final rawList = snapshot.data!;
                      final deduplicated = <String, dynamic>{}; // Map by ID

                      for (var item in rawList) {
                        deduplicated[item.gym_session_id] =
                            item; // always replaces older
                      }

                      final uniqueList = deduplicated.values.toList();

                      return ListView.builder(
                          itemCount: uniqueList.length,
                          itemBuilder: (context, index) {
                            final dataContent = uniqueList[index];

                            String dateSchedule = dataContent.for_date_schedule;
                            String dateScheduleFormat =
                                DateFormat("MMM dd, yyyy")
                                    .format(DateTime.parse(dateSchedule));
                            String price_per_day = dataContent.price_per_day;
                            String sessionId = dataContent.gym_session_id;
                            String classId = dataContent.gym_class_id;
                            String trainerId = dataContent.trainer_id;
                            String sessionStatus = dataContent.status;

                            String dateTimeFinished =
                                dataContent.date_time_actual_finished;

                            String gym_session_user_status =
                                listGymUserSessionData
                                            .where((gymUserSession) =>
                                                gymUserSession.gym_session_id ==
                                                sessionId)
                                            .toList()
                                            .length >
                                        0
                                    ? listGymUserSessionData
                                        .where((gymUserSession) =>
                                            gymUserSession.gym_session_id ==
                                            sessionId)
                                        .first
                                        .status
                                    : "";

                            String userSessionId = listGymUserSessionData
                                        .where((gymUserSession) =>
                                            gymUserSession.gym_session_id ==
                                            sessionId)
                                        .toList()
                                        .length >
                                    0
                                ? listGymUserSessionData
                                    .where((gymUserSession) =>
                                        gymUserSession.gym_session_id ==
                                        sessionId)
                                    .first
                                    .gym_user_session_id
                                : "";
                            Icon iconSession = Icon(Icons.class_outlined,
                                color: Colors.black87);

                            Color colorBoxSession =
                                Colors.grey.withOpacity(0.3);

                            if (sessionStatus == "1" &&
                                gym_session_user_status == "1") {
                              iconSession = Icon(Icons.class_outlined,
                                  color: Colors.white);
                              colorBoxSession = Colors.green;
                            }

                            if (sessionStatus == "1" &&
                                gym_session_user_status != "1") {
                              iconSession = Icon(Icons.class_outlined,
                                  color: Colors.white);
                              colorBoxSession = Colors.orangeAccent;
                            }

                            return Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black12))),
                                padding: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width - 20,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: colorBoxSession),
                                          child: iconSession),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 15),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              225,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(dateScheduleFormat),
                                                Text("PHP " + price_per_day,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))
                                              ])),
                                      Text(
                                          gymUserSessionStatus == "0"
                                              ? "Pay upon\nTrainer's Confirmation"
                                              : "",
                                          style: TextStyle(fontSize: 12)),
                                      Visibility(
                                        visible: gymUserSessionStatus == "1"
                                            ? true
                                            : false,
                                        child: GestureDetector(
                                          onTap: () {
                                            String? firebaseUIDValue =
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                                    .toString();

                                            if (gym_session_user_status ==
                                                    "1" ||
                                                gym_session_user_status ==
                                                    "2") {
                                            } else {
                                              payUserSession(
                                                  context,
                                                  gcashAdmin ?? "",
                                                  price_per_day,
                                                  classId,
                                                  classTitle!.toUpperCase() ??
                                                      "",
                                                  dateScheduleFormat,
                                                  sessionId,
                                                  trainerId,
                                                  dateTimeFinished,
                                                  userSessionId);

                                              setState(() {
                                                gym_session_user_status = "1";
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text("Receipt for " +
                                                          dateScheduleFormat +
                                                          " session uploaded!\nPlease wait for admin confirmation of payment")));
                                            }
                                          },
                                          child: Container(
                                              width: 115,
                                              decoration: BoxDecoration(
                                                  border: gym_session_user_status ==
                                                          "1"
                                                      ? Border.all(
                                                          color: Colors.grey)
                                                      : Border.all(
                                                          color: Colors
                                                              .transparent),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: gym_session_user_status !=
                                                          "1"
                                                      ? Color.fromARGB(
                                                          199, 167, 10, 180)
                                                      : Colors.transparent),
                                              padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                  right: 18,
                                                  left: 18),
                                              child: Text(
                                                  textAlign: TextAlign.center,
                                                  gym_session_user_status == "1"
                                                      ? "Paid"
                                                      : gym_session_user_status ==
                                                              "2"
                                                          ? "Uploaded Receipt"
                                                          : "Pay Now",
                                                  style: TextStyle(
                                                      color:
                                                          gym_session_user_status !=
                                                                  "1"
                                                              ? Colors.white
                                                              : Colors.grey))),
                                        ),
                                      )
                                    ]));
                          });
                    }))));
  }
}
