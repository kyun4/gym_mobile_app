class RatingsReviews {
  final String ratings_reviews_id;
  final String rating_from;
  final String rating_from_role;
  final String rating_to;
  final String rating_to_role;
  final String rating_value;
  final String review_content;
  final String transaction_id;
  final String date_time;

  RatingsReviews(
      {required this.ratings_reviews_id,
      required this.rating_from,
      required this.rating_from_role,
      required this.rating_to,
      required this.rating_to_role,
      required this.rating_value,
      required this.review_content,
      required this.transaction_id,
      required this.date_time});

  Map<String, dynamic> toMap() {
    return {
      ratings_reviews_id: ratings_reviews_id,
      rating_from: rating_from,
      rating_from_role: rating_from_role,
      rating_to: rating_to_role,
      rating_value: rating_value,
      review_content: review_content,
      transaction_id: transaction_id,
      date_time: date_time
    };
  }

  factory RatingsReviews.fromJson(Map<String, dynamic> json) {
    return RatingsReviews(
        ratings_reviews_id: json['ratings_reviews_id'],
        rating_from: json['rating_from'],
        rating_from_role: json['rating_from_role'],
        rating_to: json['rating_to'],
        rating_to_role: json['rating_to_role'],
        rating_value: json['rating_value'],
        review_content: json['review_content'],
        transaction_id: json['transaction_id'],
        date_time: json['date_time']);
  }
}
