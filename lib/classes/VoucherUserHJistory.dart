class VoucherUserHistory {
  final String user_voucher_history_id;
  final String user_id;
  final String date_time_claimed;
  final String date_time_given;
  final String no_items_claimed;
  final String voucher_id;

  VoucherUserHistory(
      {required this.user_voucher_history_id,
      required this.user_id,
      required this.date_time_claimed,
      required this.date_time_given,
      required this.no_items_claimed,
      required this.voucher_id});

  Map<String, dynamic> toMap() {
    return {
      user_voucher_history_id: user_voucher_history_id,
      user_id: user_id,
      date_time_claimed: date_time_claimed,
      date_time_given: date_time_given,
      no_items_claimed: no_items_claimed,
      voucher_id: voucher_id
    };
  }

  factory VoucherUserHistory.from(Map<String, dynamic> json) {
    return VoucherUserHistory(
        user_voucher_history_id: json['user_voucher_history_id'],
        user_id: json['user_id'],
        date_time_claimed: json['date_time_claimed'],
        date_time_given: json['date_time_given'],
        no_items_claimed: json['no_items_claimed'],
        voucher_id: json['voucher_id']);
  }
}
