import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/pages/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/classes/userPaymentMethod.dart';
import 'package:fitup/classes/UserPremiumPlan.dart';
import 'package:fitup/classes/SubscriptionPlan.dart';
import 'package:fitup/classes/AdsClass.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _userHomePageState();
}

Stream<List<UserPremiumPlan>> getUserPremiumPlans(String firebaseuid) {
  final databaseRef = FirebaseDatabase.instance.ref('user_premium_plan');

  return databaseRef.onValue.map((event) {
    final List<UserPremiumPlan> listUserPlan = [];

    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((dataId, data) {
      if (firebaseuid == data['user_id']) {
        return listUserPlan.add(UserPremiumPlan(
            user_premium_plan_id: data['user_premium_plan_id'],
            subscription_plan_id: data['subscription_plan_id'],
            date_time_joined: data['date_time_joined'],
            date_time_activated: data['date_time_activated'],
            activated_by: data['activated_by'],
            user_id: data['user_id'],
            status: data['status']));
      }
    });

    return listUserPlan;
  });
} // getUserPremiumPlans

Future<String> getEmailVerificationStatusByFirebaseEmail(
    String firebaseEmail) async {
  String? emailVerified;
  String url = "https://fitup-43ee3-default-rtdb.firebaseio.com/users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['email'] == firebaseEmail) {
        emailVerified = json['email_verified'] ?? "";
      }
    });
  } catch (error) {
    throw error;
  }
  return emailVerified ?? "";
} // getEmailVerificationStatusByFirebaseEmail

Stream<List<AdsClass>> getAds() {
  final List<AdsClass> list_ads = [];

  final databaseRef = FirebaseDatabase.instance.ref('ads');

  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);
    extractedData.forEach((dataId, json) {
      list_ads.add(AdsClass(
          ads_id: json['ads_id'],
          ads_image_url: json['ads_image_url'],
          ads_title: json['ads_title'],
          ads_description: json['ads_description'],
          date_time_added: json['date_time_added'],
          added_by: json['added_by'],
          date_time_last_updated: json['date_time_last_updated'],
          last_updated_by: json['last_updated_by'],
          status: json['status']));
    });

    list_ads.shuffle();

    return list_ads;
  });
} // getAds()

Future<List<SubscriptionPlan>> getSubscriptionPlan(BuildContext context) async {
  String url = "https://fitup-43ee3-default-rtdb.firebaseio.com/" +
      "subscription_plan.json";

  final List<SubscriptionPlan> subscriptionPlanListData = [];

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((dataId, data) {
      subscriptionPlanListData.add(SubscriptionPlan(
          subscription_plan_id: data['subscription_plan_id'] ?? "",
          subscription_name: data['subscription_name'] ?? "",
          details: data['details'] ?? "",
          price_per_unit: data['price_per_unit'] ?? "",
          unit: data['unit'] ?? "",
          date_time_added: data['date_time_added'] ?? "",
          added_by: data['added_by'] ?? "",
          date_time_last_updated: data['date_time_last_updated'] ?? "",
          last_updated_by: data['last_updated_by'] ?? ""));
    });
  } catch (error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$error")));
  }

  return subscriptionPlanListData;
} // getSubscriptionPlan

class _userHomePageState extends State<UserHomePage> {
  List<UserPaymentMethod> userPaymentMethodList = [];
  List<SubscriptionPlan> subscriptionPlanList = [];
  List<AdsClass> adsList = [];
  final StreamController<List<AdsClass>> _streamAdsController =
      StreamController();

  String? firebaseUID;
  String? firebaseEmail;
  String? profileImageUrl;
  String? emailVerified;

  Future<void> getImages() async {
    await Provider.of<StorageService>(context, listen: false).getFetchImages();
  }

  void getSubscriptionLoad() async {
    List<SubscriptionPlan> subPlan = [];
    subPlan = await getSubscriptionPlan(context);
    setState(() {
      subscriptionPlanList = subPlan;
    });
  } // getSubscriptionLoad

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

  @override
  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    firebaseEmail = FirebaseAuth.instance.currentUser!.email.toString();

    getSubscriptionLoad();
    getImages();
    getLatestProfile();
    getEmailVerificationStatus();
  }

  void getEmailVerificationStatus() async {
    String emailVerifiedValue =
        await getEmailVerificationStatusByFirebaseEmail(firebaseEmail ?? "");
    setState(() {
      emailVerified = emailVerifiedValue;
    });

    if (emailVerified == "false") {
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Splash();
      }));
    }
  } // getEmailVerificationStatus()

  Future<void> getLatestProfile() async {
    String? latestProfileURL = await getUserImageData(firebaseUID ?? "");
    setState(() {
      profileImageUrl = latestProfileURL;
    });
  } // getLatestProfile()

  Future<String> getUserImageData(String firebaseUID) async {
    String imageUrl = "";
    String url =
        "https://fitup-43ee3-default-rtdb.firebaseio.com/" + "user_images.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((id, data) {
        if (data['user_id'] == firebaseUID && data['status'] == "1") {
          imageUrl = data['image_url'] ?? "";
        }
      });
    } catch (error) {
      throw error;
    }

    return imageUrl;
  } // getUserImageData

  @override
  Widget build(BuildContext) {
    return Scaffold(
        body: Container(
      child: Column(
        children: [
          Padding(
              padding:
                  const EdgeInsets.only(top: 50, right: 5, left: 5, bottom: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: ClipOval(
                            child: profileImageUrl != null
                                ? Image.network(
                                    height: 50,
                                    width: 50,
                                    profileImageUrl ?? "",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, StackTrace) {
                                    return Center(
                                        child: SvgPicture.asset(
                                            "assets/svg/user-profile-svgrepo-com.svg",
                                            height: 50));
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
                                : SvgPicture.asset(
                                    "assets/svg/user-profile-svgrepo-com.svg",
                                    height: 50))),
                    Column(children: [
                      SizedBox(height: 3),
                      Text("FIT UP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color.fromARGB(199, 118, 10, 160))),
                      GestureDetector(
                        onTap: () async {
                          String? premium_activate =
                              await getSession("premium_activated");

                          if (premium_activate != null) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return UserMainMenu(
                                  selectedInitIndex: 0,
                                  subSelectedInitIndex: 43);
                            }));
                          } else {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return UserMainMenu(
                                  selectedInitIndex: 0,
                                  subSelectedInitIndex: 40);
                            }));
                          }
                        },
                        child: Container(
                          width: 235,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(199, 118, 10, 160)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StreamBuilder(
                                    stream:
                                        getUserPremiumPlans(firebaseUID ?? ""),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text("Go to Premium",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)));
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: Text(
                                                "Loading Premium Detail ...",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)));
                                      }

                                      final data = snapshot.data!;
                                      int dataLength = snapshot.data!.length;
                                      String subscriptionStatus = "";

                                      if (dataLength > 0) {
                                        subscriptionStatus = data[0].status;
                                      }

                                      if (subscriptionStatus == "1") {
                                        setSession("premium_activated",
                                            data[0].subscription_plan_id);
                                      } else {
                                        removeSession("premium_activated");
                                      }

                                      return Text(
                                          dataLength > 0 &&
                                                  subscriptionStatus == "1"
                                              ? subscriptionPlanList.length > 0
                                                  ? subscriptionPlanList
                                                      .where((planData) =>
                                                          planData
                                                              .subscription_plan_id ==
                                                          data[0]
                                                              .subscription_plan_id)
                                                      .first
                                                      .subscription_name
                                                  : "Pending Subscription"

                                              // data[0].subscription_plan_id
                                              : "Go to Premium",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white));
                                    }),
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.all(2),
                                    child: SvgPicture.asset(
                                        "assets/svg/crown-svgrepo-com.svg",
                                        color: Colors.white,
                                        height: 14),
                                    height: 24)
                              ]),
                        ),
                      )
                    ]),
                    Container(
                        child: SvgPicture.asset(
                            "assets/svg/user-profile-svgrepo-com.svg",
                            color: Colors.transparent))
                  ])),
          Expanded(
              child: StreamBuilder(
                  stream: getAds(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: const Text("Loading ..."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const CircularProgressIndicator());
                    }

                    final data = snapshot.data;

                    return Scaffold(
                      body: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final imageURL = data![index].ads_image_url;
                            String title = data![index].ads_title;
                            String description = data![index].ads_description;

                            return Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withOpacity(0.1)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                          child: Image.network(imageURL,
                                              loadingBuilder: (context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                      loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Container(
                                            margin: const EdgeInsets.all(10),
                                            child: Center(
                                                child: CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null)),
                                          );
                                        }
                                      }, fit: BoxFit.cover)),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Visibility(
                                                        visible: false,
                                                        child: Icon(
                                                            Icons.location_pin,
                                                            color:
                                                                Color.fromARGB(
                                                                    199,
                                                                    118,
                                                                    10,
                                                                    160)),
                                                      ),
                                                      Text(title,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ]),
                                                  ]),
                                              SizedBox(height: 8),
                                              Text(description,
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              SizedBox(height: 8),
                                              Visibility(
                                                visible: false,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Php 500/Day",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          "Discounted if booked early",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300)),
                                                    ]),
                                              ),
                                            ]),
                                      )
                                    ]));
                          }),
                    );
                  })),
        ],
      ),
    ));
  }
}
