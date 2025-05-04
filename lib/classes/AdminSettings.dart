class AdminSettings {
  final String admin_settings_id;
  final String fitup_service_fee;
  final String apple_pay_payment_account;
  final String apple_pay_payment_date_time_last_updated;
  final String apple_pay_updated_by;
  final String gcash_payment_account;
  final String gcash_payment_date_time_last_updated;
  final String gcash_payment_updated_by;
  final String paypal_payment_account;
  final String paypal_payment_date_time_last_updated;
  final String paypal_payment_updated_by;

  AdminSettings({
    required this.admin_settings_id,
    required this.fitup_service_fee,
    required this.apple_pay_payment_account,
    required this.apple_pay_payment_date_time_last_updated,
    required this.apple_pay_updated_by,
    required this.gcash_payment_account,
    required this.gcash_payment_date_time_last_updated,
    required this.gcash_payment_updated_by,
    required this.paypal_payment_account,
    required this.paypal_payment_date_time_last_updated,
    required this.paypal_payment_updated_by,
  });

  Map<String, dynamic> toMap() {
    return {
      admin_settings_id: admin_settings_id,
      fitup_service_fee: fitup_service_fee,
      apple_pay_payment_account: apple_pay_payment_account,
      apple_pay_payment_date_time_last_updated:
          apple_pay_payment_date_time_last_updated,
      apple_pay_updated_by: apple_pay_updated_by,
      gcash_payment_account: gcash_payment_account,
      gcash_payment_date_time_last_updated:
          gcash_payment_date_time_last_updated,
      gcash_payment_updated_by: gcash_payment_updated_by,
      paypal_payment_account: paypal_payment_account,
      paypal_payment_date_time_last_updated:
          paypal_payment_date_time_last_updated,
      paypal_payment_updated_by: paypal_payment_updated_by
    };
  }

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
        admin_settings_id: json['admin_settings_id'],
        fitup_service_fee: json['fitup_service_fee'],
        apple_pay_payment_account: json['apple_pay_payment_account'],
        apple_pay_payment_date_time_last_updated:
            json['apple_pay_payment_date_time_last_updated'],
        apple_pay_updated_by: json['apple_pay_updated_by,'],
        gcash_payment_account: json['gcash_payment_account'],
        gcash_payment_date_time_last_updated:
            json['gcash_payment_date_time_last_updated'],
        gcash_payment_updated_by: json['gcash_payment_updated_by'],
        paypal_payment_account: json['paypal_payment_account'],
        paypal_payment_date_time_last_updated:
            json['paypal_payment_date_time_last_updated'],
        paypal_payment_updated_by: json[' paypal_payment_updated_by']);
  }
}
