import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/pages/stories/auth/user_model.dart';
import 'package:lie_and_truth/pages/stories/story_home/model/story_model.dart';
import 'package:lie_and_truth/utils.dart';
import 'package:share_plus/share_plus.dart';

class StoryController extends GetxController {
  final stories = <StoryModel>[].obs;

  var isLoading = false.obs;

  var isMyStories = true.obs;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    getMyStories();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // read all stories
  Future<void> readStories() async {
    isLoading.value = true;
    try {
      final list = await StoryModel.getStories();
      final newList = sortedStories(list);
      stories.clear();
      stories.addAll(newList);
    } catch (e) {
      Utils.showSnackBar(message: e.toString());
    }
    isLoading.value = false;
  }

  // sort stories
  List<StoryModel> sortedStories(List<StoryModel> list) {
    // show most liked stories first
    list.sort((a, b) => b.likeBy?.length.compareTo(a.likeBy?.length ?? 0) ?? 0);
    List<StoryModel> top3Stories = [];
    try {
      if (list.length > 3) {
        top3Stories = list.sublist(0, 3);
        top3Stories.forEach((element) {
          Utils.debug('element : ${element.title}');
          if ((element.likeBy?.length ?? 0) > 0) {
            element.isTopStory = true;
          } else {
            element.isTopStory = false;
          }
        });
        list.removeRange(0, 3);
      }
    } catch (e) {
      //
    }
    list.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? '') ?? 0);

    if (top3Stories.isNotEmpty) {
      // adding top 3 stories into stories list at the start
      list.insertAll(0, top3Stories);
    }

    // notify listeners
    return list;
  }

  // share story
  Future<void> shareStory(StoryModel model) async {
    try {
      await Share.share(
        "Checkout my Story about ${model.title} below\n\n${AppStrings.appUrl}",
        subject: AppStrings.appName,
      );
    } catch (e) {
      Utils.showSnackBar(message: e.toString());
    }
  }

  // like story
  Future<void> likeStory(StoryModel model, int index) async {
    try {
      Utils.debug('likeStory : ${model.id}');
      await model.like();
      stories[index] = model;
      // sortedStories();
    } catch (e) {
      Utils.debug('Error : $e');
      Utils.showSnackBar(message: e.toString());
    }
  }

  // get my stories
  Future<void> getMyStories() async {
    Utils.debug("My S");
    isLoading.value = true;
    try {
      final list = await StoryModel.getMyStories();
      final newList = sortedStories(list);
      stories.clear();
      stories.addAll(newList);
    } catch (e) {
      Utils.debug('Error : $e');
      Utils.showSnackBar(message: e.toString());
    }
    isLoading.value = false;
  }

  void deleteStory(StoryModel story) async {
    try {
      Utils.showLoading();
      await story.delete();
      stories.remove(story);
      Utils.hideLoading();

      Utils.showSnackBar(message: AppStrings.storyDeleted);
    } catch (e) {
      Utils.hideLoading();

      Utils.showSnackBar(message: e.toString());
    }
  }

  void editStory(StoryModel story, int index) async {
    try {
      final updatedStory = await Get.toNamed(
        AppRouter.storyEdit,
        arguments: story,
      );
      Utils.showSnackBar(message: AppStrings.storyUpdated);
      isMyStories.value ? getMyStories() : readStories();
    } catch (e) {
      Utils.debug('Error : $e');
      Utils.showSnackBar(message: e.toString());
    }
  }

  void reportStory(StoryModel story) {
    // report dialog
    Get.defaultDialog(
      backgroundColor: AppColors.kPrimaryContainer,
      title: AppStrings.reportStory,
      titleStyle: TextStyle(color: AppColors.kPrimary),
      confirmTextColor: AppColors.white,
      cancelTextColor: AppColors.white,
      buttonColor: AppColors.kPrimary,
      onConfirm: () async {
        // open Email
        final Email email = Email(
          body:
              'I want to report this story \n ${story.title} ID : ${story.id}  ',
          subject: 'Report Story',
          recipients: [AppStrings.emailAddress],
          cc: [],
          bcc: [],
          attachmentPaths: [],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
      },
      onCancel: () {},
      content: Column(
        children: [
          // report reason
          Text(
            AppStrings.youWantToReportThisStory,
            style: TextStyle(color: AppColors.kPrimary),
          ),
          SizedBox(height: 20),
          // report button
        ],
      ),
    );
  }

  void signOut() async {
    Utils.showLoading();
    await UserModel.signOut();
    Utils.hideLoading();
  }
}
