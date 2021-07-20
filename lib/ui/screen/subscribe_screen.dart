import 'dart:async';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({Key? key}) : super(key: key);

  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Set<String> _kIds = <String>{
    '1_month_subscription',
    '6_months_subscription',
    '1_year_subscription',
  };

  late ThemeProvider _themeProvider;
  List<ProductDetails> _subscriptions = [];
  String _currentSubscriptionId = "free";
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    if(!ChicPlatform.isDesktop()) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          InAppPurchase.instance.purchaseStream;

      _loadProducts();

      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        print(error);
      });
    }

    super.initState();
  }

  /// Listen to the purchases for Android/iOS
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    var hasItemPurchased = false;

    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Item purchased
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });

    if (!hasItemPurchased) {
      _currentSubscriptionId = "free";
      setState(() {});
    }
  }

  /// Load the subscriptions to display
  _loadProducts() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      print("error");
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds);

    if (response.error == null) {
      _subscriptions = response.productDetails;
    } else {
      print(response.error);
    }

    setState(() {});
  }

  /// Buy a subscription
  _buyProduct(ProductDetails productDetails) async {
    EasyLoading.show();

    // final PurchaseParam purchaseParam =
    //     PurchaseParam(productDetails: productDetails);
    //
    // var isBought = await InAppPurchase.instance
    //     .buyNonConsumable(purchaseParam: purchaseParam);
    //
    // if (isBought) {
    //   // Save the information locally and send it to the server
    // }

    // Update user which subscribed
    var user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user.id);

      if (user != null) {
        user.isSubscribed = true;
        user.subscription = productDetails.id;
        user.updatedAt = DateTime.now();
        await UserService.update(user);
      }
    }

    // Synchronize with the server

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    if (ChicPlatform.isDesktop()) {
      return _displaysDesktopInModal();
    } else {
      return _displaysMobile();
    }
  }

  /// Displays the screen in a modal for the desktop version
  Widget _displaysDesktopInModal() {
    return DesktopModal(
      title: AppTranslations.of(context).text("subscription"),
      body: _displaysBody(),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8, bottom: 8),
          child: ChicTextButton(
            child: Text(AppTranslations.of(context).text("cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  /// Displays the [Scaffold] for the mobile version
  Widget _displaysMobile() {
    return Scaffold(
      backgroundColor: _themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: _themeProvider.secondBackgroundColor,
        brightness: _themeProvider.getBrightness(),
        title: Text(
          AppTranslations.of(context).text("subscription"),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: _displaysBody(),
        ),
      ),
    );
  }

  /// Displays a unified body for both mobile and desktop version
  Widget _displaysBody() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _displaysSubscriptionWidget(
            "free",
            "Free",
            isFree: true,
          ),
          _displaysSubscriptionWidget(
            "1_month_subscription",
            "1 Month Subscription",
          ),
          _displaysSubscriptionWidget(
            "6_months_subscription",
            "6 Months Subscription",
          ),
          _displaysSubscriptionWidget(
            "1_year_subscription",
            "1 Year Subscription",
          ),
        ],
      ),
    );
  }

  /// Display a subscription row
  Widget _displaysSubscriptionWidget(String id, String title,
      {bool isFree = false}) {
    String price = "";
    ProductDetails? productDetails;

    var filteredSubscriptionList =
        _subscriptions.where((s) => s.id == id).toList();
    if (filteredSubscriptionList.isNotEmpty) {
      price = filteredSubscriptionList[0].price;
      productDetails = filteredSubscriptionList[0];
    }

    return ListTile(
      onTap: () {
        if (productDetails != null) {
          _buyProduct(productDetails);
        }
      },
      title: Text(
        title,
        style: TextStyle(color: _themeProvider.textColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          !isFree
              ? Text(
                  price,
                  style: TextStyle(
                    color: _themeProvider.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              : SizedBox.shrink(),
          Container(
            width: 20,
            margin: EdgeInsets.only(left: 20),
            child: id == _currentSubscriptionId
                ? Icon(
                    Icons.check,
                    color: _themeProvider.primaryColor,
                  )
                : SizedBox.shrink(),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
