class GymProgram {
  final String gym_program_id;
  final String gym_program_name;
  final String added_by;
  final String date_time_added;
  final String date_time_last_updated;
  final String gym_id;
  final String is_active;
  final String is_deleted;
  final String is_premium;
  final String last_updated_by;

  GymProgram(
      {required this.gym_program_id,
      required this.gym_program_name,
      required this.added_by,
      required this.date_time_added,
      required this.date_time_last_updated,
      required this.gym_id,
      required this.is_active,
      required this.is_deleted,
      required this.is_premium,
      required this.last_updated_by});

  Map<String, dynamic> toMap() {
    return {
      gym_program_id: gym_program_id,
      gym_program_name: gym_program_name,
      added_by: added_by,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated,
      gym_id: gym_id,
      is_active: is_active,
      is_deleted: is_deleted,
      is_premium: is_premium,
      last_updated_by: last_updated_by
    };
  }

  factory GymProgram.fromJson(Map<String, dynamic> json) {
    return GymProgram(
        gym_program_id: json['gym_program_id'],
        gym_program_name: json['gym_program_name'],
        added_by: json['added_by'],
        date_time_added: json['date_time_added'],
        date_time_last_updated: json['date_time_last_updated'],
        gym_id: json['gym_id'],
        is_active: json['is_active'],
        is_deleted: json['is_deleted'],
        is_premium: json['is_premium'],
        last_updated_by: json['last_updated_by']);
  }
}
