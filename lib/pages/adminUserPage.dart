import 'package:flutter/material.dart';
import 'package:fitup/classes/UserDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  State<AdminUserPage> createState() => _adminUserPageState();
}

Future<List<UserDetails>> getAllUsers(String role) async {
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

  if (role != "0" || role.trim() == "") {
    listUsersData =
        listUsersData.where((userData) => userData.role == role).toList();
  }

  return listUsersData;
} // getAllUsers

String translateRole(String roleId) {
  String roleName = "";
  switch (roleId) {
    case "1":
      roleName = "Gym User";
      break;
    case "2":
      roleName = "Gym Trainer";
      break;
    case "3":
      roleName = "Admin";
      break;
  }

  return roleName;
} // translateRole

class _adminUserPageState extends State<AdminUserPage> {
  String? selectedRole;

  void initState() {
    super.initState();
    selectedRole = "0";
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new, color: Colors.transparent),
            centerTitle: true,
            title: Text("All Users", style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  height: 40,
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = "0";
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.all(1),
                          width: MediaQuery.of(context).size.width * 0.24,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: selectedRole == "0"
                                          ? Colors.black54
                                          : Colors.transparent,
                                      width: 2))),
                          child: Text("All",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12))),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = "3";
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.all(1),
                          width: MediaQuery.of(context).size.width * 0.24,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: selectedRole == "3"
                                          ? Colors.black54
                                          : Colors.transparent,
                                      width: 2))),
                          child: Text("Admin",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12))),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = "2";
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.all(1),
                          width: MediaQuery.of(context).size.width * 0.24,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: selectedRole == "2"
                                          ? Colors.black54
                                          : Colors.transparent,
                                      width: 2))),
                          child: Text("Gym Trainers",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12))),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = "1";
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.all(1),
                          width: MediaQuery.of(context).size.width * 0.24,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: selectedRole == "1"
                                          ? Colors.black54
                                          : Colors.transparent,
                                      width: 2))),
                          child: Text("Gym Users",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12))),
                    )
                  ])),
              Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: StreamBuilder(
                      stream: getAllUsers(selectedRole ?? "").asStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final dataRecord = snapshot.data!;
                        final deduplicated = <String, dynamic>{};

                        for (var item in dataRecord) {
                          deduplicated[item.firebase_uid] = item;
                        }
                        var uniqueList = deduplicated.values.toList();

                        return ListView.builder(
                            itemCount: uniqueList.length,
                            itemBuilder: (context, index) {
                              final dataContent = uniqueList[index];
                              String firebase_uid = dataContent.firebase_uid;
                              String role = dataContent.role;
                              String firstname = dataContent.firstname;
                              String middlename = dataContent.middlename;
                              String lastname = dataContent.lastname;
                              String ext = dataContent.ext;
                              String userFullname = firstname + " " + lastname;
                              String username = dataContent.username;

                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(children: [
                                    Container(
                                        margin: const EdgeInsets.all(10),
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.grey),
                                        child: Icon(Icons.person_3_outlined,
                                            color: Colors.white)),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.50,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(userFullname.toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(translateRole(role))
                                          ]),
                                    )
                                  ]));
                            });
                      })),
            ],
          ),
        )));
  }
}
