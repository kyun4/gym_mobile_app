class GymExercises {
  final String exercise_id;
  final String details;
  final String exercise_name;
  final String icon;
  final String improve;
  final String status;
  final String date_time_added;
  final String added_by;
  final String date_time_last_updated;
  final String last_updated_by;

  GymExercises(
      {required this.exercise_id,
      required this.details,
      required this.exercise_name,
      required this.icon,
      required this.improve,
      required this.status,
      required this.date_time_added,
      required this.added_by,
      required this.date_time_last_updated,
      required this.last_updated_by});

  Map<String, dynamic> toMap() {
    return {
      exercise_id: exercise_id,
      details: details,
      exercise_name: exercise_name,
      icon: icon,
      improve: improve,
      status: status,
      date_time_added: date_time_added,
      added_by: added_by,
      date_time_last_updated: date_time_last_updated,
      last_updated_by: last_updated_by
    };
  }

  factory GymExercises.fromJson(Map<String, dynamic> json) {
    return GymExercises(
        exercise_id: json['exercise_id'],
        details: json['details'],
        exercise_name: json['exercise_name'],
        icon: json['icon'],
        improve: json['improve'],
        status: json['status'],
        date_time_added: json['date_time_added'],
        added_by: json['added_by'],
        date_time_last_updated: json['date_time_last_updated'],
        last_updated_by: json['last_updated_by']);
  }
}
