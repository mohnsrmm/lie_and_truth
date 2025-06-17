import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/core/common_widgets/common_text_field.dart';
import 'package:lie_and_truth/pages/stories/auth/controller/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // controller
    LoginController controller = Get.find<LoginController>();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formSignUpKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // profile pic
                    GestureDetector(
                      onTap: controller.pickProfilePic,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 53,
                            backgroundColor: AppColors.kPrimary,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.kSecondary,
                              child: Obx(
                                () => controller.profilePic.value.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.white,
                                      )
                                    :
                                    // if start with http or https then load from network
                                    controller.profilePic.value
                                                .startsWith('http') ||
                                            controller.profilePic.value
                                                .startsWith('https')
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                                controller.profilePic.value,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100, errorBuilder:
                                                    (context, error, stack) {
                                              return Icon(
                                                Icons.person,
                                                size: 50,
                                                color: AppColors.white,
                                              );
                                            }),
                                          )
                                        :
                                        // else load from local file
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.file(
                                              File(controller.profilePic.value),
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                          // pick image icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.kPrimary,
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // AppName text
                    Text(
                      AppStrings.signup.toUpperCase(),
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kPrimary,
                      ),
                    ),
                    SizedBox(height: 30),
                    // name field
                    CommonTextField(
                      labelText: AppStrings.name,
                      hintText:
                          AppStrings.pleaseEnterYourPrefix + AppStrings.name,
                      controller: controller.nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return (AppStrings.pleaseEnterYourPrefix +
                                  AppStrings.name)
                              .toLowerCase();
                        }
                        return null;
                      },
                    ),
                    //email field
                    CommonTextField(
                      labelText: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      hintText:
                          AppStrings.pleaseEnterYourPrefix + AppStrings.email,
                      controller: controller.emailController,
                      validator: (value) {
                        if (!GetUtils.isEmail(value ?? '')) {
                          return AppStrings.pleaseEnterValidEmail.toLowerCase();
                        }
                        return null;
                      },
                    ),

                    //password field
                    CommonTextField(
                      labelText: AppStrings.password,
                      hintText: AppStrings.pleaseEnterYourPrefix +
                          AppStrings.password,
                      isPassword: true,
                      controller: controller.passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return (AppStrings.pleaseEnterYourPrefix +
                                  AppStrings.password)
                              .toLowerCase();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),

                    ElevatedButton(
                      onPressed: controller.signUp,
                      child: Text(
                        AppStrings.signup,
                      ),
                    ),
                    SizedBox(height: 10),

                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAnAccount,
                            style: TextStyle(color: AppColors.kPrimary),
                          ),
                          SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              AppStrings.login,
                              style: TextStyle(color: AppColors.kPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
