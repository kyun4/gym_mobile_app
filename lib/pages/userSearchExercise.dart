import 'package:flutter/material.dart';
import 'package:fitup/components/textFieldSearchGymCustomSecondary.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:provider/provider.dart';
import 'package:fitup/classes/GymExercises.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserSearchExercise extends StatefulWidget {
  const UserSearchExercise({super.key});

  @override
  State<UserSearchExercise> createState() => _userSearchExerciseState();
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

Stream<List<GymExercises>> getExercises() {
  final databaseRef = FirebaseDatabase.instance.ref('exercises');

  return databaseRef.onValue.map((event) {
    final List<GymExercises> listExercises = [];
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((dataId, data) {
      listExercises.add(GymExercises(
          exercise_id: data['exercise_id'],
          exercise_name: data['exercise_name'],
          details: data['details'],
          icon: data['icon'],
          improve: data['improve'],
          added_by: data['added_by'],
          status: data['status'],
          date_time_added: data['date_time_added'],
          last_updated_by: data['last_updated_by'],
          date_time_last_updated: data['date_time_last_updated']));
    });

    return listExercises;
  });
} // getExercises()

class _userSearchExerciseState extends State<UserSearchExercise> {
  final textSearchExercise = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      SizedBox(height: 15),
      Container(
          margin: const EdgeInsets.only(left: 5),
          alignment: Alignment.centerLeft,
          child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const UserMainMenu(
                      selectedInitIndex: 1, subSelectedInitIndex: 22);
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
                          color: const Color.fromARGB(199, 118, 10, 160)))))),
      Container(
        height: 370,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 1,
                offset: Offset(0, 0))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 7),
              child: Text("What Exercise?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color.fromARGB(199, 116, 10, 180))),
            ),
            SizedBox(height: 20),
            Container(
                child: TextFieldSearchGymCustomSecondary(
                    textController: textSearchExercise,
                    obscure_text: false,
                    hint_text_value: "Search Exercise",
                    iconPrefix: const Icon(Icons.search, color: Colors.black87),
                    iconSuffix:
                        const Icon(Icons.clear, color: Colors.black38))),
            SizedBox(height: 10),
            Container(
                margin: const EdgeInsets.only(top: 10, bottom: 15, left: 10),
                child: Row(children: [
                  Icon(Icons.info_outlined, size: 16),
                  Text(" Suggested sports", style: TextStyle(fontSize: 12))
                ])),
            Container(
                height: 140,
                width: MediaQuery.of(context).size.width - 50,
                child: StreamBuilder(
                    stream: getExercises(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: const Text("Error Loading Exercises ..."));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: const Text("Loading Exercises ..."));
                      }
                      int listCount = snapshot.data!.length;

                      return ListView.builder(
                          itemCount: listCount,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!;

                            String icon = data[index].icon;
                            String exerciseName = data[index].exercise_name;
                            String exerciseId = data[index].exercise_id;

                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setSession(
                                          "exerciseNameSelected", exerciseName);
                                      setSession("exercise_id", exerciseId);
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const UserMainMenu(
                                            selectedInitIndex: 1,
                                            subSelectedInitIndex: 24);
                                      }));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(20),
                                      height: 100,
                                      width: 105,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              199, 116, 10, 180)),
                                      child: SvgPicture.asset(
                                          "assets/svg/$icon",
                                          color: Colors.white,
                                          height: 35),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    child: Text(exerciseName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45
                                                .withOpacity(0.5))),
                                  ),
                                ],
                              ),
                            );
                          });
                    }))
          ],
        ),
      ),
      SizedBox(height: 15),
    ])));
  }
}
