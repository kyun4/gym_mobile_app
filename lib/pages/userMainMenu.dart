import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fitup/services/storage.service.dart';

import 'package:fitup/pages/userHomePage.dart';
import 'package:fitup/pages/userPremiumSubscription.dart';
import 'package:fitup/pages/userPremiumSubscriptionPayment.dart';
import 'package:fitup/pages/userPremiumSubscriptionPaymentUploadReceipt.dart';
import 'package:fitup/pages/userPremiumSubscriptionPaymentThankYou.dart';
import 'package:fitup/pages/userPremiumSubscriptionPaymentSummary.dart';

import 'package:fitup/pages/userBookingHome.dart';
import 'package:fitup/pages/userChooseTraining.dart';
import 'package:fitup/pages/userSelectNearestGymPartner.dart';
import 'package:fitup/pages/userSearchExercise.dart';
import 'package:fitup/pages/userBookingDateTime.dart';
import 'package:fitup/pages/userTrainerDetailedSearch.dart';
import 'package:fitup/pages/userTrainerProfile.dart';
import 'package:fitup/pages/userTrainerSchedule.dart';
import 'package:fitup/pages/userClassView.dart';
import 'package:fitup/pages/userBookingPreview.dart';
import 'package:fitup/pages/userBookingSummary.dart';
import 'package:fitup/pages/userBookingSuccessful.dart';
import 'package:fitup/pages/userBookingOrders.dart';
import 'package:fitup/pages/userBookingSessions.dart';
import 'package:fitup/pages/userTrainerInquiryConversation.dart';

import 'package:fitup/pages/userVouchers.dart';
import 'package:fitup/pages/userSubscriptionView.dart';
import 'package:fitup/pages/userVoucherList.dart';

import 'package:fitup/pages/userMessages.dart';
import 'package:fitup/pages/userMessageConversation.dart';

import 'package:fitup/pages/userProfilePage.dart';
import 'package:fitup/pages/EditProfileDetails.dart';
import 'package:fitup/pages/userSettings.dart';
import 'package:fitup/pages/userProfileImage.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

int _subSelectedIndex = 0;

class UserMainMenu extends StatefulWidget {
  final int selectedInitIndex;
  final int subSelectedInitIndex;
  const UserMainMenu(
      {super.key,
      required this.selectedInitIndex,
      required this.subSelectedInitIndex});

  @override
  State<UserMainMenu> createState() => _userMainMenuState();
}

class _userMainMenuState extends State<UserMainMenu> {
  int _selectedIndex = 0;

  BuildContext? _currentContext;

  void initState() {
    setState(() {
      _selectedIndex = widget.selectedInitIndex;
      _subSelectedIndex = widget.subSelectedInitIndex;
    });

    super.initState();
  }

  final List<Widget> _pages = [
    UserHomePages(),
    BookingPage(),
    VoucherPageContent(),
    InboxPage(),
    ProfilePageContent()
  ];

  @override
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _subSelectedIndex = 0;
    });
  }

  Widget build(BuildContext context) {
    _currentContext = context;

    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.navigation), label: "Booking"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.topic), label: "Voucher"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), label: "Inbox"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_outlined), label: "Profile")
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.black45));
  }
}

class ProfilePageContent extends StatefulWidget {
  const ProfilePageContent({super.key});

  @override
  State<ProfilePageContent> createState() => _profilePageContentState();
}

class _profilePageContentState extends State<ProfilePageContent> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  } // InboxPage

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 10 &&
        subSelectedIndexLocal <= 14) {
      switch (subSelectedIndexLocal) {
        case 10:
          pageCurrent = const UserSettings();
        case 11:
          pageCurrent = const UserProfileImage();
        case 12:
          pageCurrent = const EditProfileDetails();
        case 13:
          pageCurrent = const UserBookingOrders();
        case 14:
          pageCurrent = const UserBookingSessions();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const ProfilePage();
    }

    return pageCurrent;
  }
} // ProfilePageContent

class VoucherPageContent extends StatefulWidget {
  const VoucherPageContent({super.key});

  @override
  State<VoucherPageContent> createState() => _voucherPageContentState();
}

class _voucherPageContentState extends State<VoucherPageContent> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  } // InboxPage

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 15 &&
        subSelectedIndexLocal <= 20) {
      switch (subSelectedIndexLocal) {
        case 15:
          pageCurrent = const UserSubscriptionView();
        case 16:
          pageCurrent = const UserVoucherList();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const UserVouchers();
    }

    return pageCurrent;
  }
} // VoucherPageContent

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _bookingPageState();
}

class _bookingPageState extends State<BookingPage> {
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

    if (subSelectedIndexLocal >= 21 && subSelectedIndexLocal <= 35) {
      switch (subSelectedIndexLocal) {
        case 21:
          pageCurrent = const UserChooseTraining();
        case 22:
          pageCurrent = const UserSelectNearestGymPartner();
        case 23:
          pageCurrent = const UserSearchExercise();
        case 24:
          pageCurrent = const UserBookingDateTime();
        case 25:
          pageCurrent = const UserTrainerDetailedSearch();
        case 26:
          pageCurrent = const UserTrainerProfile();
        case 27:
          pageCurrent = const UserTrainerInquiryConversation();
        case 28:
          pageCurrent = const UserTrainerSchedule();
        case 29:
          pageCurrent = const UserClassView();
        case 30:
          pageCurrent = const UserBookingPreview();
        case 31:
          pageCurrent = const UserBookingSummary();
        case 32:
          pageCurrent = const UserBookingSuccessful();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const UserBookingHome();
    }

    return pageCurrent;
  }
} // BookingPage()

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _inboxPageState();
}

class _inboxPageState extends State<InboxPage> {
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

    if (subSelectedIndexLocal > 0) {
      switch (subSelectedIndexLocal) {
        case 7:
          pageCurrent = UserMessageConversation();
        default:
          pageCurrent = Text("Page not found");
      }
    } else {
      pageCurrent = UserMessages();
    }

    return pageCurrent;
  }
} // InboxPage

class UserHomePages extends StatefulWidget {
  const UserHomePages({super.key});

  @override
  State<UserHomePages> createState() => userHomePagesState();
} // UserHomePage

class userHomePagesState extends State<UserHomePages> {
  int subSelectedIndexLocal = 0;

  void initState() {
    super.initState();

    setState(() {
      subSelectedIndexLocal = _subSelectedIndex;
    });
  } // InboxPage

  @override
  Widget build(BuildContext context) {
    final pageCurrent;

    if (subSelectedIndexLocal > 0 &&
        subSelectedIndexLocal >= 40 &&
        subSelectedIndexLocal <= 55) {
      switch (subSelectedIndexLocal) {
        case 40:
          pageCurrent = const UserPremiumSubscription();
        case 41:
          pageCurrent = const UserPremiumSubscriptionPayment();
        case 42:
          pageCurrent = const UserPremiumSubscriptionPaymentThankYou();
        case 43:
          pageCurrent = const UserPremiumSubscriptionPaymentSummary();
        case 44:
          pageCurrent = const UserPremiumSubscriptionPaymentUploadReceipt();
        default:
          pageCurrent = const Center(child: Text("Page not found"));
      }
    } else {
      pageCurrent = const UserHomePage();
    }

    return pageCurrent;
  }
}
