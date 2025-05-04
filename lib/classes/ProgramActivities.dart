class ProgramActivities {
  final String program_activity_id;
  final String program_id;
  final String added_by;
  final String date_time_added;
  final String date_time_last_updated;
  final String is_active;
  final String is_deleted;
  final String last_updated_by;

  ProgramActivities(
      {required this.program_activity_id,
      required this.program_id,
      required this.added_by,
      required this.date_time_added,
      required this.date_time_last_updated,
      required this.is_active,
      required this.is_deleted,
      required this.last_updated_by});

  Map<String, dynamic> toMap() {
    return {
      program_activity_id: program_activity_id,
      program_id: program_id,
      added_by: added_by,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated,
      is_active: is_active,
      is_deleted: is_deleted,
      last_updated_by: last_updated_by
    };
  }

  factory ProgramActivities.fromJson(Map<String, dynamic> json) {
    return ProgramActivities(
        program_activity_id: json['program_activity_id'],
        program_id: json['program_id'],
        added_by: json['added_by'],
        date_time_added: json['date_time_addedd'],
        date_time_last_updated: json['date_time_last_updated'],
        is_active: json['is_active'],
        is_deleted: json['is_deleted'],
        last_updated_by: json['last_updated_by']);
  }
}
