class GymTrainerClasses {
  final String gym_trainer_class_id;
  final String training_category_id;
  final String class_name;
  final String class_description;
  final String price_per_day;
  final String cover_photo_url;
  final String best_for;
  final String exercise_id;
  final String date_start;
  final String date_end;
  final String duration_in_mins;
  final String firebase_uid;
  final String date_time_added;
  final String date_time_last_updated;
  final String is_active;
  final String is_done;
  final String schedule_times;
  final String scheduled_days;
  final String session_setup;
  final String level;
  final String users_per_class_limit;
  final String status;

  GymTrainerClasses(
      {required this.gym_trainer_class_id,
      required this.training_category_id,
      required this.class_name,
      required this.class_description,
      required this.price_per_day,
      required this.cover_photo_url,
      required this.best_for,
      required this.exercise_id,
      required this.date_start,
      required this.date_end,
      required this.duration_in_mins,
      required this.firebase_uid,
      required this.date_time_added,
      required this.date_time_last_updated,
      required this.is_active,
      required this.is_done,
      required this.schedule_times,
      required this.scheduled_days,
      required this.session_setup,
      required this.level,
      required this.users_per_class_limit,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      gym_trainer_class_id: gym_trainer_class_id,
      training_category_id: training_category_id,
      class_name: class_name,
      class_description: class_description,
      price_per_day: price_per_day,
      cover_photo_url: cover_photo_url,
      best_for: best_for,
      exercise_id: exercise_id,
      date_start: date_start,
      date_end: date_end,
      duration_in_mins: duration_in_mins,
      firebase_uid: firebase_uid,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated,
      is_active: is_active,
      is_done: is_done,
      schedule_times: schedule_times,
      scheduled_days: scheduled_days,
      session_setup: session_setup,
      level: level,
      users_per_class_limit: users_per_class_limit,
      status: status
    };
  }

  factory GymTrainerClasses.fromJson(Map<String, dynamic> json) {
    return GymTrainerClasses(
        gym_trainer_class_id: json['gym_trainer_class_id'],
        training_category_id: json['training_category_id'],
        class_name: json['class_name'],
        class_description: json['class_description'],
        price_per_day: json['price_per_day'],
        cover_photo_url: json['cover_photo_url'],
        best_for: json['best_for'],
        exercise_id: json['exercise_id'],
        date_start: json['date_start'],
        date_end: json['date_end'],
        duration_in_mins: json['duration_in_mins'],
        firebase_uid: json['firebase_uid'],
        date_time_added: json['date_time_added'],
        date_time_last_updated: json['date_time_last_updated'],
        is_active: json['is_active'],
        is_done: json['is_done'],
        schedule_times: json['schedule_times'],
        scheduled_days: json['scheduled_days'],
        session_setup: json['session_setup'],
        level: json['level'],
        users_per_class_limit: json['users_per_class_limit'],
        status: json['status']);
  }
}
