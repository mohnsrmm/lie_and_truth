import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/pages/stories/auth/user_model.dart';
import 'package:lie_and_truth/utils.dart';

class LoginController extends GetxController {
  // controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();
  final formSignUpKey = GlobalKey<FormState>();
  var formKeyforgot = GlobalKey<FormState>();

  var profilePic = ''.obs;

  void pickProfilePic() async {
    profilePic.value = (await Utils.pickImageVideo()) ?? '';
  }

  @override
  void dispose() {
    // dispose controllers
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();

    super.dispose();
  }

  void afterLoginProcess() async {
    // save user data in LOCAL STORAGE
    try {
      // get user data from firebase
      final userData = await FirebaseFirestore.instance
          .collection(AppDBKeys.userData)
          .where(
            'email',
            isEqualTo: emailController.text.toLowerCase(),
          )
          .get();
      Utils.userData = UserModel.fromMap(
        userData.docs.first.data(),
      );
      Utils.userData.uid = userData.docs.first.id;
      await Utils.userData.saveUserData();
      Utils.hideLoading();

      // navigate to home screen
      Get.offAllNamed(AppRouter.root);
      Get.toNamed(AppRouter.storyHome);
    } catch (e) {
      Utils.hideLoading();

      Utils.debug('Error : $e');
      Utils.showSnackBar(message: AppStrings.userNotFound);
    }
  }

  void login({bool fromSignUp = false}) {
    if (fromSignUp) {
      if (Utils.userData.email?.isEmpty ?? true) {
        Utils.showSnackBar(
          message: AppStrings.someThingWentWrong,
        );
        return;
      }
    }

    if (!formKey.currentState!.validate()) {
      return;
    }
    Utils.showLoading(message: AppStrings.processing);

    // firebase login
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text.toLowerCase(),
      password: passwordController.text,
    )
        .then((value) {
      // Utils.showSnackBar(
      //   message: AppStrings.login + ' ' + AppStrings.successFully,
      //   isSuccess: true,
      // );
      afterLoginProcess();
    }).catchError((error) {
      Utils.debug("; $error");
      Utils.hideLoading();
      final str =
          error.toString().contains('The supplied auth credential is incorrect, malformed or has expired.')
              ? AppStrings.userNotFound
              : error.toString().split(']').last.toString();
      Utils.showSnackBar(
        message: AppStrings.errorPrefix + str,
      );
    });
  }

  void signUp() {
    if (!formSignUpKey.currentState!.validate()) {
      return;
    }

    if (profilePic.value.isEmpty) {
      Utils.showSnackBar(
        message: AppStrings.pleasePickProfilePic,
      );
      return;
    }

    Utils.showLoading(message: AppStrings.processing);

    // firebase signup
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text.toLowerCase(),
      password: passwordController.text,
    )
        .then((value) async {
      // save in firebase collection  if not exist
      try {
        await FirebaseFirestore.instance
            .collection(AppDBKeys.userData)
            .where('uid', isEqualTo: value.user!.uid)
            .get()
            .then((value) async {
          Utils.debug('Error : $value');
          if (value.docs.isEmpty) {
            await addUserToFirebase(value.docs.first.id);
          }
        });
        Utils.hideLoading();

        login(fromSignUp: true);
      } catch (e) {
        Utils.debug('Error : $e');
        await addUserToFirebase(value.user!.uid);
        Utils.hideLoading();

        login(fromSignUp: true);
      }
      // login after signup automatically

      //
    }).catchError((error) {
      Utils.debug("; $error");
      Utils.hideLoading();
      Utils.showSnackBar(
        message: AppStrings.errorPrefix +
            error.toString().split(']').last.toString(),
      );
    });
  }

  void forgetPassword() {
    if (!formKeyforgot.currentState!.validate()) {
      return;
    }

    Utils.showLoading(message: AppStrings.processing);

    // firebase signup
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.toLowerCase())
        .then((value) {
      Utils.hideLoading();
      Utils.showSnackBar(
        message: AppStrings.resetPasswordEmailSent,
        isSuccess: true,
      );
    }).catchError((error) {
      Utils.debug("; $error");
      Utils.hideLoading();
      Utils.showSnackBar(
        message: AppStrings.errorPrefix +
            error.toString().split(']').last.toString(),
      );
    });
  }

  Future<void> addUserToFirebase(String uid) async {
    try {
      Utils.userData = UserModel(
        uid: uid,
        name: nameController.text,
        email: emailController.text.toLowerCase(),
        profilePic: profilePic.value ?? '',
      );
      // upload file to firebase storage
      if (profilePic.value.isNotEmpty) {
        Utils.userData.profilePic = await Utils.uploadFile(
          profilePic.value,
        );
      }
      await FirebaseFirestore.instance
          .collection(AppDBKeys.userData)
          .add(Utils.userData.toMap());
    } catch (e) {
      // delete user from firebase auth
      await FirebaseAuth.instance.currentUser!.delete();
      Utils.debug('Error : $e');
      Utils.userData = UserModel();
    }
  }
}
