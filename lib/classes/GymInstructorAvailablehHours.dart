class GymInstructorAvailableHours {
  final String gym_instructor_available_hours_limit_id;
  final String instructor_id;
  final String added_by;
  final String date_time_last_updated;
  final String day;
  final String time_start;
  final String time_end;
  final String is_active;
  final String is_deleted;
  final String last_updated_by;

  GymInstructorAvailableHours(
      {required this.gym_instructor_available_hours_limit_id,
      required this.instructor_id,
      required this.added_by,
      required this.date_time_last_updated,
      required this.day,
      required this.time_start,
      required this.time_end,
      required this.is_active,
      required this.is_deleted,
      required this.last_updated_by});

  Map<String, dynamic> toMap() {
    return {
      gym_instructor_available_hours_limit_id:
          gym_instructor_available_hours_limit_id,
      instructor_id: instructor_id,
      added_by: added_by,
      date_time_last_updated: date_time_last_updated,
      day: day,
      time_start: time_start,
      time_end: time_end,
      is_active: is_active,
      is_deleted: is_deleted,
      last_updated_by: last_updated_by
    };
  }

  factory GymInstructorAvailableHours.fromJson(Map<String, dynamic> json) {
    return GymInstructorAvailableHours(
        gym_instructor_available_hours_limit_id:
            json['gym_instructor_available_hours_limit_id'],
        instructor_id: json['instructor_id'],
        added_by: json['added_by'],
        date_time_last_updated: json['date_time_last_updated'],
        day: json['day'],
        time_start: json['time_start'],
        time_end: json['time_end'],
        is_active: json['is_active'],
        is_deleted: json['is_deleted'],
        last_updated_by: json['last_updated_by']);
  }
}
