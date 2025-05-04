import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class StorageService with ChangeNotifier {
  final firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrls = [];
  List<String> _productImageUrls = [];
  List<String> _partnerLogoImageUrls = [];

  bool _isLoading = false;
  bool _isUploading = false;

  List<String> get imageUrls => _imageUrls;
  List<String> get productImageUrls => _productImageUrls;
  List<String> get partnerLogoImageUrls => _partnerLogoImageUrls;

  Future<void> getFetchImages() async {
    _isLoading = true;

    final ListResult result =
        await firebaseStorage.ref("/ads_images").listAll();

    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _imageUrls = urls;

    _isLoading = false;

    notifyListeners();
  }

  Future<void> fetchProductImages() async {
    _isLoading = true;

    final ListResult result = await firebaseStorage.ref("/products").listAll();

    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _productImageUrls = urls;

    _isLoading = false;

    notifyListeners();
  }

  Future<void> getPartnerLogos() async {
    _isLoading = true;

    final ListResult result =
        await firebaseStorage.ref("/gym_partners_logo").listAll();

    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _partnerLogoImageUrls = urls;

    _isLoading = false;

    notifyListeners();
  }

  Future<void> uploadImages(String firebaseUID) async {
    _isUploading = true;

    notifyListeners();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    File file = File(image.path);

    try {
      if (image != null) {
        // Cropping the image
        // CroppedFile? croppedFile = await ImageCropper().cropImage(
        //   sourcePath: image.path,
        //   aspectRatio: CropAspectRatio(
        //       ratioX: 1.0, ratioY: 1.0), // Specify the aspect ratio
        //   uiSettings: [
        //     AndroidUiSettings(
        //       toolbarTitle: 'profilephoto_${firebaseUID}',
        //       toolbarColor: Colors.deepOrange,
        //       toolbarWidgetColor: Colors.white,
        //       lockAspectRatio:
        //           false, // Allow the user to adjust the aspect ratio
        //     ),
        //     IOSUiSettings(
        //       title: 'profilephoto_${firebaseUID}',
        //     ),
        //   ],
        // );

        // The cropped image file can be used here

        // Display or use the cropped image
        //print('Cropped image path: $croppedImagePath');

        String filePathDefault = 'user_images/${DateTime.now()}.png';
        // String filePath = 'user_images/${croppedImagePath.toString()}';

        await firebaseStorage.ref(filePathDefault).putFile(file);

        String downloadedUrl =
            await firebaseStorage.ref(filePathDefault).getDownloadURL();

        _imageUrls.add(downloadedUrl);
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  } // uploadImages

  Future<void> uploadReceiptImages(
      String firebaseUID, String paymentMethod, String transactionId) async {
    _isUploading = true;

    notifyListeners();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    File file = File(image.path);

    try {
      if (image != null) {
        // Cropping the image
        // CroppedFile? croppedFile = await ImageCropper().cropImage(
        //   sourcePath: image.path,
        //   aspectRatio: CropAspectRatio(
        //       ratioX: 1.0, ratioY: 1.0), // Specify the aspect ratio
        //   uiSettings: [
        //     AndroidUiSettings(
        //       toolbarTitle: 'profilephoto_${firebaseUID}',
        //       toolbarColor: Colors.deepOrange,
        //       toolbarWidgetColor: Colors.white,
        //       lockAspectRatio:
        //           false, // Allow the user to adjust the aspect ratio
        //     ),
        //     IOSUiSettings(
        //       title: 'profilephoto_${firebaseUID}',
        //     ),
        //   ],
        // );

        // The cropped image file can be used here

        // Display or use the cropped image
        //print('Cropped image path: $croppedImagePath');

        String filePathDefault =
            "receipts/'$firebaseUID'_'$paymentMethod'_${DateTime.now()}.png";
        // String filePath = 'user_images/${croppedImagePath.toString()}';

        await firebaseStorage.ref(filePathDefault).putFile(file);

        String downloadedUrl =
            await firebaseStorage.ref(filePathDefault).getDownloadURL();

        _imageUrls.add(downloadedUrl);
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }
}
