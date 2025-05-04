class UserImagesClass {
  final String image_url;
  final String user_id;
  final String date_time_added;
  final String status;

  UserImagesClass(
      {required this.image_url,
      required this.user_id,
      required this.date_time_added,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      image_url: image_url,
      user_id: user_id,
      date_time_added: date_time_added,
      status: status
    };
  }

  factory UserImagesClass.fromJson(Map<String, dynamic> json) {
    return UserImagesClass(
        image_url: json['image_url'],
        user_id: json['user_id'],
        date_time_added: json['date_time_added'],
        status: json['status']);
  }
}
