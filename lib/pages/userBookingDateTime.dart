import 'package:flutter/material.dart';
import 'package:fitup/components/textFieldSearchGymCustomSlim.dart';
import 'package:fitup/pages/userMainMenu.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:fitup/services/calendar_provider.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserBookingDateTime extends StatefulWidget {
  const UserBookingDateTime({super.key});

  @override
  State<UserBookingDateTime> createState() => _userBookingDateTimeState();
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

class _userBookingDateTimeState extends State<UserBookingDateTime> {
  String? exerciseNameSelected;
  bool _calendarInputVisible = false;
  CalendarFormat? calendarFormatSelected;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;

  FocusNode focusNodeSports = FocusNode();
  FocusNode focusNodeWhen = FocusNode();
  FocusNode focusNodeWhenDayInterval = FocusNode();
  FocusNode focusNodeTimeRange = FocusNode();
  FocusNode focusNodeSearchCoach = FocusNode();

  void getSharedSessionValues() async {
    String? exerciseString = await getSession("exerciseNameSelected");
    setState(() {
      exerciseNameSelected = exerciseString;
    });
  } // getSharedSessionValues

  Future<TimeOfDay?> selectTime(context) async {
    TimeOfDay? _selectedTimeFinal =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (_selectedTimeFinal != null || _selectedTime != _selectedTimeFinal) {
      _selectedTime = _selectedTimeFinal;
    }

    return _selectedTime;
  } // selectTime

  final textSports = new TextEditingController();
  final textWhen = new TextEditingController();
  final textWhenDayInterval = new TextEditingController();
  final textWhenTimeRange = new TextEditingController();
  TextEditingController textSearchCoach = new TextEditingController();
  bool searchCoachHasContent = false;

  void initState() {
    super.initState();
    calendarFormatSelected = CalendarFormat.month;
    getSharedSessionValues();
    getGymPartnerLogoImages();

    textSearchCoach.addListener(() {
      setState(() {
        searchCoachHasContent = textSearchCoach.text.isNotEmpty;
        setSession("coachName", textSearchCoach.text.toString());
      });
    });

    focusNodeWhen.addListener(onTextWhenChange);
  }

  void onTextWhenChange() {
    setState(() {
      _calendarInputVisible = !_calendarInputVisible;
    });
  } // set

  Future<void> getGymPartnerLogoImages() async {
    Provider.of<StorageService>(context, listen: false).getPartnerLogos();
  }

  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context, listen: true);

    return Scaffold(
        body: SafeArea(
            child: ListView(children: [
      SizedBox(height: 15),
      Container(
          margin: const EdgeInsets.only(left: 5),
          alignment: Alignment.centerLeft,
          child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const UserMainMenu(
                      selectedInitIndex: 1, subSelectedInitIndex: 23);
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 0))
                ],
              ),
              child: TextFieldSearchGymCustomSlim(
                  textController: textSports,
                  obscure_text: false,
                  focusNode: focusNodeSports,
                  hint_text_value: "Sports",
                  choosen_value: exerciseNameSelected ?? "",
                  iconSuffix:
                      const Icon(Icons.search, color: Colors.transparent))),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 0))
                ],
              ),
              child: TextFieldSearchGymCustomSlim(
                  textController: textWhen,
                  obscure_text: false,
                  focusNode: focusNodeWhen,
                  hint_text_value: "When",
                  choosen_value: "MM/DD/YYYY to MM/DD/YYYY",
                  iconSuffix:
                      const Icon(Icons.search, color: Colors.transparent))),
          Visibility(
              visible: _calendarInputVisible,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20.0,
                        spreadRadius: 1,
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0, 0),
                      )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: TableCalendar(
                  onDaySelected: (selectedDay, focusedDay) {
                    provider.selectDay(selectedDay);
                  },
                  focusedDay: provider.selectedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2050),
                  selectedDayPredicate: (day) =>
                      isSameDay(provider.selectedDay, day),

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
                  calendarFormat:
                      calendarFormatSelected ?? CalendarFormat.month,
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
              )),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 0))
                ],
              ),
              child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(top: 7),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Available Time",
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 100),
                        GestureDetector(
                            onTap: () async {
                              TimeOfDay? StartTime = await selectTime(context);

                              setState(() {
                                _selectedTimeStart = StartTime;
                                setSession("selectedTimeStart",
                                    _selectedTimeStart.toString());
                              });
                            },
                            child: Text(_selectedTimeStart == null
                                ? "HH:mm"
                                : _selectedTimeStart.toString())),
                        Text("to"),
                        GestureDetector(
                            onTap: () async {
                              TimeOfDay? EndTime = await selectTime(context);

                              setState(() {
                                _selectedTimeEnd = EndTime;
                                setSession("selectedTimeEnd",
                                    _selectedTimeEnd.toString());
                              });
                            },
                            child: Text(_selectedTimeEnd == null
                                ? "HH:mm"
                                : _selectedTimeEnd.toString())),
                      ]))),
          Container(
              padding: const EdgeInsets.all(18),
              child: Text("Filter by Trainer",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(199, 116, 10, 180)))),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 0))
                ],
              ),
              child: TextFieldSearchGymCustomSlim(
                  textController: textSearchCoach,
                  obscure_text: false,
                  focusNode: focusNodeSearchCoach,
                  hint_text_value: "Search specific coach",
                  choosen_value: "",
                  iconSuffix:
                      const Icon(Icons.search, color: Colors.transparent))),
          Visibility(
            visible: true,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const UserMainMenu(
                      selectedInitIndex: 1, subSelectedInitIndex: 25);
                }));
              },
              child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(199, 118, 10, 160)),
                  child: const Text("Search Now",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
            ),
          ),
        ],
      ),
    ])));
  }
}
