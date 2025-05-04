class GymSessionClass {
  final String gym_session_id;
  final String gym_class_id;
  final String for_date_schedule;
  final String for_day_schedule;
  final String for_time_range_schedule;
  final String price_per_day;
  final String trainer_id;
  final String date_time_actual_finished;
  final String status;

  GymSessionClass(
      {required this.gym_session_id,
      required this.gym_class_id,
      required this.for_date_schedule,
      required this.for_day_schedule,
      required this.for_time_range_schedule,
      required this.price_per_day,
      required this.trainer_id,
      required this.date_time_actual_finished,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      gym_session_id: gym_session_id,
      gym_class_id: gym_class_id,
      for_date_schedule: for_date_schedule,
      for_day_schedule: for_day_schedule,
      for_time_range_schedule: for_time_range_schedule,
      price_per_day: price_per_day,
      trainer_id: trainer_id,
      date_time_actual_finished: date_time_actual_finished,
      status: status
    };
  }

  factory GymSessionClass.fromJson(Map<String, dynamic> json) {
    return GymSessionClass(
        gym_session_id: json['gym_session_id'],
        gym_class_id: json['gym_class_id'],
        for_date_schedule: json['for_date_schedule'],
        for_day_schedule: json['for_day_schedule'],
        for_time_range_schedule: json['for_time_range_schedule'],
        price_per_day: json['price_per_day'],
        trainer_id: json['trainer_id'],
        date_time_actual_finished: json['date_time_actual_finished'],
        status: json['status']);
  }
}
