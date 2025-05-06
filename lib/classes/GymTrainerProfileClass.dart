class GymTrainerProfileClass {
  final String gym_trainer_profile_id;
  final String gym_id;
  final String specialty;
  final String bio_one;
  final String bio_two;
  final String socials_facebook;
  final String socials_linkedin;
  final String socials_instagram;
  final String socials_rednote;
  final String socials_tiktok;
  final String socials_whatsapp;
  final String socials_viber;
  final String socials_x;
  final String firebase_uid;
  final String date_time_added;
  final String date_time_last_updated;
  final String cover_photos;
  final String profile_description;

  GymTrainerProfileClass(
      {required this.gym_trainer_profile_id,
      required this.gym_id,
      required this.specialty,
      required this.bio_one,
      required this.bio_two,
      required this.socials_facebook,
      required this.socials_linkedin,
      required this.socials_instagram,
      required this.socials_rednote,
      required this.socials_tiktok,
      required this.socials_whatsapp,
      required this.socials_viber,
      required this.socials_x,
      required this.firebase_uid,
      required this.date_time_added,
      required this.date_time_last_updated,
      required this.cover_photos,
      required this.profile_description});

  Map<String, dynamic> toMap() {
    return {
      gym_trainer_profile_id: gym_trainer_profile_id,
      gym_id: gym_id,
      specialty: specialty,
      bio_one: bio_one,
      bio_two: bio_two,
      socials_facebook: socials_facebook,
      socials_linkedin: socials_linkedin,
      socials_instagram: socials_instagram,
      socials_rednote: socials_rednote,
      socials_tiktok: socials_tiktok,
      socials_whatsapp: socials_whatsapp,
      socials_viber: socials_viber,
      socials_x: socials_x,
      firebase_uid: firebase_uid,
      date_time_added: date_time_added,
      date_time_last_updated: date_time_last_updated,
      cover_photos: cover_photos,
      profile_description: profile_description
    };
  }

  factory GymTrainerProfileClass.fromJson(Map<String, dynamic> json) {
    return GymTrainerProfileClass(
        gym_trainer_profile_id: json['gym_trainer_profile_id'],
        gym_id: json['gym_id'],
        specialty: json['specialty'],
        bio_one: json['bio_one'],
        bio_two: json['bio_two'],
        socials_facebook: json['socials_facebook'],
        socials_linkedin: json['socials_linkedin'],
        socials_instagram: json['socials_instagram'],
        socials_rednote: json['socials_rednote'],
        socials_tiktok: json['socials_tiktok'],
        socials_whatsapp: json['socials_whatsapp'],
        socials_viber: json['socials_viber'],
        socials_x: json['socials_x'],
        firebase_uid: json['firebase_uid'],
        date_time_added: json['date_time_added'],
        date_time_last_updated: json['date_time_last_updated'],
        cover_photos: json['cover_photos'],
        profile_description: json['profile_description']);
  }
}
