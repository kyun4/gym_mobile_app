import 'package:flutter/material.dart';
import 'package:fitup/pages/UserMainMenu.dart';
import 'package:fitup/pages/InstructorMainMenu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fitup/services/storage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:fitup/classes/UserImagesClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitup/classes/AppConfig.dart';

String dbUrl = AppConfig.dbUrl;

class UserProfileImage extends StatefulWidget {
  const UserProfileImage({super.key});

  @override
  State<UserProfileImage> createState() => userProfileImageState();
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

Future<void> addUserImageData(String firebaseUID, String user_image_url) async {
  String date_time_added = DateTime.now().toIso8601String();

  String url = dbUrl + "user_images.json";
  try {
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          "image_url": user_image_url,
          "user_id": firebaseUID,
          "status": "1",
          "date_time_added": date_time_added
        }));
  } catch (error) {
    throw error;
  }
} // addUserImageData

Future<String> getUserImageData(String firebaseUID) async {
  String imageUrl = "";
  String url =
      "https://fitup-43ee3-default-rtdb.firebaseio.com/" + "user_images.json";
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null || response.body.isEmpty) {
      return "";
    }

    extractedData.forEach((id, data) {
      if (data['user_id'] == firebaseUID && data['status'] == "1") {
        imageUrl = data['image_url'] ?? "";
      }
    });
  } catch (error) {
    throw error;
  } // getUserImageData

  return imageUrl;
} // getUserImageData

void updateAllUserImageRecordStatus(String firebaseUID) {
  var ref = FirebaseDatabase.instance.ref("user_images/$firebaseUID/");

  ref.onValue.map((event) {
    final values = event.snapshot.value as Map;

    values.forEach((key, value) {
      ref.child(key).update({'status': '0'});
    });
  });
} // updateAllUserIamgeRecordStatus

class userProfileImageState extends State<UserProfileImage> {
  XFile? _image;
  String? _downloadURL;
  double _progress = 0.0; //
  String? firebaseUID;

  @override
  void initState() {
    super.initState();
    firebaseUID = FirebaseAuth.instance.currentUser!.uid.toString();
    getLatestProfileImageUrl();
  }

  Future<void> getLatestProfileImageUrl() async {
    String? latestImageUrl = await getUserImageData(firebaseUID ?? "");
    setState(() {
      _downloadURL = latestImageUrl;
    });
  } // getLatestProfileImageUrl

  Future<void> _pickAndUploadImage() async {
    // Pick an image
    XFile? image = await _pickImage();
    if (image != null) {
      // Upload the image and get the download URL
      String? downloadURL = await _uploadImage(image);
      if (downloadURL != null) {
        setState(() {
          _image = image;
          _downloadURL = downloadURL;
          _progress = 0.0;
        });
      }
    }
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      final uniqueId = new Uuid();
      String uniqueIdValue = uniqueId.v4();
      String profileImageFileName =
          firebaseUID ?? "" + "_" + uniqueIdValue + "";

      Reference ref =
          storage.ref().child("user_images/" + profileImageFileName + ".jpg");
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

      updateAllUserImageRecordStatus(firebaseUID ?? "");
      addUserImageData(firebaseUID ?? "", downloadURL);

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget build(BuildContext) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Profile Image"),
            leading: GestureDetector(
              onTap: () async {
                String? role = await getSession("role");

                if (role == "1") {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return UserMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 0);
                  }));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return InstructorMainMenu(
                        selectedInitIndex: 4, subSelectedInitIndex: 0);
                  }));
                }

                removeSession("role");
              },
              child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Icon(Icons.arrow_back)),
            )),
        body: SafeArea(
            child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Image.network(_downloadURL ?? "", fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text("Error loading image"));
                }, loadingBuilder: (context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null));
                  }
                })),
            if (_progress > 0 && _progress < 1)
              Container(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress, // Show the progress
                    ),
                    SizedBox(height: 8),
                    Text('${(_progress * 100).toStringAsFixed(2)}% uploaded',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            GestureDetector(
              onTap: () {
                _pickAndUploadImage();
              },
              child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  decoration:
                      BoxDecoration(color: Colors.grey.withOpacity(0.5)),
                  child: Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Icon(Icons.upload),
                        SizedBox(width: 15),
                        Text("Upload Profile Image")
                      ]))),
            ),
          ],
        )));
  }
}
