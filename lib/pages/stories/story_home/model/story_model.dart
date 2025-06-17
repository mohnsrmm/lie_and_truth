import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/utils.dart';

class Like {
  String likedBy; //user id of the user
  DateTime addedOn;

  Like({
    required this.likedBy,
    required this.addedOn,
  }); // when the user liked it

  Map<String, dynamic> toMap() {
    return {
      'likedBy': likedBy,
      'addedOn': addedOn.toIso8601String(),
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      likedBy: map['likedBy'],
      addedOn: DateTime.parse(map['addedOn']),
    );
  }
}

class StoryModel {
  String? title;
  String? content;
  String? id;
  String? createdAt;
  String? updatedAt;
  List<Like>? likeBy;
  String userId = '';
  String userName = '';
  String userImage = '';
  String? videoUrl;
  bool isTopStory = false;

  StoryModel({
    this.title,
    this.content,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId = '',
    this.userName = '',
    this.likeBy = const [],
    this.userImage = '',
    this.videoUrl,
  });

  StoryModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    json['likedBy'] != null
        ? likeBy = List<Like>.from(json['likedBy'].map((x) => Like.fromMap(x)))
        : likeBy = null;

    userId = json['userId'] ?? '';
    userName = json['userName'] ?? '';
    userImage = json['imageUrl'] ?? '';
    videoUrl = json['videoUrl'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['likedBy'] = likeBy?.map((x) => x.toMap()).toList();
    data['userId'] = userId;
    data['userName'] = userName;
    data['imageUrl'] = userImage;
    data['videoUrl'] = videoUrl;
    return data;
  }

  // save story to firestore
  Future<void> create() async {
    // get current time
    final now = DateTime.now();

    final StoryModel storyModel = StoryModel(
      title: title,
      content: content,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
      userId: userId,
      userName: userName,
      userImage: userImage,
      videoUrl: videoUrl,
    );

    if (storyModel.videoUrl != null && storyModel.videoUrl!.isNotEmpty) {
      storyModel.videoUrl = await Utils.uploadFile(
        storyModel.videoUrl!,
        isVideo: true,
      );
    }

    final mapData = storyModel.toJson();
    // save story to firestore
    final storyRespo = await FirebaseFirestore.instance
        .collection(AppDBKeys.storiesFBCollection)
        .add(mapData);

    id = storyRespo.id;

    await FirebaseFirestore.instance
        .collection(AppDBKeys.storiesFBCollection)
        .doc(id)
        .update({
      'id': id,
    });
  }

  // update story
  Future<void> update({bool isNewVideo = false}) async {
    // get firestore instance
    final firestore = FirebaseFirestore.instance;

    // get current time
    final now = DateTime.now();
    if (isNewVideo) {
      if (videoUrl != null && videoUrl!.isNotEmpty) {
        videoUrl = await Utils.uploadFile(
          videoUrl!,
          isVideo: true,
        );
      }
    }

    // update story
    await firestore.collection(AppDBKeys.storiesFBCollection).doc(id).update({
      'title': title,
      'content': content,
      //  if user update video
      if (isNewVideo) "videoUrl": videoUrl,
      'updatedAt': now.toIso8601String(),
    });
  }

  // like story
  Future<void> like() async {
    // get firestore instance
    final firestore = FirebaseFirestore.instance;

    final currLikeBy = Like(
      likedBy: Utils.userData.uid ?? '',
      addedOn: DateTime.now(),
    );

    if (likeBy == null) {
      likeBy = [];
    }
    // check if already liked then remove like
    if (likeBy?.any((element) => element.likedBy == currLikeBy.likedBy) ??
        false) {
      // remove like
      likeBy?.removeWhere((element) => element.likedBy == currLikeBy.likedBy);
    } else {
      // add like
      likeBy?.add(currLikeBy);
    }

    // update story
    await firestore.collection(AppDBKeys.storiesFBCollection).doc(id).update({
      "likedBy": likeBy?.map((e) => e.toMap()).toList() ?? [],
    });
  }

  // delete story
  Future<void> delete() async {
    // get firestore instance
    final firestore = FirebaseFirestore.instance;

    // delete story
    await firestore.collection(AppDBKeys.storiesFBCollection).doc(id).delete();
  }

  // get stories
  static Future<List<StoryModel>> getStories() async {
    // get firestore instance
    final firestore = FirebaseFirestore.instance;

    // get stories
    final stories =
        await firestore.collection(AppDBKeys.storiesFBCollection).get();

    // convert stories to list
    final storyList = stories.docs.map((story) {
      final model = StoryModel.fromJson(
        story.data(),
      );
      model.id = story.id;
      return model;
    }).toList();

    // return story list
    return storyList;
  }

  // get my stories by user id
  static Future<List<StoryModel>> getMyStories() async {
    Utils.debug('getMyStories : ${Utils.userData.uid}');
    // get firestore instance
    final firestore = FirebaseFirestore.instance;
    // search ui from map userData
    // get stories
    final stories = await firestore
        .collection(AppDBKeys.storiesFBCollection)
        .where(
          'userId',
          isEqualTo: Utils.userData.uid,
        )
        .get();

    // convert stories to list
    final storyList = stories.docs.map((story) {
      final model = StoryModel.fromJson(
        story.data(),
      );
      model.id = story.id;
      return model;
    }).toList();

    // return story list
    return storyList;
  }

  StoryModel copyWith({
    required String title,
    required String content,
    required String videoUrl,
  }) {
    return StoryModel(
      title: title,
      content: content,
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      userName: userName,
      likeBy: likeBy,
      userImage: userImage,
      videoUrl: videoUrl,
    );
  }
}
