import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  String? uid;
  String? name;
  String? email;
  String? profilePic;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.profilePic,
  });

  UserModel.fromMap(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    email = json['email'];
    profilePic = json['profilePic'];
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['email'] = email;
    data['profilePic'] = profilePic;
    return data;
  }

  // from &  to Json func
  factory UserModel.fromJson(String json) {
    return UserModel.fromMap(jsonDecode(json));
  }

  String toJson() => jsonEncode(toMap());

  // save to local storage
  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppDBKeys.userData, toJson());
    Utils.debug('User data saved');
  }

  // get from local storage
  static Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(AppDBKeys.userData);
    Utils.debug('User data : $userData');
    if (userData != null) {
      Utils.userData = UserModel.fromJson(userData);

    }
  }

  static Future<void> signOut() async {
    Utils.userData = UserModel();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(AppDBKeys.userData);
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(AppRouter.root);
  }
}
