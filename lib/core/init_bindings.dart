import 'package:get/get.dart';
import 'package:lie_and_truth/pages/stories/story_home/controller/story_controller.dart';

class InitBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(StoryController());
  }
}
