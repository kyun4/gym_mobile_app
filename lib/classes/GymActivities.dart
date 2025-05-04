class GymActivities {
  final String gym_activity_id;
  final String gym_activity_name;
  final String duration;
  final String difficulty;
  final String added_by;
  final String date_time_added;
  final String date_time_last_updated;
  final String is_active;
  final String is_deleted;
  final String repetition;
  final String sets;
  final String last_updated_by;

  GymActivities(
      {required this.gym_activity_id,
      required this.gym_activity_name,
      required this.duration,
      required this.difficulty,
      required this.added_by,
      required this.date_time_added,
      required this.date_time_last_updated,
      required this.is_active,
      required this.is_deleted,
      required this.repetition,
      required this.sets,
      required this.last_updated_by});

  Map<String, dynamic> toMap() {
    return {
      gym_activity_id: gym_activity_id,
      gym_activity_name: gym_activity_name,
      duration: duration,
      difficulty: difficulty,
      added_by: added_by,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated,
      is_active: is_active,
      is_deleted: is_deleted,
      repetition: repetition,
      sets: sets,
      last_updated_by: last_updated_by
    };
  }

  factory GymActivities.fromJson(Map<String, dynamic> json) {
    return GymActivities(
        gym_activity_id: json['gym_activity_id'],
        gym_activity_name: json['gym_activity_name'],
        duration: json['duration'],
        difficulty: json['difficulty'],
        added_by: json['added_by'],
        date_time_added: json['date_time_added'],
        date_time_last_updated: json['date_time_last_updated'],
        is_active: json['is_active'],
        is_deleted: json['is_deleted'],
        repetition: json['repetition'],
        sets: json['sets'],
        last_updated_by: json['last_updated_by']);
  }
}
