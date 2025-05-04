class SubscriptionPlan {
  final String subscription_plan_id;
  final String details;
  final String subscription_name;
  final String price_per_unit;
  final String unit;
  final String added_by;
  final String date_time_added;
  final String last_updated_by;
  final String date_time_last_updated;

  SubscriptionPlan(
      {required this.subscription_plan_id,
      required this.details,
      required this.subscription_name,
      required this.price_per_unit,
      required this.unit,
      required this.added_by,
      required this.date_time_added,
      required this.last_updated_by,
      required this.date_time_last_updated});

  Map<String, dynamic> toMap() {
    return {
      subscription_plan_id: subscription_plan_id,
      details: details,
      subscription_name: subscription_name,
      price_per_unit: price_per_unit,
      unit: unit,
      added_by: added_by,
      date_time_added: date_time_added,
      last_updated_by: last_updated_by,
      date_time_last_updated: date_time_last_updated
    };
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
        subscription_plan_id: json['subscription_plan_id'],
        details: json['details'],
        subscription_name: json['subscription_name'],
        price_per_unit: json['price_per_unit'],
        unit: json['unit'],
        added_by: json['added_by'],
        date_time_added: json['date_time_added'],
        last_updated_by: json['last_updated_by'],
        date_time_last_updated: json['date_time_last_updated']);
  }
}
