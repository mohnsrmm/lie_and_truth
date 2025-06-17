import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/init_bindings.dart';
import 'package:lie_and_truth/pages/startpage/startpage.dart';
import 'package:lie_and_truth/pages/stories/auth/pages/forgot_screen.dart';
import 'package:lie_and_truth/pages/stories/auth/pages/login.dart';
import 'package:lie_and_truth/pages/stories/auth/pages/sign_up.dart';
import 'package:lie_and_truth/pages/stories/auth/user_model.dart';
import 'package:lie_and_truth/pages/stories/story_home/model/story_model.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/create_story.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/story_home.dart';

import 'pages/stories/auth/controller/auth_controller.dart';
import 'pages/stories/story_home/controller/story_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp();
    debugPrint('Initialized default app $app');
  }

  await initializeDefault();
  await UserModel.getUserData();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initializeDefault();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lie & Truth',
      initialBinding: InitBindings(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.kSecondary,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.kSecondary,
          foregroundColor: AppColors.white,
          iconTheme: IconThemeData(color: AppColors.kPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.white,
          ),
        ),
        tabBarTheme: TabBarTheme(
          indicatorColor: AppColors.white,
          dividerColor: AppColors.white,
          labelStyle: TextStyle(color: AppColors.kPrimary),
          unselectedLabelColor: AppColors.kPrimary.withOpacity(0.5),
          labelColor: AppColors.kPrimary,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.kPrimary,
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.kPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.kPrimary),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
            ),
            textStyle: MaterialStateProperty.all(
              TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.kSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            color: AppColors.kPrimary,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.kSecondary,
          foregroundColor: AppColors.kPrimary,
        ),
      ),
      home: const StartPage(),
      getPages: [
        GetPage(name: '/', page: () => StartPage()),
        // login
        GetPage(
            name: AppRouter.login,
            page: () {
              Get.put(LoginController());
              return const LoginScreen();
            }),
        // signup
        GetPage(
            name: AppRouter.signUp,
            page: () {
              Get.put(LoginController());
              return const SignUpScreen();
            }),

        // ForgotPasswordScreen
        GetPage(
            name: AppRouter.forgetPassword,
            page: () {
              Get.put(LoginController());
              return const ForgotPasswordScreen();
            }),
        // stories home
        GetPage(
          name: AppRouter.storyHome,
          page: () {
            // check login or not
            Get.find<StoryController>()
              ..getMyStories()
              ..isMyStories.value = true;

            return const StoryHomeScreen();
          },
        ),

        // stories create
        GetPage(
          name: AppRouter.storyCreate,
          page: () => const CreateStoryScreen(),
        ),

        // edit Story
        GetPage(
          name: AppRouter.storyEdit,
          page: () {
            final story = Get.arguments as StoryModel;
            return CreateStoryScreen(story: story);
          },
        ),
      ],
    );
  }
}
