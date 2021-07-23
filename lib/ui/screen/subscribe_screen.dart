import 'dart:async';
import 'dart:io';

import 'package:chic_secret/localization/app_translations.dart';
import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/provider/theme_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/component/common/chic_text_button.dart';
import 'package:chic_secret/ui/component/common/desktop_modal.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';

const String freeId = "free";
const String oneMonthId = "1_month_subscription";
const String sixMonthsId = "6_months_subscription";
const String oneYearId = "1_year_subscription";

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({Key? key}) : super(key: key);

  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late final Set<String> _kIds;

  late ThemeProvider _themeProvider;
  late SynchronizationProvider _synchronizationProvider;
  List<ProductDetails> _subscriptions = [];
  String _currentSubscriptionId = "";

  @override
  void initState() {
    _currentSubscriptionId = freeId;
    _kIds = <String>{
      oneMonthId,
      sixMonthsId,
      oneYearId,
    };

    if (ChicPlatform.isDesktop()) {
      _getSubscription();
    }

    _loadProducts();

    super.initState();
  }

  /// Get the subscription from the local database
  void _getSubscription() async {
    var user = await Security.getCurrentUser();
    if (user != null) {
      user = await UserService.getUserById(user.id);

      if (user != null && user.subscription != null) {
        setState(() {
          _currentSubscriptionId = user!.subscription!;
        });
      }
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
    PurchaseParam purchaseParam;

    String subscriptionId = _synchronizationProvider.currentSubscription;
    if (subscriptionId == freeId) {
      subscriptionId = _currentSubscriptionId;
    }

    if (Platform.isAndroid) {
      var oldSubscriptions = _synchronizationProvider.purchaseDetailsList
          .where((s) => s.productID == subscriptionId)
          .toList();
      GooglePlayPurchaseDetails? oldSubscription;

      if (oldSubscriptions.isNotEmpty) {
        oldSubscription = oldSubscriptions[0] as GooglePlayPurchaseDetails?;
      }

      purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetails,
          applicationUserName: null,
          changeSubscriptionParam: oldSubscription != null
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldSubscription,
                  prorationMode: ProrationMode.immediateWithTimeProration,
                )
              : null);
    } else {
      purchaseParam = PurchaseParam(productDetails: productDetails);
    }

    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    _synchronizationProvider =
        Provider.of<SynchronizationProvider>(context, listen: true);

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
            freeId,
            AppTranslations.of(context).text("free"),
            isFree: true,
          ),
          _displaysSubscriptionWidget(
            oneMonthId,
            AppTranslations.of(context).text("1_month_subscription"),
          ),
          _displaysSubscriptionWidget(
            sixMonthsId,
            AppTranslations.of(context).text("6_months_subscription"),
          ),
          _displaysSubscriptionWidget(
            oneYearId,
            AppTranslations.of(context).text("1_year_subscription"),
          ),
          SizedBox(height: 40),
          ChicPlatform.isDesktop()
              ? Text(
                  AppTranslations.of(context).text("desktop_no_payment"),
                  style: TextStyle(fontSize: 12),
                )
              : SizedBox.shrink(),
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

    String subscriptionId = _synchronizationProvider.currentSubscription;
    if (subscriptionId == freeId) {
      subscriptionId = _currentSubscriptionId;
    }

    return ListTile(
      onTap: ChicPlatform.isDesktop()
          ? null
          : () {
              if (productDetails != null &&
                  subscriptionId != productDetails.id) {
                _buyProduct(productDetails);
              } else if (isFree && subscriptionId != freeId) {}
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
            child: id == subscriptionId
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
}
