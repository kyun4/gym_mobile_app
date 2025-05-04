import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitup/services/calendar_provider.dart';
import 'package:provider/provider.dart';
import 'package:fitup/classes/GymTrainerClasses.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class InstructorSchedule extends StatefulWidget {
  const InstructorSchedule({super.key});
  @override
  State<InstructorSchedule> createState() => _instructorScheduleState();
}

Future<List<GymTrainerClasses>> getClassesJson(String fUID) async {
  final List<GymTrainerClasses> listGymTrainer = [];

  String url = dbUrl + "gym_trainer_classes.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((id, json) {
      if (fUID == json['firebase_uid']) {
        listGymTrainer.add(GymTrainerClasses(
            gym_trainer_class_id: json['gym_trainer_class_id'] ?? "",
            training_category_id: json['training_category_id'] ?? "",
            class_name: json['class_name'] ?? "",
            class_description: json['class_description'] ?? "",
            price_per_day: json["price_per_day"],
            cover_photo_url: json['cover_photo_url'],
            best_for: json['best_for'] ?? "",
            exercise_id: json['exercise_id'] ?? "",
            date_start: json['date_start'] ?? "",
            date_end: json['date_end'],
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
      }
    });
  } catch (error) {
    throw error;
  }

  return listGymTrainer;
} // getClassesJson

Stream<List<GymTrainerClasses>> getClasses(String fUID) {
  final List<GymTrainerClasses> listTrainerClases = [];

  final databaseRef = FirebaseDatabase.instance.ref('gym_trainer_classes');

  return databaseRef.onValue.map((event) {
    final extractedData =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    extractedData.forEach((id, json) {
      if (fUID == json['firebase_uid']) {
        listTrainerClases.add(GymTrainerClasses(
            gym_trainer_class_id: json['gym_trainer_class_id'] ?? "",
            training_category_id: json['training_category_id'] ?? "",
            class_name: json['class_name'] ?? "",
            class_description: json['class_description'] ?? "",
            price_per_day: json["price_per_day"],
            cover_photo_url: json['cover_photo_url'],
            best_for: json['best_for'] ?? "",
            exercise_id: json['exercise_id'] ?? "",
            date_start: json['date_start'] ?? "",
            date_end: json['date_end'],
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
      }
    });

    return listTrainerClases;
  });
} // getClasses

class _instructorScheduleState extends State<InstructorSchedule> {
  CalendarFormat? calendarFormatSelected;

  String? firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
  List<GymTrainerClasses> listGymTrainer = [];

  void initState() {
    super.initState();
    getGymTrainerClassList();
  }

  void getGymTrainerClassList() async {
    List<GymTrainerClasses> listGymTrainerList = [];
    listGymTrainerList = await getClassesJson(firebaseUID ?? "");

    setState(() {
      listGymTrainer = listGymTrainerList;
      calendarFormatSelected = CalendarFormat.month;
    });
  } // getGymTrainerClassList

  void deleteSession(String child_key) {
    final databaseRef = FirebaseDatabase.instance.ref("gym_sessions");
    databaseRef.child(child_key).remove();
  } // deleteSession

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context, listen: true);
    int dataGymTrainerClass = listGymTrainer.length;
    String dataTrainerClass = dataGymTrainerClass.toString();

    provider.clearEvents();

    for (var dataSnapshot in listGymTrainer) {
      String dateStart = dataSnapshot.date_start;
      String dateEnd = dataSnapshot.date_end;
      String className = dataSnapshot.class_name;
      String classDesc = dataSnapshot.class_description;
      String level = dataSnapshot.level;
      String scheduledTimes = dataSnapshot.schedule_times;
      String scheduledDays = dataSnapshot.scheduled_days;

      List<String> weekDayIndexPresent = [];
      List<String> days = scheduledDays.split(",");

      for (int j = 0; j < days.length; j++) {
        if (days[j] == "Monday") {
          weekDayIndexPresent.add("1");
        }
        if (days[j] == "Tuesday") {
          weekDayIndexPresent.add("2");
        }
        if (days[j] == "Wednesday") {
          weekDayIndexPresent.add("3");
        }
        if (days[j] == "Thursday") {
          weekDayIndexPresent.add("4");
        }
        if (days[j] == "Friday") {
          weekDayIndexPresent.add("5");
        }
        if (days[j] == "Saturday") {
          weekDayIndexPresent.add("6");
        }
        if (days[j] == "Sunday") {
          weekDayIndexPresent.add("0");
        }
      }

      Duration lenghtDate =
          DateTime.parse(dateEnd).difference(DateTime.parse(dateStart));

      for (int i = 0; i < lenghtDate.inDays; i++) {
        final scheduledDate = DateTime.parse(dateStart).add(Duration(days: i));

        int dayIndex = scheduledDate.weekday;
        int isPresent = weekDayIndexPresent
            .where((dataIndex) => dataIndex == dayIndex.toString())
            .length;

        // String timeRange = scheduledTimes.split(',')[dayIndex];

        if (isPresent > 0) {
          provider.addEventWithNote(scheduledDate, " " + className, level);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.calendar_month),
        title: Text("Schedules", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          TableCalendar(
            onDaySelected: (selectedDay, focusedDay) {
              provider.selectDay(selectedDay);
            },
            focusedDay: provider.selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            selectedDayPredicate: (day) => isSameDay(provider.selectedDay, day),

            calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(198, 214, 4, 233),
                    shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(199, 167, 10, 180),
                  shape: BoxShape.circle,
                )),

            availableCalendarFormats: const {
              CalendarFormat.week: 'Month View',
              CalendarFormat.month: 'Week View',
            },
            calendarFormat: calendarFormatSelected ?? CalendarFormat.month,
            onFormatChanged: (formatName) {
              setState(() {
                calendarFormatSelected = formatName;
              });
            },
            eventLoader: (day) => provider.getEventsForDay(day),
            // headerStyle: HeaderStyle(formatButtonVisible: false),
            // onRangeSelected: (start, end, focusedDay) {
            //   provider.selectRange(start, end);
            // },
          ),
          SizedBox(height: 8.0),
          _buildEventList(provider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context, provider),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList(CalendarProvider provider) {
    final selectedEvents = provider.getEventsForDay(provider.selectedDay);

    return Expanded(
      child: ListView.builder(
        itemCount: selectedEvents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedEvents[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => provider.removeEvent(
                  provider.selectedDay, selectedEvents[index]),
            ),
          );
        },
      ),
    );
  }

  void _addEventDialog(BuildContext context, CalendarProvider provider) {
    final eventController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event with Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: eventController,
              decoration: InputDecoration(hintText: 'Enter event name'),
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(hintText: 'Enter event note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.addEventWithNote(provider.selectedDay,
                  eventController.text, noteController.text);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  } // addEventDialog
}
