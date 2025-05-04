class TransactionClass {
  final String transaction_id;
  final String transaction_set_id;
  final String subscription_plan_id;
  final String gym_program_id;
  final String gym_session_id;
  final String transaction_type;
  final String payment_method;
  final String total_price;
  final String amount_change;
  final String total_paid;
  final String image_receipt_url;
  final String discount_applied;
  final String date_time_transaction;
  final String trainer_id;
  final String user_id;
  final String from_transaction_id;
  final String status;
  final String admin_handled;
  final String admin_handled_date_time;
  final String remarks;

  TransactionClass(
      {required this.transaction_id,
      required this.transaction_set_id,
      required this.subscription_plan_id,
      required this.gym_program_id,
      required this.gym_session_id,
      required this.transaction_type,
      required this.payment_method,
      required this.total_price,
      required this.amount_change,
      required this.total_paid,
      required this.image_receipt_url,
      required this.discount_applied,
      required this.date_time_transaction,
      required this.trainer_id,
      required this.user_id,
      required this.from_transaction_id,
      required this.status,
      required this.admin_handled,
      required this.admin_handled_date_time,
      required this.remarks});

  Map<String, dynamic> toMap() {
    return {
      transaction_id: transaction_id,
      transaction_set_id: transaction_set_id,
      subscription_plan_id: subscription_plan_id,
      gym_program_id: gym_program_id,
      gym_session_id: gym_session_id,
      transaction_type: transaction_type,
      payment_method: payment_method,
      total_price: total_price,
      amount_change: amount_change,
      total_paid: total_paid,
      image_receipt_url: image_receipt_url,
      discount_applied: discount_applied,
      date_time_transaction: date_time_transaction,
      trainer_id: trainer_id,
      user_id: user_id,
      from_transaction_id: from_transaction_id,
      status: status,
      admin_handled: admin_handled,
      admin_handled_date_time: admin_handled_date_time,
      remarks: remarks
    };
  }

  factory TransactionClass.fromJson(Map<String, dynamic> json) {
    return TransactionClass(
        transaction_id: json['transaction_id'],
        transaction_set_id: json['transaction_set_id'],
        subscription_plan_id: json['subscription_plan_id'],
        gym_program_id: json['gym_program_id'],
        gym_session_id: json['gym_session_id'],
        transaction_type: json['transaction_type'],
        payment_method: json['payment_method'],
        total_price: json['total_price'],
        amount_change: json['amount_change'],
        total_paid: json[' total_paid'],
        image_receipt_url: json['image_receipt_url'],
        discount_applied: json['discount_applied'],
        date_time_transaction: json['date_time_transaction'],
        trainer_id: json['trainer_id'],
        user_id: json['user_id'],
        from_transaction_id: json['from_transaction_id'],
        status: json['status'],
        admin_handled: json['admin_handled'],
        admin_handled_date_time: json['admin_handled_date_time'],
        remarks: json['remarks']);
  }
}
