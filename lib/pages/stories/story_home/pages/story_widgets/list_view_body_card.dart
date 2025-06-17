import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:lie_and_truth/core/app_colors.dart';
import 'package:lie_and_truth/pages/stories/story_home/model/story_model.dart';
import 'package:lie_and_truth/pages/stories/story_home/pages/story_widgets/common_editor_widget.dart';
import 'package:lie_and_truth/utils.dart';

import '../../../../../generated/assets.dart';

class ListViewBodyCard extends StatefulWidget {
  const ListViewBodyCard({
    super.key,
    required this.storyModel,
    required this.onDelete,
    required this.onLike,
    required this.onEdit,
    required this.onShare,
    required this.onReport,
    this.isTopStory = false,
  });

  final StoryModel storyModel;
  final dynamic onDelete;
  final dynamic onLike;
  final dynamic onEdit;
  final dynamic onShare;
  final dynamic onReport;
  final bool isTopStory;

  @override
  State<ListViewBodyCard> createState() => _ListViewBodyCardState();
}

class _ListViewBodyCardState extends State<ListViewBodyCard> {
  bool get isAlreadyLiked =>
      widget.storyModel.likeBy
          ?.where((e) => e.likedBy == Utils.userData.uid)
          .isNotEmpty ??
      false;

  int get likes => widget.storyModel.likeBy?.length ?? 0;

  String get getFirstChar => widget.storyModel.userName.isEmpty
      ? ''
      : widget.storyModel.userName.toString().substring(0, 1).toUpperCase();

  final QuillController _controller = QuillController.basic();

  List<dynamic> get content => jsonDecode(widget.storyModel.content ?? '');

  // late final ChewieController chewieController;

  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    initChewie();

    Utils.debug(widget.storyModel.content ?? '');
    Utils.debug(content.toString());
    super.initState();
    _controller.document = Document.fromJson(content);
    if (widget.storyModel.userImage.isNotEmpty) {
      try {
        precacheImage(NetworkImage(widget.storyModel.userImage), context);
      } catch (e) {}
    }
  }

  initChewie() async {
    Utils.debug('init videoUrl: ${widget.storyModel.videoUrl}');
    if (widget.storyModel.videoUrl?.isEmpty ?? true) return;
    final cachedVideoPath =
        await DefaultCacheManager().downloadFile(widget.storyModel.videoUrl!);

    player.setDataSource(cachedVideoPath.file.path, showCover: true);

    // chewieController = ChewieController(
    //   videoPlayerController: VideoPlayerController.networkUrl(
    //     Uri.parse(widget.storyModel.videoUrl!),
    //   ),
    //   autoPlay: false,
    //   looping: false,
    //   // loading
    //   placeholder: Center(
    //     child: CircularProgressIndicator(
    //       color: AppColors.kPrimary,
    //     ),
    //   ),
    //   autoInitialize: true,
    //   errorBuilder: (context, errorMessage) {
    //     return Center(
    //       child: Text(
    //         errorMessage,
    //         style: TextStyle(color: AppColors.kPrimary),
    //       ),
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      surfaceTintColor: AppColors.kPrimaryContainer,
      color: AppColors.kPrimaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            dense: true,
            leading: CircleAvatar(
              backgroundColor: AppColors.kPrimary.withOpacity(0.5),
              child: widget.storyModel.userImage.isEmpty
                  ? Text(
                      getFirstChar,
                      style: TextStyle(color: AppColors.white),
                    )
                  : CircleAvatar(
                      radius: 53,
                      backgroundColor: AppColors.kPrimary,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.kSecondary,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network((widget.storyModel.userImage),
                              fit: BoxFit.cover, width: 100, height: 100,
                              errorBuilder: (context, error, stack) {
                            return Text(
                              getFirstChar,
                              style: TextStyle(color: AppColors.white),
                            );
                          }),
                        ),
                      ),
                    ),
            ),

            trailing: Utils.userData.uid == widget.storyModel.userId
                ? PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.kPrimary,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: widget.onEdit,
                        child: const Text('Edit'),
                      ),
                      PopupMenuItem(
                        onTap: widget.onDelete,
                        child: const Text('Delete'),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: widget.onReport,
                    child: Icon(
                      Icons.report,
                      color: AppColors.kPrimary,
                    ),
                  ),
            title: Text(
              widget.storyModel.title ?? '',
              maxLines: 2,
              style: TextStyle(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            // date formatted from createdAt like this: 01/08/2021 12:00:00
            subtitle: Text(
              formatDate(
                DateTime.parse(
                    widget.storyModel.createdAt ?? DateTime.now().toString()),
                [HH, ':', nn, ' ', dd, '/', mm, '/', yyyy],
              ),
              style: TextStyle(color: AppColors.kGrey.withAlpha(80)),
            ),
          ),
          // content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QuillProvider(
                    configurations: QuillConfigurations(
                      controller: _controller,
                      sharedConfigurations: QuillSharedConfigurations(
                        animationConfigurations:
                            const QuillAnimationConfigurations(
                          checkBoxPointItem: true,
                        ),
                      ),
                    ),
                    child: CommonTextEditorWidget(
                      readOnly: true,
                    ),
                  ),
                ),
                if (Utils.userData.uid != widget.storyModel.userId &&
                    widget.isTopStory)
                  Image.asset(
                    Assets.imagesBadge,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          // video player
          if (widget.storyModel.videoUrl != null &&
              widget.storyModel.videoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FijkView(
                  player: player,
                  width: Get.width,
                  fsFit: FijkFit.fitHeight,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            // alignment: MainAxisAlignment.spaceBetween,
            children: [
              if (Utils.userData.uid != widget.storyModel.userId)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      likes.toString(),
                      style: TextStyle(
                        color: AppColors.kPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onLike,
                      child: Icon(
                        isAlreadyLiked
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_off_alt_outlined,
                        color: isAlreadyLiked
                            ? AppColors.kPrimary
                            : AppColors.kPrimary,
                      ),
                    ),
                  ],
                ),
              TextButton(
                onPressed: widget.onShare,
                child: Icon(
                  Icons.share_outlined,
                  color: AppColors.kPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
