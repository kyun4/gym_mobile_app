class GymNames {
  final String gym_id;
  final String gym_name;
  final String gym_photo_url;
  final String address;
  final String email;
  final String gym_phone;
  final String is_active;
  final String is_deleted;
  final String last_updated_by;
  final String added_by;
  final String date_time_added;
  final String date_time_last_updated;

  GymNames(
      {required this.gym_id,
      required this.gym_name,
      required this.gym_photo_url,
      required this.address,
      required this.email,
      required this.gym_phone,
      required this.is_active,
      required this.is_deleted,
      required this.last_updated_by,
      required this.added_by,
      required this.date_time_added,
      required this.date_time_last_updated});

  Map<String, dynamic> toMap() {
    return {
      gym_id: gym_id,
      gym_name: gym_name,
      gym_photo_url: gym_photo_url,
      address: address,
      email: email,
      is_active: is_active,
      is_deleted: is_deleted,
      last_updated_by: last_updated_by,
      added_by: added_by,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated
    };
  }

  factory GymNames.fromJson(Map<String, dynamic> json) {
    return GymNames(
        gym_id: json['gym_id'],
        gym_name: json['gym_name'],
        gym_photo_url: json['gym_photo_url'],
        address: json['address'],
        email: json['email'],
        gym_phone: json['gym_phone'],
        is_active: json['is_active'],
        is_deleted: json['is_deleted'],
        last_updated_by: json['last_updated_by'],
        added_by: json['added_by'],
        date_time_added: json['date_time_added'],
        date_time_last_updated: json['date_time_last_updated']);
  }
}
