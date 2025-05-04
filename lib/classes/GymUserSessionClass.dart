class GymUserSessionClass {
  final String gym_user_session_id;
  final String gym_session_id;
  final String gym_class_id;
  final String date_time_meet;
  final String price_per_day_net;
  final String fitup_service_price;
  final String rating;
  final String review;
  final String status;
  final String trainer_id;
  final String user_id;
  final String price_per_day;
  final String fitup_service_percentage_from_price;
  final String admin_remittance_date_time;
  final String is_trainer_remittance_confirm;

  GymUserSessionClass(
      {required this.gym_user_session_id,
      required this.gym_session_id,
      required this.gym_class_id,
      required this.date_time_meet,
      required this.price_per_day_net,
      required this.fitup_service_price,
      required this.rating,
      required this.review,
      required this.status,
      required this.trainer_id,
      required this.user_id,
      required this.price_per_day,
      required this.fitup_service_percentage_from_price,
      required this.admin_remittance_date_time,
      required this.is_trainer_remittance_confirm});

  Map<String, dynamic> toMap() {
    return {
      gym_user_session_id: gym_user_session_id,
      gym_session_id: gym_session_id,
      gym_class_id: gym_class_id,
      date_time_meet: date_time_meet,
      price_per_day_net: price_per_day_net,
      fitup_service_price: fitup_service_price,
      rating: rating,
      review: review,
      status: status,
      trainer_id: trainer_id,
      user_id: user_id,
      price_per_day: price_per_day,
      fitup_service_percentage_from_price: fitup_service_percentage_from_price,
      admin_remittance_date_time: admin_remittance_date_time,
      is_trainer_remittance_confirm: is_trainer_remittance_confirm
    };
  }

  factory GymUserSessionClass.fromJson(Map<String, dynamic> json) {
    return GymUserSessionClass(
        gym_user_session_id: json['gym_user_session_id'],
        gym_session_id: json['gym_session_id'],
        gym_class_id: json['gym_class_id'],
        date_time_meet: json['date_time_meet'],
        price_per_day_net: json['price_per_day_net'],
        fitup_service_price: json['fitup_service_price'],
        rating: json['rating'],
        review: json['review'],
        status: json['status'],
        trainer_id: json['trainer_id'],
        user_id: json['user_id'],
        price_per_day: json['price_per_day'],
        fitup_service_percentage_from_price:
            json['fitup_service_percentage_from_price'],
        admin_remittance_date_time: json['admin_remittance_date_time'],
        is_trainer_remittance_confirm: json['is_trainer_remittance_confirm']);
  }
}
