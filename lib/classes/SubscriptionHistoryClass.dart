class SubscriptionHistoryClass {
  final String subscription_history_id;
  final String transaction_id;
  final String subscription_plan_id;
  final String user_id;
  final String next_payment_date;
  final String next_subscription_plan_id;
  final String interval_month;
  final String amount;
  final String status;

  SubscriptionHistoryClass(
      {required this.subscription_history_id,
      required this.transaction_id,
      required this.subscription_plan_id,
      required this.user_id,
      required this.next_payment_date,
      required this.next_subscription_plan_id,
      required this.interval_month,
      required this.amount,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      subscription_history_id: subscription_history_id,
      transaction_id: transaction_id,
      subscription_plan_id: subscription_plan_id,
      user_id: user_id,
      next_payment_date: next_payment_date,
      next_subscription_plan_id: next_subscription_plan_id,
      interval_month: interval_month,
      amount: amount,
      status: status
    };
  }

  factory SubscriptionHistoryClass.from(Map<String, dynamic> json) {
    return SubscriptionHistoryClass(
        subscription_history_id: json['subscription_history_id'],
        transaction_id: json['transaction_id'],
        subscription_plan_id: json['subscription_plan_id'],
        user_id: json['user_id'],
        next_payment_date: json['next_payment_date'],
        next_subscription_plan_id: json['next_subscription_plan_id'],
        interval_month: json['interval_month'],
        amount: json['amount'],
        status: json['status']);
  }
}
