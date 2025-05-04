class AdsClass {
  final String ads_id;
  final String ads_image_url;
  final String ads_title;
  final String ads_description;
  final String date_time_added;
  final String added_by;
  final String date_time_last_updated;
  final String last_updated_by;
  final String status;

  AdsClass(
      {required this.ads_id,
      required this.ads_image_url,
      required this.ads_title,
      required this.ads_description,
      required this.date_time_added,
      required this.added_by,
      required this.date_time_last_updated,
      required this.last_updated_by,
      required this.status});

  Map<String, dynamic> toMap() {
    return {
      ads_id: ads_id,
      ads_image_url: ads_image_url,
      ads_title: ads_title,
      ads_description: ads_description,
      date_time_added: date_time_added,
      added_by: added_by,
      date_time_last_updated: date_time_last_updated,
      last_updated_by: last_updated_by,
      status: status
    };
  }

  factory AdsClass.fromJson(Map<String, dynamic> json) {
    return AdsClass(
        ads_id: json['ads_id'],
        ads_image_url: json['ads_image_url'],
        ads_title: json['ads_title'],
        ads_description: json['ads_description'],
        date_time_added: json['date_time_added'],
        added_by: json['added_by'],
        date_time_last_updated: json['date_time_last_updated'],
        last_updated_by: json['last_updated_by'],
        status: json['status']);
  }
}
