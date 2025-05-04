import 'package:flutter/material.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fitup/classes/AdminSettings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserPremiumSubscriptionPaymentUploadReceipt extends StatefulWidget {
  const UserPremiumSubscriptionPaymentUploadReceipt({super.key});

  @override
  State<UserPremiumSubscriptionPaymentUploadReceipt> createState() =>
      userPremiumSubscriptionPaymentUploadReceiptState();
}

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

Future<List<AdminSettings>> getAdminSettings() async {
  List<AdminSettings> listAdminSettings = [];

  String url = dbUrl + "admin_settings.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData != null || response.body.isEmpty) {}

    extractedData.forEach((dataId, json) {
      listAdminSettings.add(AdminSettings(
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
          paypal_payment_updated_by: json[' paypal_payment_updated_by'] ?? ""));
    });
  } catch (error) {
    throw error;
  }

  return listAdminSettings;
} // getAdminSettings

class userPremiumSubscriptionPaymentUploadReceiptState
    extends State<UserPremiumSubscriptionPaymentUploadReceipt> {
  double _widthPlan = 0;
  bool isSelectedPlanOne = false;
  bool isSelectedPlanTwo = false;
  bool isSelectedPlanThree = false;
  bool isSelectedPlanFour = false;
  String? planString;
  String? rateString;
  String? paymentMethod;
  String? accountNumber;
  String? adminAccountNumber;
  String? planName;
  String? planDescription;
  String? planPricePerUnit;
  String? planPriceUnit;
  String? firebaseUID;
  String? transactionId;
  String? uploadedUrl;
  List<AdminSettings> listAdminSettingsFinal = [];

  void initState() {
    super.initState();
    getCheckoutDetails();
  }

  XFile? _image;
  String? _downloadURL;
  double _progress = 0.0; //

  Future<void> _pickAndUploadImage() async {
    // Pick an image
    XFile? image = await _pickImage();
    if (image != null) {
      // Upload the image and get the download URL
      String? downloadURL = await _uploadImage(image);
      if (downloadURL != null) {
        setState(() {
          _image = image;
          _downloadURL = downloadURL;
          _progress = 0.0;
        });
      }
    }
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child("receipts/${DateTime.now().millisecondsSinceEpoch}.jpg");
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
  }

  Future<void> getCheckoutDetails() async {
    String? paymentMethodTemp;
    String? accountNumberTemp;
    String? planNameTemp;
    String? planDescriptionTemp;
    String? adminAccountNumberTemp;

    List<AdminSettings> listAdminSettingsTemp;

    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();

    var transactionId_value = Uuid();
    transactionId = transactionId_value.v4();

    paymentMethodTemp = await getSession("selected_payment_method");
    accountNumberTemp = await getSession("accountNumber");

    String? planIndex = await getSession("premium_plan");
    planNameTemp = "subscription_plan_id_" + planIndex! + "";

    planDescriptionTemp = await getSession("plan_description");
    listAdminSettingsTemp = await getAdminSettings();

    adminAccountNumberTemp = listAdminSettingsTemp[0].gcash_payment_account;

    setState(() {
      paymentMethod = paymentMethodTemp;
      accountNumber = accountNumberTemp;
      planName = planNameTemp;
      planDescription = planDescriptionTemp;
      listAdminSettingsFinal = listAdminSettingsTemp;
      adminAccountNumber = adminAccountNumberTemp;
    });
  } // getCheckoutDetails

  Widget build(BuildContext) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
          child: Image.asset("assets/images/gymbg2.png", fit: BoxFit.cover)),
      Positioned.fill(
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: ListView(children: [
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
                    Visibility(
                      visible: true,
                      child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Text("Upload Receipt",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white),
                              textAlign: TextAlign.center)),
                    )
                  ]),
                ),
                SizedBox(height: 5),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                        "Send $paymentMethod payment to $adminAccountNumber",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                SizedBox(height: 30),
                Consumer<StorageService>(builder: (context, storage, child) {
                  return GestureDetector(
                    onTap: () {
                      // storage.uploadReceiptImages(firebaseUID ?? "",
                      //     paymentMethod ?? "", transactionId ?? "");

                      _pickAndUploadImage();
                    },
                    child: _downloadURL == null
                        ? Container(
                            height: 100,
                            width: 20,
                            margin: const EdgeInsets.only(left: 60, right: 60),
                            padding: const EdgeInsets.only(top: 20, bottom: 40),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: Color.fromARGB(199, 167, 10, 180)),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87),
                            child: Icon(Icons.upload,
                                color: Color.fromARGB(199, 167, 10, 180),
                                size: 60))
                        : Container(
                            alignment: Alignment.center,
                            child: Image.network(_downloadURL ?? "",
                                fit: BoxFit.cover, loadingBuilder: (context,
                                    Widget child,
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
                            })),
                  );
                }),
                SizedBox(height: 30),
                Container(
                    alignment: Alignment.center,
                    child: Text("Choose File from your Gallery",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                Container(
                    padding:
                        const EdgeInsets.only(top: 40, left: 65, right: 65),
                    child: Text(
                        "Upload your $paymentMethod receipt here, You will be notified for 1 to 7 days if the payment is received!",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300))),
                Container(
                    padding:
                        const EdgeInsets.only(left: 65, right: 65, top: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("TOTAL",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          Text(planDescription ?? "",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))
                        ])),
                Container(
                  padding: const EdgeInsets.only(left: 65, right: 65, top: 20),
                  child: Text(
                      "* Make sure the payment will be coming from $paymentMethod Account Number $accountNumber",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 25),
                if (_progress > 0 && _progress < 1)
                  Container(
                    margin: const EdgeInsets.only(left: 55, right: 55, top: 5),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _progress, // Show the progress
                        ),
                        SizedBox(height: 10),
                        Text(
                            '${(_progress * 100).toStringAsFixed(2)}% uploaded',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    setSession("uploaded_receipt_url", _downloadURL ?? "");
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMainMenu(
                          selectedInitIndex: 0, subSelectedInitIndex: 42);
                    }));
                  },
                  child: Visibility(
                    visible: _progress >= 1.0,
                    child: Container(
                        margin: const EdgeInsets.only(
                            top: 25, left: 60, bottom: 50, right: 60),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, top: 15, bottom: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(197, 241, 38, 224)),
                        child: Text("Upload Receipt",
                            style: TextStyle(color: Colors.white))),
                  ),
                )
              ]))),
    ]));
  }
}
