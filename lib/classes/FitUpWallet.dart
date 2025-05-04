class FitUpWallet {
  final String fitup_wallet_id;
  final String current_balance;
  final String date_time_last_updated;

  FitUpWallet(
      {required this.fitup_wallet_id,
      required this.current_balance,
      required this.date_time_last_updated});

  Map<String, dynamic> toMap() {
    return {
      fitup_wallet_id: fitup_wallet_id,
      current_balance: current_balance,
      date_time_last_updated: date_time_last_updated
    };
  }

  factory FitUpWallet.fromJson(Map<String, dynamic> json) {
    return FitUpWallet(
        fitup_wallet_id: json['fitup_wallet_id'],
        current_balance: json['current_balance'],
        date_time_last_updated: json['date_time_last_updated']);
  }
}
