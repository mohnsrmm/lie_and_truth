import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lie_and_truth/pages/homepage/widgets/funny_questions_widget.dart';
import 'package:lie_and_truth/utils.dart';
import 'package:volume_controller/volume_controller.dart';

class HomePage extends StatefulWidget {
  final bool showAds;

  final int funnyQuestionIndex;

  final bool isFromFunnyQuestion;

  final Future<void> Function() removeAdsCallback;

  const HomePage({
    required this.showAds,
    required this.funnyQuestionIndex,
    required this.isFromFunnyQuestion,
    Key? key,
    required this.removeAdsCallback,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum GameResult {
  none,
  truth,
  lie;

  static final Random rnd = Random();

  static GameResult randomResult() {
    var result = values.toList();
    result.removeWhere((element) => element == GameResult.none);
    return result[rnd.nextInt(result.length)];
  }
}

class _HomePageState extends State<HomePage> {
  ImageSequenceAnimatorState? fingerImageSequenceAnimator;
  ImageSequenceAnimatorState? heartImageSequenceAnimator;

  AdManagerBannerAd? _anchoredAdaptiveAd;
  AdManagerInterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isLoaded = false;

  AudioPlayer? player = AudioPlayer();

  final List<String> _fullPathsHeart = [];

  final List<String> _fullPathsFinger = [];

  bool isHeartDisplay = false;

  double volume = 0;

  GameResult result = GameResult.none;

  var startVolumeListing = false;

  var volumeController = VolumeController();

  late Timer vibrationTimer;

  @override
  void initState() {
    super.initState();

    loadRewardedAd(useCounter: false);
    debugPrint('Banner load --');
    volumeController.showSystemUI = false;
    VolumeController().getVolume().then((value) {
      volume = value;
      debugPrint('Current Volume ==>$volume');
    });
    for (int i = 0; i < 138; i++) {
      String value = i.toString();
      while (value.length < 5) {
        value = "0$value";
      }
      _fullPathsFinger.add("assets/images/print/frame_$value.png");
    }

    for (int i = 0; i < 66; i++) {
      String value = i.toString();
      while (value.length < 5) {
        value = "0$value";
      }
      _fullPathsHeart.add("assets/images/heart/heart_$value.png");
    }
    player?.setAsset('assets/sounds/finger_sound.mp3');
    player?.playerStateStream.listen(
      (state) {
        switch (state.processingState) {
          case ProcessingState.completed:
            var old = player;
            if (old != null) {
              old.dispose();
            }
            setStartHeartbeatSound();
            break;
          case ProcessingState.idle:
            // TODO: Handle this case.
            break;
          case ProcessingState.loading:
            // TODO: Handle this case.
            break;
          case ProcessingState.buffering:
            // TODO: Handle this case.
            break;
          case ProcessingState.ready:
            // TODO: Handle this case.
            break;
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showAds) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    debugPrint('Banner load');
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = AdManagerBannerAd(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // for test ads
          : 'ca-app-pub-6016208251876595/3138911413',
      sizes: [size],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as AdManagerBannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  void loadInterstitialAd() {
    AdManagerInterstitialAd.load(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712' // for test ads
          : 'ca-app-pub-6016208251876595/8199666401',
      request: const AdManagerAdRequest(),
      adLoadCallback: AdManagerInterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
          showInterstitial();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdManagerInterstitialAd failed to load: $error');
        },
      ),
    );
  }

  bool get willAdShow => Utils.adCounter >= 3;

  bool get willAdShowBasedOnCount {
    Utils.debug('Ad Counter ${Utils.adCounter}');
    if (Utils.adCounter >= 3) {
      Utils.adCounter = 0;
      return true;
    }
    Utils.adCounter++;

    return false;
  }

  void loadRewardedAd({bool useCounter = true}) {
    if (useCounter && !willAdShowBasedOnCount) return;
    RewardedAd.loadWithAdManagerAdRequest(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917' // for test ads
          : 'ca-app-pub-6016208251876595/9593067378',
      adManagerRequest: const AdManagerAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          loadRewardedAd();
        },
      ),
    );
  }

  void showInterstitial() {
    if (widget.showAds) {
      _interstitialAd?.show();
      loadRewardedAd();
    }
  }

  void setStartHeartbeatSound() {
    debugPrint('Start Heartbeat sound');
    player = AudioPlayer();
    player?.setAsset('assets/sounds/start_heartbeat.mp3');
    player?.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.completed:
          var old = player;
          if (old != null) {
            old.dispose();
          }
          setHeartbeatSound();
          break;
        case ProcessingState.idle:
          // TODO: Handle this case.
          break;
        case ProcessingState.loading:
          // TODO: Handle this case.
          break;
        case ProcessingState.buffering:
          // TODO: Handle this case.
          break;
        case ProcessingState.ready:
          // TODO: Handle this case.
          break;
      }
    });
    player?.play();
  }

  void setHeartbeatSound() async {
    player = AudioPlayer();
    listenVolume();
    player?.setAsset('assets/sounds/heartbeat.mp3');
    player?.play();
    Timer(const Duration(seconds: 1), () {
      startVolumeListing = true;
    });
    Timer(const Duration(seconds: 7), () {
      if (result == GameResult.none) {
        setResult(GameResult.randomResult());
      }
    });
  }

  void listenVolume() {
    volumeController.listener((localVolume) {
      debugPrint('Changed Volume ==>$localVolume');
      if (result != GameResult.none) {
        return;
      }

      if (startVolumeListing == false) {
        volume = localVolume;
        return;
      }

      if (localVolume == 1) {
        debugPrint('Up Key');
        setResult(GameResult.truth);
      } else if (volume > localVolume) {
        debugPrint('Down Key');
        setResult(GameResult.lie);
      } else {
        setResult(GameResult.truth);
        debugPrint('Up Key');
      }
      volume = localVolume;
    });
  }

  void setResult(GameResult result) {
    setState(() {
      this.result = result;
    });
    var secondPlayer = AudioPlayer();

    if (result == GameResult.lie) {
      _vibrate();
      secondPlayer.setAsset('assets/sounds/lie.mp3');
    }
    if (result == GameResult.truth) {
      secondPlayer.setAsset('assets/sounds/truth.mp3');
    }

    secondPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        secondPlayer.dispose();
      }
    });
    secondPlayer.play();

    Timer(
      const Duration(seconds: 5),
      () {
        player?.stop();
        player?.dispose();
        heartImageSequenceAnimator?.stop();
        showTryAgainPopUp();
      },
    );
    if (widget.showAds) {
      loadInterstitialAd();
    }
  }

  void playResultSound() {}

  void onFingerReadyToPlay(ImageSequenceAnimatorState imageSequenceAnimator) {
    fingerImageSequenceAnimator = imageSequenceAnimator;
  }

  void onFingerPlaying(ImageSequenceAnimatorState imageSequenceAnimator) {
    if (!mounted) return;
    setState(() {});
  }

  void onFingerFinish(ImageSequenceAnimatorState imageSequenceAnimator) {
    _stopVibrationTimer();
    setState(() {
      isHeartDisplay = true;
    });
  }

  void _stopVibrationTimer() {
    if (vibrationTimer.isActive) {
      vibrationTimer.cancel();
    }
  }

  void onHeartReadyToPlay(ImageSequenceAnimatorState imageSequenceAnimator) {
    heartImageSequenceAnimator = imageSequenceAnimator;
  }

  void onHeartPlaying(ImageSequenceAnimatorState imageSequenceAnimator) {
    setState(() {});
  }

  void onHeartFinish(ImageSequenceAnimatorState imageSequenceAnimator) {}

  void _vibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      Vibrate.feedback(FeedbackType.medium);
    }
  }

  Widget truthWidget() {
    if (result == GameResult.none || result == GameResult.lie) {
      return Image.asset(
        'assets/images/btn_gray.png',
        width: 80,
      );
    } else {
      return Image.asset(
        'assets/images/btn_green.png',
        width: 80,
      );
    }
  }

  Widget lieWidget() {
    if (result == GameResult.none || result == GameResult.truth) {
      return Image.asset(
        'assets/images/btn_gray.png',
        width: 80,
      );
    } else {
      return Image.asset(
        'assets/images/btn_red.png',
        width: 80,
      );
    }
  }

  void showTryAgainPopUp() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            actions: [
              widget.showAds ? _nonPremiumActions() : _premiumActions()
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    player?.dispose();
    _anchoredAdaptiveAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            (widget.showAds && _anchoredAdaptiveAd != null && _isLoaded)
                ? Container(
                    color: Colors.green,
                    width: _anchoredAdaptiveAd!.sizes.first.width.toDouble(),
                    height: _anchoredAdaptiveAd!.sizes.first.height.toDouble(),
                    child: AdWidget(ad: _anchoredAdaptiveAd!),
                  )
                : Container(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'assets/images/screen_2.jpg',
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 150,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          truthWidget(),
                          // ValueListenableBuilder(
                          //     valueListenable: VideoRecorder.isCameraReady,
                          //     builder: (context, value, child) {
                          //       return value &&
                          //               videoPlayer.videoController != null &&
                          //               (videoPlayer.videoController?.value
                          //                       .isInitialized ??
                          //                   false)
                          //           ? Container(
                          //               width: 150,
                          //               height: 150,
                          //               decoration: BoxDecoration(
                          //                 borderRadius:
                          //                     BorderRadius.circular(20),
                          //               ),
                          //               clipBehavior: Clip.antiAlias,
                          //               child: CameraPreview(
                          //                 videoPlayer.videoController!,
                          //                 key: UniqueKey(),
                          //               ),
                          //             )
                          //           : SizedBox.shrink();
                          //     }),
                          lieWidget(),
                        ],
                      ),
                      isHeartDisplay
                          ? Align(
                              alignment: Alignment.center,
                              child: AspectRatio(
                                aspectRatio: 720 / 480,
                                child: ImageSequenceAnimator(
                                  'assets/images/heart',
                                  'heart_',
                                  0,
                                  5,
                                  'png',
                                  66,
                                  key: const Key('heart'),
                                  fullPaths: _fullPathsHeart,
                                  onReadyToPlay: onHeartReadyToPlay,
                                  onPlaying: onHeartPlaying,
                                  onFinishPlaying: onHeartFinish,
                                  fps: 23,
                                  isLooping: true,
                                  // isAutoPlay: false,
                                ),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: 720 / 480,
                              child: widget.isFromFunnyQuestion
                                  ? FunnyQuestionsWidget(
                                      index: widget.funnyQuestionIndex,
                                    )
                                  : SizedBox.shrink(),
                            ),
                      Column(
                        children: [
                          isHeartDisplay
                              ? SizedBox(
                                  width: Get.width / 1.04,
                                  child: const AspectRatio(
                                    aspectRatio: 1280 / 500,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Heartbeat and hand temperature are being checked...',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: Get.width / 1.5,
                                  child: InkWell(
                                    child: AspectRatio(
                                      aspectRatio: 1280 / 720,
                                      child: ImageSequenceAnimator(
                                        'assets/images/print',
                                        'frame_',
                                        0,
                                        5,
                                        'png',
                                        138,
                                        key: const Key('offline'),
                                        fullPaths: _fullPathsFinger,
                                        onReadyToPlay: onFingerReadyToPlay,
                                        onPlaying: onFingerPlaying,
                                        onFinishPlaying: onFingerFinish,
                                        fps: 34,
                                        isAutoPlay: false,
                                      ),
                                    ),
                                    onTapDown: (TapDownDetails details) async {
                                      debugPrint(
                                          '***************************tap down');
                                      fingerImageSequenceAnimator?.play();
                                      player?.play();

                                      vibrationTimer = Timer.periodic(
                                          const Duration(milliseconds: 500),
                                          (timer) {
                                        _vibrate();
                                      });
                                    },
                                    onTapUp: (_) {
                                      _stopVibrationTimer();
                                    },
                                  ),
                                ),
                          SizedBox(
                            height: (Get.height * 135 / 1002),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                result == GameResult.lie
                                    ? 'Lie'
                                    : result == GameResult.truth
                                        ? 'Truth'
                                        : '',
                                style: TextStyle(
                                  color: result == GameResult.lie
                                      ? Colors.red
                                      : result == GameResult.truth
                                          ? Colors.green
                                          : Colors.transparent,
                                  fontSize: 70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nonPremiumActions() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                if (!willAdShow) {
                  Get.back();
                  Get.back();
                  return;
                }
                if (_rewardedAd != null) {
                  _rewardedAd?.show(
                    onUserEarnedReward:
                        (AdWithoutView ad, RewardItem rewardItem) {
                      loadRewardedAd();
                      Get.back();
                      Get.back();
                    },
                  );
                } else {
                  Get.back();
                  Get.back();
                }
              },
              child: Text(
                willAdShow ? 'Watch Ads to Try Again' : 'Try Again',
              ),
            ),
            TextButton(
              onPressed: () async {
                await widget.removeAdsCallback();
                Get.back();
                Get.back();
              },
              child: Text('Play Forever and Remove Ads'),
            ),
          ],
        ),
      );

  Widget _premiumActions() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
}
