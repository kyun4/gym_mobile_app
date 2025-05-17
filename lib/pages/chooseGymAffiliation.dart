import 'package:flutter/material.dart';
import 'package:fitup/pages/signUpAs.dart';
import 'package:fitup/pages/registerUser.dart';
import 'package:fitup/classes/GymNames.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitup/classes/AppConfig.dart';

import 'package:shared_preferences/shared_preferences.dart';

String dbUrl = AppConfig.dbUrl;

class ChooseGymAffiliation extends StatefulWidget {
  final String roleAccount;
  const ChooseGymAffiliation({super.key, required this.roleAccount});

  State<ChooseGymAffiliation> createState() => _chooseGymAffiliationState();
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

Future<List<GymNames>> getGymNames() async {
  List<GymNames> listGymNamesData = [];
  String url = dbUrl + "gym_names.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listGymNamesData.add(GymNames(
          gym_id: json['gym_id'] ?? "",
          gym_name: json['gym_name'] ?? "",
          gym_photo_url: json['gym_photo_url'] ?? "",
          address: json['address'] ?? "",
          email: json['email'] ?? "",
          gym_phone: json['gym_phone'] ?? "",
          is_active: json['is_active'] ?? "",
          is_deleted: json['is_deleted'] ?? "",
          last_updated_by: json['last_updated_by'] ?? "",
          added_by: json['added_by'] ?? "",
          date_time_added: json['date_time_added'] ?? "",
          date_time_last_updated: json['date_time_last_updated'] ?? ""));
    });

    listGymNamesData.add(GymNames(
        gym_id: "1",
        gym_name: "I'm an Independent Gym Trainer",
        gym_photo_url: "",
        address: "",
        email: "",
        gym_phone: "",
        is_active: "",
        is_deleted: "",
        last_updated_by: "",
        added_by: "",
        date_time_added: "",
        date_time_last_updated: ""));
  } catch (error) {
    throw error;
  }

  return listGymNamesData;
} // getGymNames

class _chooseGymAffiliationState extends State<ChooseGymAffiliation> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const SignUpAs();
                  }));
                },
                child: Container(
                    child: Icon(Icons.arrow_back,
                        color: const Color.fromARGB(199, 118, 10, 160)),
                    margin: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromARGB(199, 118, 10, 160)))))),
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 25, top: 10, bottom: 25),
                  child: Text("On what Gym Brand\ndo you train now?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24))),
              Container(
                height: MediaQuery.of(context).size.height - 250,
                child: StreamBuilder(
                    stream: getGymNames().asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("No image found"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final dataContent = snapshot.data![index];
                            String gymId = dataContent.gym_id;
                            String gym_name = dataContent.gym_name;
                            String gym_logo_url = dataContent.gym_photo_url;

                            return GestureDetector(
                              onTap: () {
                                setSession("gym_selected_id", gymId);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const RegisterUser(registerRole: "2");
                                }));
                              },
                              child: Container(
                                  height: 85,
                                  width: 125,
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 10, top: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                            color:
                                                Colors.grey.withOpacity(0.10),
                                            offset: Offset(7, 7))
                                      ]),
                                  child: Image.network(gym_logo_url,
                                      errorBuilder:
                                          (context, error, StackTrace) {
                                    return Container(
                                        padding: const EdgeInsets.only(top: 25),
                                        color: Colors.white,
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            "I'm an Independent Gym Trainer",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 18)));
                                  })),
                            );
                          });
                    }),
              ),
            ])));
  }
}
