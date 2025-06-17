import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/pages/stories/story_home/controller/story_controller.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/story_widgets/custom_floating_widget.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/story_widgets/tabbar_widget.dart';

class StoryHomeScreen extends StatelessWidget {
  const StoryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // controller
    final con = Get.find<StoryController>();

    //
    return DefaultTabController(
      length: 2,
      child: Center(
        child: Scaffold(
          floatingActionButton: CustomFloatingWidget(con: con),
          appBar: AppBar(
            title: Text(
              AppStrings.storyHome,
              style: TextStyle(
                color: AppColors.kPrimary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => con.signOut(),
                icon: Icon(
                  Icons.logout,
                  color: AppColors.kPrimary,
                ),
              ),
            ],
            bottom: TabBar(
              onTap: (index) {
                // con.isMyStories.value = index == 0;

                con.isMyStories.value = index == 0;
                con.isMyStories.value ? con.getMyStories() : con.readStories();
              },
              tabs: [
                Tab(text: AppStrings.myStories),
                Tab(text: AppStrings.readStory),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    TabBarListWidget(isMyStories: true),
                    TabBarListWidget(isMyStories: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
