import 'package:flutter/material.dart';

import 'package:fitup/pages/UserMainMenu.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitup/classes/Users.dart';
import 'package:fitup/classes/GymTrainerProfileClass.dart';

import 'package:fitup/components/textField.dart';
import 'package:fitup/components/textFieldMultiarea.dart';
import 'package:fitup/components/textFieldPhone.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class EditTrainerDetails extends StatefulWidget {
  const EditTrainerDetails({super.key});

  State<EditTrainerDetails> createState() => _editTrainerDetailsState();
}

Future<void> setSession(String key, String value) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.setString(key, value);
} //

Future<String?> getSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  return ref.getString(key);
} // getSession

Future<void> removeSession(String key) async {
  SharedPreferences ref = await SharedPreferences.getInstance();
  ref.remove(key);
} // removeSession

void updateUserDetails(
    String bio_one,
    String bio_two,
    String specialty,
    String cover_photos,
    String gymId,
    String profileDescription,
    String socialsInstagram,
    String socialsFacebook,
    String socialsX,
    String socialsWhatsapp,
    String socialsTiktok,
    String socialsRednote,
    String socialsLinkedin,
    String socialsViber) async {
  String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
  String url = dbUrl + "gym_trainer_profile/$firebaseUID.json";

  String date_time_added =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  try {
    final response = await http.patch(Uri.parse(url),
        body: json.encode({
          "bio_one": bio_one,
          "bio_two": bio_two,
          "specialty": specialty,
          "cover_photos": cover_photos,
          "date_time_added": date_time_added,
          "date_time_last_updated": "",
          "firebase_uid": firebaseUID,
          "gym_id": gymId,
          "gym_trainer_profile_id": firebaseUID,
          "profile_description": profileDescription,
          "socials_facebook": socialsFacebook,
          "socials_instagram": socialsInstagram,
          "socials_x": socialsX,
          "socials_whatsapp": socialsWhatsapp,
          "socials_tiktok": socialsTiktok,
          "socials_rednote": socialsRednote,
          "socials_linkedin": socialsLinkedin,
          "socials_viber": socialsViber
        }));
  } catch (error) {
    throw error;
  }
} // updateUserDetails

Future<String> getUIDByFirebaseUID(String firebaseUID) async {
  String? uid;
  String url = dbUrl + "users.json";

  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((userId, json) {
      if (json['firebase_uid'] == firebaseUID) {
        uid = userId;
      }
    });
  } catch (error) {
    throw error;
  }
  return uid ?? "";
} // getUIDByFirebaseUID

class _editTrainerDetailsState extends State<EditTrainerDetails> {
  TextEditingController textProfileDescController = new TextEditingController();
  TextEditingController textLongBioController = new TextEditingController();
  TextEditingController textShortBioController = new TextEditingController();

  TextEditingController textFacebookSocialController =
      new TextEditingController();
  TextEditingController textTiktokSocialController =
      new TextEditingController();

  TextEditingController textRednoteSocialController =
      new TextEditingController();
  TextEditingController textWhatsappSocialController =
      new TextEditingController();
  TextEditingController textLinkedinSocialController =
      new TextEditingController();
  TextEditingController textInstagramSocialController =
      new TextEditingController();
  TextEditingController textXSocialController = new TextEditingController();
  TextEditingController textViberSocialController = new TextEditingController();

  String? firebaseUID;
  String? roleId;

  String? specialtyValues;
  String? coverPhotosValues;
  String? gymId;
  String? profileDescriptionValue;
  String? socialsInstagramValue;
  String? socialsFacebookValue;
  String? socialsXValue;
  String? socialsWhatsappValue;
  String? socialsTiktokValue;
  String? socialsRednoteValue;
  String? socialsLinkedinValue;
  String? socialsViberValue;

  XFile? _image;
  String? _downloadURL;
  double _progress = 0.0; //

  String? exerciseId,
      trainingCategoryId,
      sessionSetup,
      exerciseLevel,
      trainerCoverPhoto,
      trainerCoverPhotoNew,
      classLimit;

  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getSharedPreferencesValues();
  }

  void getSharedPreferencesValues() async {
    String? roleIDValue = await getSession("role");
    setState(() {
      roleId = roleIDValue;
    });
  } // getSharedPreferencesValues

  Future<XFile?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String?> _uploadImage(XFile image) async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      final uniqueId = new Uuid();
      String uniqueIdValue = uniqueId.v4();
      String profileImageFileName = firebaseUID + "_" + uniqueIdValue + "";

      Reference ref = storage
          .ref()
          .child("trainer_cover_photos/" + profileImageFileName + ".jpg");
      TaskSnapshot uploadTask = await ref.putFile(File(image.path));

      UploadTask uploadTasking = ref.putFile(File(image.path));

      // Listen to upload progress
      uploadTasking.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _progress = progress; // Update the progress value
        });
      });

      String downloadURL = await uploadTask.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  } // _uploadImage

  Future<void> _pickAndUploadImage() async {
    // Pick an image
    XFile? image = await _pickImage();
    if (image != null) {
      // Upload the image and get the download URL
      String? downloadURL = await _uploadImage(image);
      if (downloadURL != null) {
        setState(() {
          _image = image;
          trainerCoverPhotoNew = downloadURL;
          _progress = 0.0;
        });
      }
    }
  } // _pickAndUploadImage

  Stream<List<Users>> getUsers(String firebaseUID) {
    final dbref = FirebaseDatabase.instance.ref("users");

    return dbref.onValue.map((event) {
      final List<Users> listUsers = [];

      final extractedData =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      extractedData.forEach((key, json) {
        if (firebaseUID == json['firebase_uid']) {
          listUsers.add(Users(
              username: json['username'] ?? "",
              firebase_uid: json['firebase_uid'] ?? "",
              firstname: json['firstname'] ?? "",
              middlename: json['middlename'] ?? "",
              lastname: json['lastname'] ?? "",
              ext: json['ext'] ?? "",
              email: json['email'] ?? "",
              phone: json['phone'] ?? "",
              otp: json['otp'] ?? "",
              occupation: json['occupation'] ?? "",
              title: json['title'] ?? "",
              role: json['role'] ?? "",
              date_time_membership: json['date_time_membership'] ?? "",
              date_time_premium_activated:
                  json['date_time_premium_actvated'] ?? "",
              date_time_registered: json['date_time_registered'] ?? "",
              email_verified: json['email_verified'] ?? ""));
        }
      });

      return listUsers;
    });
  } // getUsers

  Future<List<GymTrainerProfileClass>> listGymTrainerProfile() async {
    String firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    List<GymTrainerProfileClass> listGymTrainerProfileData = [];
    String url = dbUrl + "gym_trainer_profile.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == Null ||
          extractedData == null ||
          response.body.isEmpty) {
        return [];
      }

      extractedData.forEach((key, json) {
        String trainerID = json['firebase_uid'] ?? "";

        if (trainerID == firebaseUID) {
          listGymTrainerProfileData.add(GymTrainerProfileClass(
              gym_trainer_profile_id: json['gym_trainer_profile_id'] ?? "",
              gym_id: json['gym_id'] ?? "",
              specialty: json['specialty'] ?? "",
              bio_one: json['bio_one'],
              bio_two: json['bio_two'],
              socials_facebook: json['socials_facebook'] ?? "",
              socials_linkedin: json['socials_linkedin'] ?? "",
              socials_instagram: json['socials_instagram'] ?? "",
              socials_rednote: json['socials_rednote'] ?? "",
              socials_tiktok: json['socials_tiktok'] ?? "",
              socials_whatsapp: json['socials_whatsapp'] ?? "",
              socials_viber: json['socials_viber'] ?? "",
              socials_x: json['socials_x'] ?? "",
              firebase_uid: json['firebase_uid'] ?? "",
              date_time_added: json['date_time_added'] ?? "",
              date_time_last_updated: json['date_time_last_updated'] ?? "",
              cover_photos: json['cover_photos'] ?? "",
              profile_description: json['profile_description'] ?? ""));
        }
      });
    } catch (error) {
      throw error;
    }

    return listGymTrainerProfileData;
  } // listGymTrainerProfile

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Edit Profile Details", style: TextStyle(fontSize: 16)),
            leading: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const InstructorMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 0);
                  }));
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(199, 118, 60, 180)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Icon(Icons.arrow_back,
                        color: Color.fromARGB(199, 118, 60, 180))))),
        body: SafeArea(
            child: StreamBuilder(
                stream: listGymTrainerProfile().asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Center(
                            child: Text("No trainer profile available")));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.length > 0) {
                    textProfileDescController.text =
                        snapshot.data![0].profile_description;
                    textLongBioController.text = snapshot.data![0].bio_one;
                    textShortBioController.text = snapshot.data![0].bio_two;
                    textFacebookSocialController.text =
                        snapshot.data![0].socials_facebook;
                    textTiktokSocialController.text =
                        snapshot.data![0].socials_tiktok;
                    trainerCoverPhoto = snapshot.data![0].cover_photos;
                  }

                  return ListView(children: [
                    SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.only(left: 25, bottom: 10),
                      child: Text("Cover Photo",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () {
                        _pickAndUploadImage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.withOpacity(0.05)),
                          height: 225,
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                                trainerCoverPhotoNew == null
                                    ? trainerCoverPhoto ?? ""
                                    : trainerCoverPhotoNew ?? "",
                                errorBuilder:
                                    (context, error, StackTraceError) {
                              return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload, size: 42),
                                    Text("Upload Your Trainer Cover Photo"),
                                    Text(
                                        "This will be seen by potential clients on your profile, give your best shot!",
                                        style: TextStyle(fontSize: 8))
                                  ]);
                            }, loadingBuilder: (context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: CircularProgressIndicator(
                                        value: loadingProgress != null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null));
                              }
                            }, fit: BoxFit.cover),
                          )),
                    ),
                    Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Profile Description",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldMultiarea(
                              textController: textProfileDescController,
                              obscure_text: false,
                              hint_text_value:
                                  "Tell something briefly about yourself, This will include on your cover photo that will be seen by potential clients. Give your best pitch!",
                              maxLineLength: 5),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("General Bio",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldMultiarea(
                              textController: textLongBioController,
                              obscure_text: false,
                              hint_text_value: "Bio (Tell about yourself)",
                              maxLineLength: 5),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Short Bio",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldMultiarea(
                              textController: textShortBioController,
                              obscure_text: false,
                              hint_text_value:
                                  "Short Bio (e.g Years of experience, Title or Personality etc.)",
                              maxLineLength: 2),
                          SizedBox(height: 15),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Facebook",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textFacebookSocialController,
                              obscure_text: false,
                              hint_text_value: "Your Facebook ID",
                              iconPrefix: Icon(Icons.facebook),
                              iconSuffix: Icon(Icons.facebook,
                                  color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Tiktok ID",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textTiktokSocialController,
                              obscure_text: false,
                              hint_text_value: "Your Tiktok ID",
                              iconPrefix: Icon(Icons.tiktok),
                              iconSuffix: Icon(Icons.tiktok,
                                  color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("LinkedIn",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textLinkedinSocialController,
                              obscure_text: false,
                              hint_text_value: "Your LinkedIn ID",
                              iconPrefix: Icon(Icons.link),
                              iconSuffix:
                                  Icon(Icons.link, color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Viber",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textViberSocialController,
                              obscure_text: false,
                              hint_text_value: "Your Viber Number",
                              iconPrefix: Icon(Icons.phone_android_outlined),
                              iconSuffix: Icon(Icons.phone_android_outlined,
                                  color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Instagram",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textInstagramSocialController,
                              obscure_text: false,
                              hint_text_value: "Your Instagram ID",
                              iconPrefix: Icon(Icons.camera_alt_outlined),
                              iconSuffix: Icon(Icons.camera_alt_outlined,
                                  color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("X (formerly Twitter)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textXSocialController,
                              obscure_text: false,
                              hint_text_value: "Your X/Twitter ID",
                              iconPrefix: Icon(Icons.numbers_sharp),
                              iconSuffix: Icon(Icons.one_x_mobiledata_outlined,
                                  color: Colors.transparent)),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, top: 20, bottom: 10),
                            child: Text("Reddit",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          TextFieldCustom(
                              textController: textRednoteSocialController,
                              obscure_text: false,
                              hint_text_value: "Your Reddit Username",
                              iconPrefix: Icon(Icons.reddit),
                              iconSuffix: Icon(Icons.reddit,
                                  color: Colors.transparent)),
                          SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              updateUserDetails(
                                  textLongBioController.text,
                                  textShortBioController.text,
                                  specialtyValues ?? "",
                                  trainerCoverPhotoNew == null
                                      ? trainerCoverPhoto ?? ""
                                      : trainerCoverPhotoNew ?? "",
                                  gymId ?? "",
                                  textProfileDescController.text,
                                  socialsInstagramValue ?? "",
                                  textFacebookSocialController.text,
                                  socialsXValue ?? "",
                                  socialsWhatsappValue ?? "",
                                  textTiktokSocialController.text,
                                  textRednoteSocialController.text,
                                  textLinkedinSocialController.text,
                                  textViberSocialController.text);

                              textLongBioController.text = "";
                              textShortBioController.text = "";

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return InstructorMainMenu(
                                    selectedInitIndex: 4,
                                    subSelectedInitIndex: 0);
                              }));

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Trainer Details Successfully Updated!")));
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                        199, 118, 10, 160)),
                                child: GestureDetector(
                                    onTap: () {},
                                    child: const Text("Update",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)))),
                          ),
                        ])),
                  ]);
                })));
  }
}
