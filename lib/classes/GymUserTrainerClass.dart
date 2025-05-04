class GymUserTrainerClass {
  final String user_gym_class_id;
  final String user_id;
  final String trainer_id;
  final String transaction_id;
  final String approved_by_admin;
  final String date_time_admin_approved;
  final String date_time_booked;
  final String date_time_trainer_approved;
  final String status;

  GymUserTrainerClass(
      {required this.user_gym_class_id,
      required this.user_id,
      required this.trainer_id,
      required this.transaction_id,
      required this.approved_by_admin,
      required this.date_time_admin_approved,
      required this.date_time_booked,
      required this.date_time_trainer_approved,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      user_gym_class_id: user_gym_class_id,
      user_id: user_id,
      trainer_id: trainer_id,
      transaction_id: transaction_id,
      approved_by_admin: approved_by_admin,
      date_time_admin_approved: date_time_admin_approved,
      date_time_booked: date_time_booked,
      date_time_trainer_approved: date_time_trainer_approved,
      status: status
    };
  }

  factory GymUserTrainerClass.fromJson(Map<String, dynamic> json) {
    return GymUserTrainerClass(
        user_gym_class_id: json['user_gym_class_id'],
        user_id: json['user_id'],
        trainer_id: json['trainer_id'],
        transaction_id: json['transaction_id'],
        approved_by_admin: json['approved_by_admin'],
        date_time_admin_approved: json['date_time_admin_approved'],
        date_time_booked: json['date_time_booked'],
        date_time_trainer_approved: json['date_time_trainer_approved'],
        status: json['status']);
  }
}
