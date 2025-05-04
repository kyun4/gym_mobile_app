import 'package:flutter/material.dart';

class CalendarProvider with ChangeNotifier {
  //DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, List<String>> _events = {};

  DateTime _selectedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void addEventWithNote(DateTime day, String title, String note) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    if (_events[normalizedDate] == null) {
      _events[normalizedDate] = [];
    }
    _events[normalizedDate]!.add('$title - $note');
    notifyListeners();
  }

  void removeEvent(DateTime day, String event) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    _events[normalizedDate]?.remove(event);
    notifyListeners();
  }

  List<String> getEventsForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  // List<String> getEventsForDay(DateTime day) {
  //   return _events[day] ?? [];
  // }

  // DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  // final Map<DateTime, List<String>> _events = {};

  // DateTime get selectedDay => _selectedDay;

  // void selectDay(DateTime day) {
  //   _selectedDay = day;
  //   notifyListeners();
  // }

  // void selectRange(DateTime? start, DateTime? end) {
  //   _rangeStart = start;
  //   _rangeEnd = end;
  //   notifyListeners();
  // }

  // List<String> getEventsForDay(DateTime day) {
  //   return _events[day] ?? [];
  // }

  // void addEvent(DateTime day, String event) {
  //   if (_events[day] == null) {
  //     _events[day] = [];
  //   }
  //   _events[day]!.add(event);
  //   notifyListeners();
  // }

  // void removeEvent(DateTime day, String event) {
  //   _events[day]?.remove(event);
  //   notifyListeners();
  // }

  // void addEventWithNote(DateTime day, String event, String note) {
  //   final normalizedDate = DateTime(day.year, day.month, day.day);
  //   if (_events[normalizedDate] == null) {
  //     _events[normalizedDate] = [];
  //   }
  //   _events[normalizedDate]!.add('$event - $note');
  //   notifyListeners();
  // }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}
