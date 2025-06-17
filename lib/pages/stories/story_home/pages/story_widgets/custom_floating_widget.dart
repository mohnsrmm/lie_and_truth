import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_router.dart';

import '../../controller/story_controller.dart';

class CustomFloatingWidget extends StatefulWidget {
  const CustomFloatingWidget({
    super.key,
    required this.con,
  });

  final StoryController con;

  @override
  State<CustomFloatingWidget> createState() => _CustomFloatingWidgetState();
}

class _CustomFloatingWidgetState extends State<CustomFloatingWidget> {
  ValueNotifier<bool> isShowFloating = ValueNotifier<bool>(true);

  @override
  void initState() {
    widget.con.scrollController.addListener(() {
      if (widget.con.scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isShowFloating.value) isShowFloating.value = false;
      } else {
        if (!isShowFloating.value) isShowFloating.value = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isShowFloating,
        builder: (dcontext, value, child) {
          return Visibility(
            visible: value,
            child: Obx(
              () => widget.con.isMyStories.value
                  ? FloatingActionButton(
                      backgroundColor: AppColors.kPrimary,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          final createdStory =
                              await Get.toNamed(AppRouter.storyCreate);
                          if (createdStory != null)
                            widget.con.stories.add(createdStory);
                        } catch (r) {
                          //
                        }
                      },
                    )
                  : SizedBox.shrink(),
            ),
          );
        });
  }
}
