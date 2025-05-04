class UserPremiumPlan {
  final String user_premium_plan_id;
  final String subscription_plan_id;
  final String date_time_joined;
  final String date_time_activated;
  final String activated_by;
  final String user_id;
  final String status;

  UserPremiumPlan(
      {required this.user_premium_plan_id,
      required this.subscription_plan_id,
      required this.date_time_joined,
      required this.date_time_activated,
      required this.activated_by,
      required this.user_id,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      user_premium_plan_id: user_premium_plan_id,
      subscription_plan_id: subscription_plan_id,
      date_time_joined: date_time_joined,
      date_time_activated: date_time_activated,
      activated_by: activated_by,
      user_id: user_id,
      status: status
    };
  }

  factory UserPremiumPlan.fromJson(Map<String, dynamic> json) {
    return UserPremiumPlan(
        user_premium_plan_id: json['user_premium_plan_id'],
        subscription_plan_id: json['subscription_plan_id'],
        date_time_joined: json['date_time_joined'],
        date_time_activated: json['date_time_activated'],
        activated_by: json['activated_by'],
        user_id: json['user_id'],
        status: json['status']);
  }
}
