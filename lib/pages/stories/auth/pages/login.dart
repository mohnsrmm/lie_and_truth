import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/core/common_widgets/common_text_field.dart';
import 'package:lie_and_truth/pages/stories/auth/controller/auth_controller.dart';
import 'package:lie_and_truth/utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //
                    Utils.appLogoWidget(),
                    SizedBox(height: 30),

                    // AppName text
                    Text(
                      AppStrings.login.toUpperCase(),
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
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (!GetUtils.isEmail(value ?? '')) {
                          return AppStrings.pleaseEnterValidEmail;
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
                          return AppStrings.pleaseEnterYourPrefix +
                              AppStrings.password;
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed(AppRouter.forgetPassword);
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: TextStyle(color: AppColors.kPrimary),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),

                    ElevatedButton(
                      onPressed: controller.login,
                      child: Text(
                        AppStrings.login,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.dontHaveAnAccount,
                            style: TextStyle(color: AppColors.kPrimary),
                          ),
                          SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRouter.signUp);
                            },
                            child: Text(
                              AppStrings.signup,
                              style: TextStyle(color: AppColors.kPrimary),
                            ),
                          ),
                        ],
                      ),
                    )
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
