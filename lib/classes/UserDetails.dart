class UserDetails {
  final String firebase_uid;
  final String username;
  final String firstname;
  final String middlename;
  final String lastname;
  final String ext;
  final String email;
  final String phone;
  final String otp;
  final String occupation;
  final String title;
  final String role;
  final String date_time_membership;
  final String date_time_premium_activated;
  final String date_time_registered;
  final String email_verified;

  UserDetails(
      {required this.firebase_uid,
      required this.username,
      required this.firstname,
      required this.middlename,
      required this.lastname,
      required this.ext,
      required this.email,
      required this.phone,
      required this.otp,
      required this.occupation,
      required this.title,
      required this.role,
      required this.date_time_membership,
      required this.date_time_premium_activated,
      required this.date_time_registered,
      required this.email_verified});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'firebase_uid': firebase_uid,
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'ext': ext,
      'email': email,
      'phone': phone,
      'otp': otp,
      'occupation': occupation,
      'title': title,
      'role': role,
      'date_time_membership': date_time_membership,
      'date_time_premium_activated': date_time_premium_activated,
      'date_time_registered': date_time_registered,
      'email_verified': email_verified
    };
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
        username: json['username'],
        firebase_uid: json['firebase_uid'],
        firstname: json['firstname'],
        middlename: json['middlename'],
        lastname: json['lastname'],
        ext: json['ext'],
        email: json['email'],
        phone: json['phone'],
        otp: json['otp'],
        occupation: json['occupation'],
        title: json['title'],
        role: json['role'],
        date_time_membership: json['date_time_membership'],
        date_time_premium_activated: json['date_time_premium_actvated'],
        date_time_registered: json['date_time_registered'],
        email_verified: json['email_verified']);
  }
}
