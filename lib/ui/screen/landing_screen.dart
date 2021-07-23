import 'dart:async';

import 'package:chic_secret/provider/synchronization_provider.dart';
import 'package:chic_secret/service/user_service.dart';
import 'package:chic_secret/ui/screen/main_desktop_screen.dart';
import 'package:chic_secret/ui/screen/subscribe_screen.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:chic_secret/utils/chic_platform.dart';
import 'package:chic_secret/utils/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  VaultScreenController _vaultScreenController = VaultScreenController();
  MainDesktopScreenController _mainDesktopScreenController =
      MainDesktopScreenController();
  SynchronizationProvider? _synchronizationProvider;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  didChangeDependencies() {
    super.didChangeDependencies();

    if (_synchronizationProvider == null) {
      _synchronizationProvider =
          Provider.of<SynchronizationProvider>(context, listen: true);

      _firstSynchronization();
    }

    if (!ChicPlatform.isDesktop()) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          InAppPurchase.instance.purchaseStream;

      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        print(error);
      });
    }
  }

  /// Synchronize the first time we start the application
  _firstSynchronization() async {
    Future(() {
      _firstConnection();
    });

    await _synchronizationProvider!.synchronize(isFullSynchronization: true);

    if (_mainDesktopScreenController.reloadAfterSynchronization != null) {
      _mainDesktopScreenController.reloadAfterSynchronization!();
    }

    if (_vaultScreenController.reloadVaults != null) {
      _vaultScreenController.reloadVaults!();
    }

    if (_vaultScreenController.reloadCategories != null) {
      _vaultScreenController.reloadCategories!();
    }

    if (_vaultScreenController.reloadTags != null) {
      _vaultScreenController.reloadTags!();
    }
  }

  /// Listen to the purchases for Android/iOS
  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    EasyLoading.show();
    bool hasSubscription = false;

    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      var productId = purchaseDetails.productID;

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Item purchased
          var user = await Security.getCurrentUser();
          if (user != null) {
            user = await UserService.getUserById(user.id);

            if (_synchronizationProvider != null &&
                user!.subscription != null &&
                user.subscription == productId) {
              _synchronizationProvider!.addPurchasedItem(purchaseDetails);
              hasSubscription = true;
            }

            if (user != null && user.subscription != productId) {
              user.isSubscribed = true;
              user.subscription = productId;
              user.updatedAt = DateTime.now();
              user.subscriptionStartDate = DateTime.now();
              await UserService.update(user);
            }
          }

          // Synchronize with the server
          await _synchronizationProvider!
              .synchronize(isFullSynchronization: true);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });

    // Subscription had been canceled
    if (!hasSubscription) {
      var user = await Security.getCurrentUser();
      if (user != null) {
        user = await UserService.getUserById(user.id);

        if (user != null && user.subscription != null) {
          switch (user.subscription!) {
            case oneMonthId:
              user.subscriptionEndDate = DateTime.now();
              break;
            case sixMonthsId:
              user.subscriptionEndDate = DateTime.now();
              break;
            case oneYearId:
              user.subscriptionEndDate = DateTime.now();
              break;
            default:
              return;
          }

          user.isSubscribed = false;
          user.subscription = freeId;
          user.updatedAt = DateTime.now();

          await UserService.update(user);
        }
      }
    }

    EasyLoading.dismiss();
  }

  /// Displays the next screen depending if the application is launched on
  /// desktop or mobile version
  _firstConnection() async {
    if (ChicPlatform.isDesktop()) {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainDesktopScreen(
            mainDesktopScreenController: _mainDesktopScreenController,
          ),
        ),
      );
    } else {
      return await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VaultsScreen(
            vaultScreenController: _vaultScreenController,
            onVaultChange: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
