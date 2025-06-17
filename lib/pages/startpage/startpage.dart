import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lie_and_truth/core/app_router.dart';
import 'package:lie_and_truth/core/app_strings.dart';
import 'package:lie_and_truth/pages/permission_handler.dart';
import 'package:lie_and_truth/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../homepage/homepage.dart';
import '../homepage/widgets/widgets.dart';

const String kRemoveAdsId = 'remove_ads_production_1_id';

const List<String> _kProductIds = <String>[
  kRemoveAdsId,
];

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  //
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  bool _isAvailableStore = false;
  static bool showAds = true;
  late SharedPreferences preferences;

  initPurchase() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (Object error) {
        // handle error here if you want.
      },
    );
  }

  initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    //
    if (isAvailable) {
      await _inAppPurchase.restorePurchases();
    }

    if (!isAvailable) {
      setState(() {
        _isAvailableStore = isAvailable;
        _products = <ProductDetails>[];
      });
      return;
    }
    //

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

    // In case of error
    if (productDetailResponse.error != null) {
      setState(() {
        _isAvailableStore = isAvailable;
        _products = productDetailResponse.productDetails;
      });
      return;
    }
    // If no products yet
    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _isAvailableStore = isAvailable;
        _products = productDetailResponse.productDetails;
      });
      return;
    }
    // If products found
    setState(() {
      _isAvailableStore = isAvailable;
      _products = productDetailResponse.productDetails;
    });
  }

  void initVideoPermissions() async {
    PermissionHandler permissionHandler = PermissionHandler();
    bool isGranted =
        await permissionHandler.onlyCheckUserHavePermissionsOrNot();
    if (isGranted) {
      Utils.debug('permission granted');
    } else {
      permissionHandler.showPermissionDialog(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // initVideoPermissions();
    initSharedPref();
    initStoreInfo();
    initPurchase();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/screen_1.jpg')),
              ),
            ),
            Positioned(
              // bottom: MediaQuery.of(context).size.height * 0.225,
              // width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: InkWell(
                        child: Image.asset('assets/images/start_button.png'),
                        onTap: _onStartButtonPressed,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Get.width * 0.10),
                      child: Text(
                        AppStrings.startPageDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(FirebaseAuth.instance.currentUser == null
                            ? AppRouter.login
                            : AppRouter.storyHome);
                      },
                      child: Text(AppStrings.storyHome),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        showAds
                            ? TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.yellow.withAlpha(75),
                                  ),
                                ),
                                onPressed: () async =>
                                    await _onPressedRemoveAds(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Premium Account',
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: <Color>[
                                                Colors.orange,
                                                Colors.grey,
                                                Colors.yellow
                                                //add more color here.
                                              ],
                                            ).createShader(const Rect.fromLTWH(
                                                0.0, 0.0, 200.0, 100.0))),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.70,
                                      child: Text(
                                        'remove ads - special badge-upload direct video on your storage - and more advantages',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () async {
                      var url = Uri.parse(
                          'https://www.facebook.com/profile.php?id=100070781207134');
                      debugPrint('URL ==>$url');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: Image.asset('assets/images/fb_logo.png'),
                    iconSize: 50,
                  ),
                  IconButton(
                    onPressed: () async {
                      var url = Uri.parse('https://nasrforgraphic.com/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: Image.asset('assets/images/site_logo.png'),
                    iconSize: 50,
                  ),
                  IconButton(
                    onPressed: () async {
                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.openStoreListing();
                      }
                    },
                    icon: Image.asset('assets/images/rate_us.png'),
                    iconSize: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  Future<void> _onPressedRemoveAds() async {
    if (_isAvailableStore) {
      //
      if (_products.isEmpty) {
        // try to retrieve products again
        final ProductDetailsResponse productDetailResponse =
            await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
        _products = productDetailResponse.productDetails;
      }
      //
      if (_products.isNotEmpty) {
        PurchaseParam purchaseParam = PurchaseParam(
          productDetails: _products[0],
        );
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
      //
      else if (_products.isEmpty) {
        _showSnackBar('Some thing went wrong, please try again later');
      }
      //
    }
    //
    else {
      _showSnackBar("You can't make in-app purchases!");
    }
    //
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    //
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      //
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showLoadingSpinnerDialog();
      }
      //
      else {
        //
        if (purchaseDetails.status == PurchaseStatus.error) {
          _showSnackBar('Some thing went wrong, please try again later');
        }
        //
        else if (purchaseDetails.status == PurchaseStatus.restored) {
          _handleRestoring(purchaseDetails);
        }
        //
        else if (purchaseDetails.status == PurchaseStatus.purchased) {
          _handlePurchasing();
        }
        //
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        //
      }
    }
  }

  _handleRestoring(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == kRemoveAdsId) {
      setState(() {
        showAds = false;
      });
    }
  }

  _handlePurchasing() {
    setState(() {
      showAds = false;
    });
  }

  _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  _showLoadingSpinnerDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('loading....'),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  void _onStartButtonPressed() {
    // if (!showAds) {
    //   navigateToHomeScreen();
    //   return;
    // }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose one of the following options'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                checkIsFirstTimeOpenedThenNavigate();
              },
              child: const Text('Start Lie Detector'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                checkIsFirstTimeOpenedThenNavigate(isFromFunnyQuestion: true);
              },
              child: const Text('Try Funny Questions'),
            ),
          ],
        );
      },
    );
  }

  void checkIsFirstTimeOpenedThenNavigate({bool isFromFunnyQuestion = false}) {
    if (preferences.getBool('firstTimeOpened') ?? false) {
      navigateToHomeScreen(isFromFunnyQuestion: isFromFunnyQuestion);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
                'Lie detector is just for fun and to joke and prank with your friends'),
            actions: [
              TextButton(
                onPressed: () {
                  navigateToHomeScreen(
                    isFromDialog: true,
                    isFromFunnyQuestion: isFromFunnyQuestion,
                  );
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
  }

  void navigateToHomeScreen({
    bool isFromDialog = false,
    bool isFromFunnyQuestion = false,
  }) {
    if (isFromDialog) {
      preferences.setBool('firstTimeOpened', true);
      Get.back();
    }

    Utils.debug('funnyQuestionIndex: $isFromFunnyQuestion');
    Get.to(
      () => HomePage(
        showAds: showAds,
        funnyQuestionIndex: Random().nextInt(questionsList.length - 1),
        removeAdsCallback: _onPressedRemoveAds,
        isFromFunnyQuestion: isFromFunnyQuestion,
      ),
    );
  }

//
}
