import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitup/pages/splash.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitup/classes/Users.dart';
import 'package:fitup/classes/UserDetails.dart';
import 'package:fitup/classes/messages.dart';
import 'package:fitup/classes/TransactionClass.dart';
import 'package:fitup/classes/fitupwallet.dart';

import 'package:fitup/pages/adminAds.dart';
import 'package:fitup/pages/AdminClasses.dart';
import 'package:fitup/pages/adminSales.dart';
import 'package:fitup/pages/adminTransaction.dart';
import 'package:fitup/pages/adminUserPage.dart';
import 'package:fitup/pages/adminReport.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:fitup/pages/instructorSchedule.dart';

import 'package:fitup/pages/instructorClassesMenu.dart';

import 'package:fitup/pages/instructorProfileMenu.dart';
import 'package:fitup/pages/instructorProfileMenu.dart';
import 'package:fitup/pages/userProfileImage.dart';
import 'package:fitup/pages/EditProfileDetails.dart';
import 'package:fitup/pages/userSettings.dart';
import 'package:fitup/pages/adminProfilePage.dart';

import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:fitup/services/calendar_provider.dart';
import 'package:fitup/services/firebase_services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

List<Users> usersList = [];

int _subSelectedIndex = 0;

class AdminMainMenu extends StatefulWidget {
  final int selectedInitIndex;
  final int subSelectedInitIndex;

  const AdminMainMenu(
      {super.key,
      required this.selectedInitIndex,
      required this.subSelectedInitIndex});

  @override
  State<AdminMainMenu> createState() => _adminMainMenuState();
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

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  print('User signed out');
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const Splash();
  }));
}

class getUserDetails extends StatelessWidget {
  void initState() async {}

  Future<String> getDataUsers(BuildContext context) async {
    String nameDetails = "";
    String roleDetected = "";

    User? user = FirebaseAuth.instance.currentUser;

    var url = dbUrl + "users.json";

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      String firebaseUid = user != null ? user!.uid : "";

      extractedData.forEach((userId, userData) {
        String userDataId = userData['firebase_uid'] ?? "";
        if (userDataId == firebaseUid) {
          String firstName = userData['firstname'] ?? "";
          String lastName = userData['lastname'] ?? "";

          nameDetails = firstName + " " + lastName + "";

          roleDetected = userData['role'] ?? "";

          usersList.add(Users(
              firebase_uid: userData['firebase_uid'] ?? "",
              username: userData['username'] ?? "",
              firstname: userData['firstname'] ?? "",
              middlename: userData['middlename'] ?? "",
              lastname: userData['lastname'] ?? "",
              role: userData['role'] ?? "",
              ext: userData['ext'] ?? "",
              email: userData['email'] ?? "",
              phone: userData['phone'] ?? "",
              otp: userData['otp'] ?? "",
              occupation: userData['occupation'] ?? "",
              title: userData['title'] ?? "",
              date_time_premium_activated:
                  userData['date_time_premium_activated'] ?? "",
              date_time_membership: userData['date_time_membership'] ?? "",
              date_time_registered: userData['date_time_registered'] ?? "",
              email_verified: userData['email_verified'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    if (roleDetected != '3') {
      removeSession("training_venue");
      removeSession("exerciseNameSelected");
      removeSession("coachName");
      removeSession("selectedStartTime");
      removeSession("selectedEndTime");
      signOut(context);
    }

    return nameDetails;
  } // getSUserDetails

  Widget build(BuildContext Context) {
    return FutureBuilder(
        future: getDataUsers(Context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.toString(),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18));
          } else {
            return const Text("Administrator");
          }
        });
  }
}

class _adminMainMenuState extends State<AdminMainMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AdminGymClassesPage(),
    AdminTransaction(),
    AdminUser(),
    AdminReportPage()
  ];

  void initState() {
    setState(() {
      _selectedIndex = widget.selectedInitIndex;
      _subSelectedIndex = widget.subSelectedInitIndex;
    });

    super.initState();
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _subSelectedIndex = 0;

      if (_selectedIndex == 1) {
        removeSession("client_request_mode");
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.class_outlined), label: 'Classes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.currency_exchange), label: 'Transaction'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_outlined), label: 'Users'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.report), label: 'Reports'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemSelected,
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.black38));
  }
}

class AdminGymClassesPage extends StatefulWidget {
  const AdminGymClassesPage({super.key});

  @override
  State<AdminGymClassesPage> createState() => _adminGymClassesPageState();
}

class _adminGymClassesPageState extends State<AdminGymClassesPage> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 81 &&
        subSelectedIndexLocal <= 100) {
      switch (subSelectedIndexLocal) {
        case 81:
          pageCurrent = const AdminProfilePage();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const AdminClasses();
    }

    return pageCurrent;
  }
} // AdminGymClassesPage

class AdminAdsPage extends StatefulWidget {
  const AdminAdsPage({super.key});

  @override
  State<AdminAdsPage> createState() => _adminAdsPageState();
}

class _adminAdsPageState extends State<AdminAdsPage> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 81 &&
        subSelectedIndexLocal <= 100) {
      switch (subSelectedIndexLocal) {
        case 81:
          pageCurrent = const AdminProfilePage();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const AdminAds();
    }

    return pageCurrent;
  }
} // AdminAdsPage

class AdminTransactionPage extends StatefulWidget {
  const AdminTransactionPage({super.key});

  @override
  State<AdminTransactionPage> createState() => _adminTransactionPageState();
}

class _adminTransactionPageState extends State<AdminTransactionPage> {
  final TextEditingController locationAddress = new TextEditingController();
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 21 &&
        subSelectedIndexLocal <= 40) {
      switch (subSelectedIndexLocal) {
        case 56:
          pageCurrent = const Center(child: Text("Blank"));
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = AdminTransactionPage();
    }

    return pageCurrent;
  }
} // AdminTransactionPage

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _adminUserState();
}

class _adminUserState extends State<AdminUser> {
  final TextEditingController locationAddress = new TextEditingController();
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 41 &&
        subSelectedIndexLocal <= 60) {
      switch (subSelectedIndexLocal) {
        case 41:
          pageCurrent = const AdminProfilePage();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = AdminUserPage();
    }

    return pageCurrent;
  }
} // AdminUserPage

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _adminReportPageState();
}

class _adminReportPageState extends State<AdminReportPage> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 61 &&
        subSelectedIndexLocal <= 80) {
      switch (subSelectedIndexLocal) {
        case 56:
          pageCurrent = const Center(child: Text("Blank"));
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = AdminReport();
    }

    return pageCurrent;
  }
} // AdminReportPage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPage();
} // DashboardPage

class _DashboardPage extends State<DashboardPage> {
  String? clientRequestNumber = "0";
  String? firebaseUID;
  String? profileImageUrl;
  List<Messages> listClientRequestMessages = [];
  List<UserDetails> listUsers = [];
  List<TransactionClass> listTransactions = [];
  String? trainersCount;
  String? usersCount;
  String? adminCount;
  String? thisMonthSales;
  String? fitupWalletBalance;
  String? thisMonthTrainerCollected;

  double thisMonthSalesDouble = 0.0;
  double thisMonthTrainerCollectedDouble = 0.0;

  String januarySales = "0";
  String februarySales = "0";
  String marchSales = "0";
  String aprilSales = "0";
  String maySales = "0";
  String juneSales = "0";
  String julySales = "0";
  String augustSales = "0";
  String septemberSales = "0";
  String octoberSales = "0";
  String novemberSales = "0";
  String decemberSales = "0";

  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();

    getLatestProfile(firebaseUID ?? "");
    getFitUpWalletBalance();
    getTransactions();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });

    retrieveUsers();
  }

  void retrieveUsers() async {
    List<UserDetails> listUserData = await getAllUsers();
    setState(() {
      listUsers = listUserData;
      adminCount = listUserData
          .where((userData) => userData.role == '3')
          .toList()
          .length
          .toString();
      trainersCount = listUserData
          .where((userData) => userData.role == '2')
          .toList()
          .length
          .toString();
      usersCount = listUserData
          .where((userData) => userData.role == '1')
          .toList()
          .length
          .toString();
    });
  } // retrieveUsers

  Future<List<FitUpWallet>> getFitUpWallet() async {
    List<FitUpWallet> listFitupWalletData = [];
    String url = dbUrl + "fitup_wallet.json";

    try {
      final response = await http.get(Uri.parse(url));
      final Map<String, dynamic> extractedData = json.decode(response.body);

      if (extractedData == null || response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        listFitupWalletData.add(FitUpWallet(
            fitup_wallet_id: json['fitup_wallet_id'],
            current_balance: json['current_balance'],
            date_time_last_updated: json['date_time_last_updated']));
      });
    } catch (error) {
      throw error;
    }

    return listFitupWalletData;
  } // getFitUpWallet

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
            date_time_premium_activated:
                json['date_time_premium_actvated'] ?? "",
            date_time_registered: json['date_time_registered'] ?? "",
            email_verified: json['email_verified'] ?? ""));
      });
    } catch (error) {
      throw error;
    }
    return listUsersData;
  } // getAllUsers

  double getCurrentYearMonthSales(
      int year, int month, List<TransactionClass> listTransactionDatas) {
    List<TransactionClass> listTransactionDataValue = listTransactionDatas
        .where((transactionData) =>
            transactionData.transaction_type == '1' &&
            DateTime.parse(transactionData.date_time_transaction).year ==
                year &&
            DateTime.parse(transactionData.date_time_transaction).month ==
                month)
        .toList();

    double thisMonthSalesDoubleValue =
        listTransactionDataValue.fold(0.0, (sum, item) {
      return sum + double.parse(item.total_paid);
    });

    return thisMonthSalesDoubleValue;
  } // getCurrentYearMonthSales

  void getTransactions() async {
    List<TransactionClass> listTransactionDataValue =
        await getTransactionsData();

    List<TransactionClass> listTransactionDataValueThisMonth = [];
    List<TransactionClass> listTransactionTrainerCollectedDataValueThisMonth =
        [];

    double januaryMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 1, listTransactionDataValue);

    double februaryMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 2, listTransactionDataValue);

    double marchMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 3, listTransactionDataValue);

    double aprilMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 4, listTransactionDataValue);

    double mayMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 5, listTransactionDataValue);

    double juneMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 6, listTransactionDataValue);

    double julyMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 7, listTransactionDataValue);

    double augMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 8, listTransactionDataValue);

    double sepMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 9, listTransactionDataValue);

    double octMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 10, listTransactionDataValue);

    double novMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 11, listTransactionDataValue);

    double decMonthSalesDoubleValue = getCurrentYearMonthSales(
        DateTime.now().year, 12, listTransactionDataValue);

    listTransactionDataValueThisMonth = listTransactionDataValue
        .where((transactionData) =>
            transactionData.transaction_type == '1' &&
            DateTime.parse(transactionData.date_time_transaction).year ==
                DateTime.now().year &&
            DateTime.parse(transactionData.date_time_transaction).month ==
                DateTime.now().month)
        .toList();

    double thisMonthSalesDoubleValue =
        listTransactionDataValueThisMonth.fold(0.0, (sum, item) {
      return sum + double.parse(item.total_paid);
    });

    listTransactionTrainerCollectedDataValueThisMonth = listTransactionDataValue
        .where((transactionData) =>
            transactionData.transaction_type == '3' &&
            DateTime.parse(transactionData.date_time_transaction).year ==
                DateTime.now().year &&
            DateTime.parse(transactionData.date_time_transaction).month ==
                DateTime.now().month)
        .toList();

    double thisMonthTrainerCollectedDoubleValue =
        listTransactionTrainerCollectedDataValueThisMonth.fold(0.0,
            (sum, item) {
      return sum + double.parse(item.total_paid);
    });

    setState(() {
      thisMonthSalesDouble = thisMonthSalesDoubleValue;
      thisMonthSales = "PHP " + thisMonthSalesDouble.toStringAsFixed(2);
      thisMonthTrainerCollectedDouble = thisMonthTrainerCollectedDoubleValue;
      thisMonthTrainerCollected =
          "PHP " + thisMonthTrainerCollectedDouble.toStringAsFixed(2);
      januarySales = januaryMonthSalesDoubleValue.toStringAsFixed(2);
      februarySales = februaryMonthSalesDoubleValue.toStringAsFixed(2);
      marchSales = marchMonthSalesDoubleValue.toStringAsFixed(2);
      aprilSales = aprilMonthSalesDoubleValue.toStringAsFixed(2);
      maySales = mayMonthSalesDoubleValue.toStringAsFixed(2);
      juneSales = juneMonthSalesDoubleValue.toStringAsFixed(2);
      julySales = julyMonthSalesDoubleValue.toStringAsFixed(2);
      augustSales = augMonthSalesDoubleValue.toStringAsFixed(2);
      septemberSales = sepMonthSalesDoubleValue.toStringAsFixed(2);
      octoberSales = octMonthSalesDoubleValue.toStringAsFixed(2);
      novemberSales = novMonthSalesDoubleValue.toStringAsFixed(2);
      decemberSales = decMonthSalesDoubleValue.toStringAsFixed(2);
      listTransactions = listTransactionDataValue;
    });
  } // getTransactions

  void getFitUpWalletBalance() async {
    List<FitUpWallet> listFitupWalletData = await getFitUpWallet();
    String? fitUpCurrentBalanceValue =
        listFitupWalletData.toList()[0].current_balance;

    double currentBalance = double.parse(fitUpCurrentBalanceValue);
    setState(() {
      fitupWalletBalance = "PHP " + currentBalance.toStringAsFixed(2);
    });
  } // getFitUpWalletBalance

  Future<List<TransactionClass>> getTransactionsData() async {
    List<TransactionClass> listData = [];
    try {
      String url = dbUrl + "transaction.json";
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
    } catch (error) {
      throw error;
    }

    return listData;
  } // getTransactions

  Future<String> getUserImageData(String firebaseUID) async {
    String imageUrl = "";
    String url = dbUrl + "user_images.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null || response.body.isEmpty) {
        return "";
      }

      extractedData.forEach((id, data) {
        String userID = data['user_id'] ?? "";
        String status = data['status'] ?? "";
        if (userID == firebaseUID && status == "1") {
          imageUrl = data['image_url'] ?? "";
        }
      });
    } catch (error) {
      throw error;
    }

    return imageUrl;
  } // getUserImageData

  Future<void> getLatestProfile(String fUID) async {
    String? latestProfileURL = await getUserImageData(fUID);
    setState(() {
      profileImageUrl = latestProfileURL;
    });
  } // getLatestProfile()

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 101 &&
        subSelectedIndexLocal <= 120) {
      switch (subSelectedIndexLocal) {
        case 101:
          pageCurrent = const AdminProfilePage();
        case 102:
          pageCurrent = const EditProfileDetails();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = Container(
          child: Container(
              margin: const EdgeInsets.only(top: 35),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ListView(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome Administrator!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            getUserDetails(),
                          ]),
                      GestureDetector(
                        onTap: () {
                          setSession("role", "3");
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const AdminMainMenu(
                                selectedInitIndex: 0,
                                subSelectedInitIndex: 101);
                          }));
                        },
                        child: Container(
                            child: profileImageUrl == null
                                ? SvgPicture.asset(
                                    "assets/svg/user-profile-svgrepo-com.svg",
                                    height: 45)
                                : ClipOval(
                                    child: Image.network(profileImageUrl ?? "",
                                        fit: BoxFit.cover,
                                        height: 45,
                                        width: 45, errorBuilder:
                                            (context, error, StackTrace) {
                                    return SvgPicture.asset(
                                        "assets/svg/user-profile-svgrepo-com.svg",
                                        height: 45);
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
                                  }))),
                      ),
                    ]),
                SizedBox(height: 25),
                Visibility(
                  visible: true,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(197, 247, 237, 245)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10, top: 10),
                          child: Text(DateTime.now().year.toString() + " Sales",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 0, right: 25, top: 35, bottom: 5),
                          height: 220,
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, double.parse(januarySales)),
                                    FlSpot(1, double.parse(februarySales)),
                                    FlSpot(2, double.parse(marchSales)),
                                    FlSpot(3, double.parse(aprilSales)),
                                    FlSpot(4, double.parse(maySales)),
                                    FlSpot(5, double.parse(juneSales)),
                                    FlSpot(6, double.parse(julySales)),
                                    FlSpot(7, double.parse(augustSales)),
                                    FlSpot(8, double.parse(septemberSales)),
                                    FlSpot(9, double.parse(octoberSales)),
                                    FlSpot(10, double.parse(novemberSales)),
                                    FlSpot(11, double.parse(decemberSales)),
                                  ], // Data points for the line graph
                                  isCurved: true, // Makes the line curved
                                  color:
                                      Colors.purpleAccent, // Purple line color
                                  barWidth: 4, // Line thickness
                                  dotData: FlDotData(
                                    show:
                                        true, // Enable dots on intersection points
                                    // Color of the dots
                                  ), // Disable dots on data points
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30, // Space for the labels
                                    getTitlesWidget:
                                        _buildMonthTitles, // Custom function for labels
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      getTitlesWidget: _buildSalesValuesTitles,
                                      showTitles: false,
                                      reservedSize: 30),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                  showTitles: false,
                                )),
                              ),

                              // Shows X and Y titles
                              borderData: FlBorderData(
                                  show: false), // Hide borders around the chart
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * 80,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: Offset(2, 2))
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thisMonthSales ?? "PHP 0.00",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              Text("This Month's Sales",
                                  style: TextStyle(fontSize: 18))
                            ])),
                    Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * 80,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: Offset(2, 2))
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fitupWalletBalance ?? "PHP 0.00",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              Text("Fitup Overall Revenue",
                                  style: TextStyle(fontSize: 18))
                            ])),
                    Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * 80,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: Offset(2, 2))
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thisMonthTrainerCollected ?? "PHP 0.00",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              Text("Trainer's Overall Collection",
                                  style: TextStyle(fontSize: 18))
                            ])),
                    Row(children: [
                      Container(
                          margin: const EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width * 0.425,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(2, 2))
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(usersCount ?? "",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold)),
                                Text("Active Users",
                                    style: TextStyle(fontSize: 18))
                              ])),
                      Container(
                          margin: const EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width * 0.425,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(2, 2))
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trainersCount ?? "",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold)),
                                Text("Trainers", style: TextStyle(fontSize: 18))
                              ]))
                    ]),
                    Container(
                        margin: const EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * 80,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: Offset(2, 2))
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(adminCount ?? "",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              Text("Administrators",
                                  style: TextStyle(fontSize: 18))
                            ])),
                    SizedBox(height: 20)
                  ],
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    height: 175,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: BarChart(
                      BarChartData(
                        barGroups: _buildBarGroups(),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ])));
      ;
    }

    return pageCurrent;
  }
}

List<FlSpot> _getLineSpots() {
  return const [
    FlSpot(0, 0),
    FlSpot(1, 3),
    FlSpot(2, 2),
    FlSpot(3, 5),
    FlSpot(4, 3.5),
    FlSpot(5, 4),
    FlSpot(6, 7.5),
    FlSpot(7, 8),
    FlSpot(8, 10),
    FlSpot(9, 7),
    FlSpot(10, 15),
    FlSpot(11, 17),
  ];
}

Widget _buildMonthTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  // Map values to month labels
  switch (value.toInt()) {
    case 0:
      return Text('Jan', style: style);
    case 1:
      return Text('Feb', style: style);
    case 2:
      return Text('Mar', style: style);
    case 3:
      return Text('Apr', style: style);
    case 4:
      return Text('May', style: style);
    case 5:
      return Text('Jun', style: style);
    case 6:
      return Text('Jul', style: style);
    case 7:
      return Text('Aug', style: style);
    case 8:
      return Text('Sep', style: style);
    case 9:
      return Text('Oct', style: style);
    case 10:
      return Text('Nov', style: style);
    case 11:
      return Text('Dec', style: style);
    default:
      return const SizedBox.shrink(); // No label for undefined values
  }
}

Widget _buildSalesValuesTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  return Text(value.toInt().toString(),
      style: style); // No label for undefined values
}

List<BarChartGroupData> _buildBarGroups() {
  return [
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 14)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15)]),
  ];
}
