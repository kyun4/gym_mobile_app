class UserGymClasses {
  final String user_gym_class_id;
  final String gym_class_id;
  final String user_id;
  final String trainer_id;
  final String transaction_id;
  final String status;
  final String payment_status;
  final String date_time_trainer_approved;
  final String date_time_booked;
  final String date_time_admin_approved;
  final String approved_by_admin;

  UserGymClasses(
      {required this.user_gym_class_id,
      required this.gym_class_id,
      required this.user_id,
      required this.payment_status,
      required this.trainer_id,
      required this.transaction_id,
      required this.status,
      required this.date_time_trainer_approved,
      required this.date_time_booked,
      required this.date_time_admin_approved,
      required this.approved_by_admin});

  Map<String, dynamic> toMap() {
    return {
      user_gym_class_id: user_gym_class_id,
      gym_class_id: gym_class_id,
      user_id: user_id,
      trainer_id: trainer_id,
      transaction_id: transaction_id,
      status: status,
      payment_status: payment_status,
      date_time_trainer_approved: date_time_trainer_approved,
      date_time_booked: date_time_booked,
      date_time_admin_approved: date_time_admin_approved,
      approved_by_admin: approved_by_admin
    };
  }

  factory UserGymClasses.fromJson(Map<String, dynamic> json) {
    return UserGymClasses(
        user_gym_class_id: json['user_gym_class_id'],
        gym_class_id: json['gym_class_id'],
        user_id: json['user_id'],
        trainer_id: json['trainer_id'],
        transaction_id: json['transaction_id'],
        status: json['status'],
        payment_status: json['payment_status'],
        date_time_trainer_approved: json['date_time_trainer_approved'],
        date_time_booked: json['date_time_booked'],
        date_time_admin_approved: json['date_time_admin_approved'],
        approved_by_admin: json['approved_by_admin']);
  }
}
