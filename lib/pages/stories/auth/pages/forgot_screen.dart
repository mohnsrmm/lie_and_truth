import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/core/common_widgets/common_text_field.dart';
import 'package:lie_and_truth/pages/stories/auth/controller/auth_controller.dart';
import 'package:lie_and_truth/utils.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // controller
    LoginController controller = Get.find<LoginController>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.kPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKeyforgot,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //
                    Utils.appLogoWidget(),
                    SizedBox(height: 30),

                    // AppName text
                    Text(
                      AppStrings.forgotPassword.toUpperCase(),
                      style: TextStyle(
                        fontSize: 35,
                        color: AppColors.kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),

                    //email field
                    CommonTextField(
                      labelText: AppStrings.email,
                      hintText:
                          AppStrings.pleaseEnterYourPrefix + AppStrings.email,
                      controller: controller.emailController,
                      validator: (value) {
                        if (!GetUtils.isEmail(value ?? '')) {
                          return AppStrings.pleaseEnterYourPrefix +
                              AppStrings.email;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 50),

                    ElevatedButton(
                      onPressed: controller.forgetPassword,
                      child: Text(
                        AppStrings.resetPassword,
                      ),
                    ),
                    SizedBox(height: 10),
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
