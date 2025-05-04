class TrainerWallet {
  final String trainer_wallet_id;
  final String current_balance;
  final String date_time_last_updated;
  final String trainer_id;

  TrainerWallet(
      {required this.trainer_wallet_id,
      required this.current_balance,
      required this.date_time_last_updated,
      required this.trainer_id});

  Map<String, dynamic> toMap() {
    return {
      trainer_wallet_id: trainer_wallet_id,
      current_balance: current_balance,
      date_time_last_updated: date_time_last_updated,
      trainer_id: trainer_id
    };
  }

  factory TrainerWallet.fromJson(Map<String, dynamic> json) {
    return TrainerWallet(
        trainer_wallet_id: json['trainer_wallet_id'],
        current_balance: json['current_balance'],
        date_time_last_updated: json['date_time_last_updated'],
        trainer_id: json['trainer_id']);
  }
}
