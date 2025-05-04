class VoucherClass {
  final String voucher_id;
  final String voucher_name;
  final String voucher_type;
  final String product_id;
  final String percent_gym_class_discount;
  final String added_by;
  final String date_time_added;
  final String last_updated_by;
  final String last_updated_date_time;

  VoucherClass(
      {required this.voucher_id,
      required this.voucher_name,
      required this.voucher_type,
      required this.product_id,
      required this.percent_gym_class_discount,
      required this.added_by,
      required this.date_time_added,
      required this.last_updated_by,
      required this.last_updated_date_time});

  Map<String, dynamic> toMap() {
    return {
      voucher_id: voucher_id,
      voucher_name: voucher_name,
      voucher_type: voucher_type,
      product_id: product_id,
      percent_gym_class_discount: percent_gym_class_discount,
      added_by: added_by,
      date_time_added: date_time_added,
      last_updated_by: last_updated_by,
      last_updated_date_time: last_updated_date_time
    };
  }

  factory VoucherClass.fromJson(Map<String, dynamic> json) {
    return VoucherClass(
        voucher_id: json['voucher_id'],
        voucher_name: json['voucher_name'],
        voucher_type: json['voucher_type'],
        product_id: json['product_id'],
        percent_gym_class_discount: json['percent_gym_class_discount'],
        added_by: json['added_by'],
        date_time_added: json['date_time_added'],
        last_updated_by: json['last_updated_by'],
        last_updated_date_time: json['last_updated_date_time']);
  }
}
