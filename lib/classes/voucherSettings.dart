class VoucherSettings {
  final String voucher_settings_id;
  final String subscription_plan;
  final String voucher_count;
  final String voucher_id;

  VoucherSettings(
      {required this.voucher_settings_id,
      required this.subscription_plan,
      required this.voucher_count,
      required this.voucher_id});

  Map<String, dynamic> toMap() {
    return {
      voucher_settings_id: voucher_settings_id,
      subscription_plan: subscription_plan,
      voucher_count: voucher_count,
      voucher_id: voucher_id
    };
  }

  factory VoucherSettings.fromJson(Map<String, dynamic> json) {
    return VoucherSettings(
        voucher_settings_id: json['voucher_settings_id'],
        subscription_plan: json['subscription_plan'],
        voucher_count: json['voucher_count'],
        voucher_id: json['voucher_id']);
  }
}
