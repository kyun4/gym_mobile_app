class UserPaymentMethod {
  final String user_payment_method_id;
  final String user_id;
  final String gcash;
  final String paypal;
  final String apple_pay;
  final String credit_card;
  final String credit_card_expiry;
  final String credit_card_cvc;
  final String gcash_date_time_add;
  final String paypal_date_time_add;
  final String apple_pay_date_time_add;
  final String credit_card_date_time_add;

  UserPaymentMethod(
      {required this.user_payment_method_id,
      required this.user_id,
      required this.gcash,
      required this.paypal,
      required this.apple_pay,
      required this.credit_card,
      required this.credit_card_expiry,
      required this.credit_card_cvc,
      required this.gcash_date_time_add,
      required this.paypal_date_time_add,
      required this.apple_pay_date_time_add,
      required this.credit_card_date_time_add});

  Map<String, dynamic> toMap() {
    return {
      user_payment_method_id: user_payment_method_id,
      user_id: user_id,
      gcash: gcash,
      paypal: paypal,
      apple_pay: apple_pay,
      credit_card: credit_card,
      credit_card_expiry: credit_card_expiry,
      credit_card_cvc: credit_card_cvc,
      gcash_date_time_add: gcash_date_time_add,
      paypal_date_time_add: paypal_date_time_add,
      apple_pay_date_time_add: apple_pay_date_time_add,
      credit_card_date_time_add: credit_card_date_time_add
    };
  }

  factory UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethod(
        user_payment_method_id: json['user_payment_method_id'],
        user_id: json['user_id'],
        gcash: json['gcash'],
        paypal: json['paypal'],
        apple_pay: json['apple_pay'],
        credit_card: json['credit_card'],
        credit_card_expiry: json['credit_card_expiry'],
        credit_card_cvc: json['credit_card_cvc'],
        gcash_date_time_add: json['gcash_date_time_add'],
        paypal_date_time_add: json['paypal_date_time_add'],
        apple_pay_date_time_add: json['apple_pay_date_time_add'],
        credit_card_date_time_add: json['credit_card_date_time_add']);
  }
}
