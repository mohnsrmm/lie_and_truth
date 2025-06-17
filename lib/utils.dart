import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/generated/assets.dart';
import 'package:lie_and_truth/pages/startpage/startpage.dart';
import 'package:lie_and_truth/pages/stories/auth/user_model.dart';

class Utils {
  static bool get isPremium => !StartPageState.showAds;

  static heightBasedOnString(int length) {
    //max height willbe 200
    Utils.debug('heightBasedOnString $length');
    return length > 200 ? 200.0 : length.toDouble();
  }

  static void debug(String message) {
    debugPrint(message);
  }

  static int adCounter = 0;

  static UserModel userData = UserModel();

  // show snackbar with message and color and duration with option success
  static void showSnackBar({
    String? message,
    bool isSuccess = false,
  }) {
    isSuccess = message!.contains(AppStrings.successFully) ? true : isSuccess;
    debug('showSnackBar');
    Get.snackbar(
      isSuccess ? 'Success' : 'Error',
      message ?? (isSuccess ? 'Success Done' : 'Error Occurred'),
      backgroundColor: isSuccess ? AppColors.green : AppColors.red,
      colorText: AppColors.white,
      duration: Duration(seconds: 1),
    );
  }

  // shwo loader with message
  static void showLoading({String? message}) {
    debug('showLoading');
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              color: AppColors.kPrimary,
            ),
            SizedBox(width: 10),
            Text(message ?? AppStrings.processing),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // hide loader
  static void hideLoading() async {
    debug('hideLoading ${Get.isSnackbarOpen}');
    while (Get.isSnackbarOpen) {
      await Future.delayed(Duration(milliseconds: 100));
      continue;
    }

    Get.back();
  }

  static appLogoWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset(
          Assets.imagesLauncherIcon,
          height: 100,
          width: 100,
        ),
      ),
    );
  }

  static void showConfirmationDialog(
      {required title, required message, required void Function() onYes}) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onYes();
            },
            child: Text(AppStrings.yes),
          ),
        ],
      ),
    );
  }

  static Future<String?> pickImageVideo({bool isVideo = false}) async {
    // show dialog for pick image from camera or gallery
    return await Get.defaultDialog<String>(
      title: isVideo ? AppStrings.selectVideo : AppStrings.selectImage,
      content: Column(
        children: [
          TextButton(
            onPressed: () async {
              final path = await _pickImageVideo(ImageSource.camera, isVideo);
              Get.back(result: path);
            },
            child: Text(AppStrings.camera),
          ),
          TextButton(
            onPressed: () async {
              final path = await _pickImageVideo(ImageSource.gallery, isVideo);
              Get.back(result: path);
            },
            child: Text(AppStrings.gallery),
          ),
        ],
      ),
    );
  }

  static dynamic _pickImageVideo(ImageSource source, bool isVideo) async {
    final pickedFile = isVideo
        ? await ImagePicker().pickVideo(source: source)
        : await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile.path;
    }
  }

  static const extBreaker = '__';

  static Future<String> uploadFile(
    String value, {
    bool isVideo = false,
  }) async {
    final file = File(value);
    Utils.debug("File Uploading  ...  ");
    // upload file to firebase storage
    final ref = FirebaseStorage.instance.ref().child(
        (isVideo ? AppDBKeys.videos : AppDBKeys.profilePic) +
            '/${file.path.split('/').last}');
    final uploadTask = await ref.putFile(file).whenComplete(() => null);
    final url = await uploadTask.ref.getDownloadURL();
    Utils.debug('video uploaded: ${url}');
    return url;
  }

  static deleteFileFromFirebase(String oldVideoUrl) {
    Utils.debug('Deleting FB IMAEGE... $oldVideoUrl');
    if (oldVideoUrl.isNotEmpty) {
      try {
        FirebaseStorage.instance.refFromURL(oldVideoUrl).delete();
      } catch (e) {
        debug('Error : $e');
      }
    }
  }
}
