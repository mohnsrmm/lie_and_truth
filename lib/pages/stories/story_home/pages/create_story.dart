import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/core/common_widgets/common_text_field.dart';
import 'package:lie_and_truth/pages/stories/story_home/model/story_model.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/story_widgets/common_editor_widget.dart';
import 'package:lie_and_truth/utils.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key, this.story});

  final StoryModel? story;

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final titleController = TextEditingController();
  final videoController = TextEditingController();
  QuillController _controller = QuillController.basic();

  bool isUpdating = false;

  String videoUrl = '';
  String OldVideoUrl = '';

  @override
  void initState() {
    if (widget.story != null) {
      isUpdating = true;
      titleController.text = widget.story?.title ?? '';
      OldVideoUrl = videoUrl = widget.story?.videoUrl ?? '';
      videoController.text = videoUrl.split('/').last;
      _controller.document = Document.fromJson(
        jsonDecode(widget.story?.content ?? ''),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();

  // create story
  Future<void> createStory() async {
    Utils.showLoading();
    // create story
    final model = isUpdating
        ? widget.story?.copyWith(
            title: titleController.text,
            content: jsonEncode(_controller.document.toDelta().toJson()),
            videoUrl: videoUrl,
          )
        : StoryModel(
            title: titleController.text,
            content: jsonEncode(_controller.document.toDelta().toJson()),
            userId: Utils.userData.uid ?? '',
            userName: Utils.userData.name ?? '',
            videoUrl: videoUrl,
            userImage: Utils.userData.profilePic ?? '',
          );
    try {
      isUpdating
          ? await model?.update(
              isNewVideo: videoUrl != OldVideoUrl,
            )
          : await model?.create();

      if (isUpdating && videoUrl != OldVideoUrl) {
        // delete old one
        await Utils.deleteFileFromFirebase(OldVideoUrl);
      }
      Utils.hideLoading();

      // close screen and return story
      Get.back(result: model);
      if (!isUpdating) {
        Utils.showSnackBar(
          message: AppStrings.successFully + ' ' + AppStrings.added,
          isSuccess: true,
        );
      }
    } catch (e) {
      Utils.hideLoading();

      Utils.debug("Error : $e");

      Utils.showSnackBar(message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUpdating ? AppStrings.editStory : AppStrings.createStory,
          style: TextStyle(color: AppColors.kPrimary, fontSize: 20),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // pick video if user is premium
                if (Utils.isPremium)
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () async {
                      final url = await Utils.pickImageVideo(isVideo: true);
                      if (url != null) {
                        setState(() {
                          videoUrl = url;
                          videoController.text = url.split('/').last;
                        });
                      }
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: CommonTextField(
                        labelText: AppStrings.pickVideo,
                        hintText: AppStrings.selectPrankVideo,
                        capitalizeEachWord: true,
                        controller: videoController,
                        suffixIcon: Icon(
                          Icons.video_collection,
                          color: AppColors.kPrimary,
                        ),
                        readonly: true,
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return (AppStrings.selectPrankVideo).toLowerCase();
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                  ),

                SizedBox(height: 20),
                CommonTextField(
                  labelText: AppStrings.title,
                  hintText: AppStrings.story + ' ' + AppStrings.title,
                  capitalizeEachWord: true,
                  controller: titleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return (AppStrings.pleaseEnterPrefix + AppStrings.title)
                          .toLowerCase();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: QuillProvider(
                    configurations: QuillConfigurations(
                      controller: _controller,
                      sharedConfigurations: QuillSharedConfigurations(
                        dialogBarrierColor: Colors.red,
                        dialogTheme: QuillDialogTheme(
                          inputTextStyle: TextStyle(color: AppColors.kPrimary),
                          dialogBackgroundColor: AppColors.kPrimaryContainer,
                          labelTextStyle: TextStyle(color: AppColors.kPrimary),
                          buttonTextStyle: TextStyle(color: AppColors.kPrimary),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        QuillToolbar(
                          configurations: QuillToolbarConfigurations(
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryContainer,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: AppColors.kPrimary,
                                ),
                              ),
                            ),
                            buttonOptions: QuillToolbarButtonOptions(
                              bold: QuillToolbarToggleStyleButtonOptions(
                                fillColor: AppColors.kPrimary,
                                iconTheme: QuillIconTheme(
                                  iconUnselectedColor:
                                      AppColors.kPrimaryContainer,
                                  iconSelectedColor: AppColors.white,
                                  iconSelectedFillColor: AppColors.kPrimary,
                                ),
                              ),
                              quote: QuillToolbarToggleStyleButtonOptions(
                                fillColor: AppColors.kPrimary,
                                iconTheme: QuillIconTheme(
                                  iconUnselectedColor:
                                      AppColors.kPrimaryContainer,
                                  iconSelectedColor: AppColors.white,
                                  iconSelectedFillColor: AppColors.kPrimary,
                                ),
                              ),
                              italic: QuillToolbarToggleStyleButtonOptions(
                                fillColor: AppColors.kPrimary,
                                iconTheme: QuillIconTheme(
                                  iconUnselectedColor:
                                      AppColors.kPrimaryContainer,
                                  iconSelectedColor: AppColors.white,
                                  iconSelectedFillColor: AppColors.kPrimary,
                                ),
                              ),
                              listBullets: QuillToolbarToggleStyleButtonOptions(
                                fillColor: AppColors.kPrimary,
                                iconTheme: QuillIconTheme(
                                  iconUnselectedColor:
                                      AppColors.kPrimaryContainer,
                                  iconSelectedColor: AppColors.white,
                                  iconSelectedFillColor: AppColors.kPrimary,
                                ),
                              ),
                              toggleCheckList:
                                  QuillToolbarToggleCheckListButtonOptions(
                                fillColor: AppColors.kPrimary,
                              ),
                              backgroundColor: QuillToolbarColorButtonOptions(
                                iconSize: 20,
                                dialogBarrierColor: Colors.transparent,
                                iconTheme: QuillIconTheme(
                                  iconUnselectedColor: Colors.transparent,
                                ),
                              ),
                            ),
                            multiRowsDisplay: false,
                            showBoldButton: true,
                            showItalicButton: true,
                            showUnderLineButton: false,
                            showStrikeThrough: false,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showClearFormat: false,
                            showListNumbers: false,
                            showListBullets: true,
                            showIndent: false,
                            showQuote: true,
                            showCodeBlock: false,
                            showLink: false,
                            showSearchButton: false,
                            showHeaderStyle: false,
                            showRedo: false,
                            showUndo: false,
                            showDirection: false,
                            showAlignmentButtons: false,
                            showDividers: false,
                            showJustifyAlignment: false,
                            showLeftAlignment: false,
                            showCenterAlignment: false,
                            showRightAlignment: false,
                            showListCheck: false,
                            showSmallButton: false,
                            showInlineCode: false,
                            showSuperscript: false,
                            showSubscript: false,
                          ),
                        ),
                        Expanded(
                          child: CommonTextEditorWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // check formKey
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Utils.debug(
                        '...,' + _controller.document.length.toString() + '.');
                    if (_controller.document.length == 1) {
                      Utils.showSnackBar(
                        message:
                            AppStrings.pleaseEnterPrefix + AppStrings.content,
                      );
                      return;
                    }

                    // check video url
                    // if (Utils.isPremium && videoUrl.isEmpty) {
                    //   Utils.showSnackBar(
                    //     message: AppStrings.pleaseSelectVideo,
                    //   );
                    //   return;
                    // }
                    Get.defaultDialog(
                      titlePadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      backgroundColor: AppColors.kPrimaryContainer,
                      title: AppStrings.warning,
                      titleStyle: TextStyle(color: AppColors.kPrimary),
                      confirmTextColor: AppColors.white,
                      cancelTextColor: AppColors.white,
                      buttonColor: AppColors.kPrimary,
                      onConfirm: () async {
                        Get.back();
                        createStory();
                      },
                      onCancel: () {},
                      content: Column(
                        children: [
                          // report reason
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppStrings.privacyPolicy,
                              style: TextStyle(color: AppColors.kPrimary),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 20),
                          // report button
                        ],
                      ),
                    );
                  },
                  child: Text(
                    isUpdating ? AppStrings.update : AppStrings.create,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
