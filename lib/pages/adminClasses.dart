import 'package:flutter/material.dart';
import 'package:fitup/classes/AppConfig.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String dbUrl = AppConfig.dbUrl;

class AdminClasses extends StatefulWidget {
  const AdminClasses({super.key});
  State<AdminClasses> createState() => _adminClassesState();
}

Future<List<GymTrainerClasses>> getGymClasses() async {
  List<GymTrainerClasses> listGymTrainerData = [];
  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return [];
    }

    extractedData.forEach((key, json) {
      listGymTrainerData.add(GymTrainerClasses(
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
  return listGymTrainerData;
} // getGymClasses

class _adminClassesState extends State<AdminClasses> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.transparent),
            centerTitle: true,
            title: Text("Gym Classes", style: TextStyle(fontSize: 14))),
        body: SafeArea(
            child: Container(
                child: StreamBuilder(
                    stream: getGymClasses().asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("No data available"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final dataRaw = snapshot.data!;
                      final deduplicated = <String, dynamic>{};

                      for (var item in dataRaw) {
                        deduplicated[item.gym_trainer_class_id] = item;
                      }

                      var uniqueList = deduplicated.values.toList();

                      return ListView.builder(
                          itemCount: uniqueList.length,
                          itemBuilder: (context, index) {
                            final dataContent = uniqueList[index];
                            String className = dataContent.class_name;
                            String classDescription =
                                dataContent.class_description;
                            String firebaseUID = dataContent.firebase_uid;
                            return Container(
                                padding: const EdgeInsets.all(15),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.class_rounded),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(className,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                              Text(classDescription)
                                            ]),
                                      )
                                    ]));
                          });
                    }))));
  }
}
