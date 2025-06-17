import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/generated/assets.dart';
import 'package:lie_and_truth/pages/stories/story_home/controller/story_controller.dart';
import 'package:lie_and_truth/utils.dart';

import 'list_view_body_card.dart';

class TabBarListWidget extends StatelessWidget {
  const TabBarListWidget({super.key, required this.isMyStories});

  final bool isMyStories;

  @override
  Widget build(BuildContext context) {
    // controller
    final StoryController controller = Get.find<StoryController>();

    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.kPrimary,
                  ),
                )
              : Column(
                  children: [
                    if (isMyStories)
                      Image.asset(
                        Assets.imagesHappyNewYear,
                        width: Get.width,
                        height: Get.height * 0.25,
                        fit: BoxFit.cover,
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: controller.stories.isEmpty
                            ? Center(
                                child: Text(
                                  AppStrings.NoDataFound,
                                  style: TextStyle(color: AppColors.kPrimary),
                                ),
                              )
                            : ListView.builder(
                                controller: controller.scrollController,
                                itemCount: controller.stories.length,
                                padding: EdgeInsets.all(12),
                                itemBuilder: (context, index) {
                                  final story =
                                      controller.stories.elementAt(index);
                                  return ListViewBodyCard(
                                    storyModel: story,
                                    isTopStory: story.isTopStory,
                                    onDelete: () {
                                      Utils.showConfirmationDialog(
                                        title: AppStrings.confirmation,
                                        message: AppStrings
                                            .areYouSureYouWantToDelete,
                                        onYes: () =>
                                            controller.deleteStory(story),
                                      );
                                    },
                                    onLike: () =>
                                        controller.likeStory(story, index),
                                    onEdit: () =>
                                        controller.editStory(story, index),
                                    onShare: () => controller.shareStory(story),
                                    onReport: () =>
                                        controller.reportStory(story),
                                  );
                                }),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
