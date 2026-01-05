import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:universal_io/io.dart';

import '../utils/log.dart';
import 'firestore_repository.dart';

class SubscriptionRepository {
  final FirestoreRepository _firestoreRepository;

  SubscriptionRepository(this._firestoreRepository);

  static Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);

    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration('goog_AfveruTPRhPpqaMRNdoEBpoJsnl');
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration('appl_ievjDBXFTMbtfKLoeCAlfMvFPyP');
    }
    await Purchases.configure(configuration);
  }

  Future<void> setUserId() async {
    final user = await _firestoreRepository.getUser();
    if (user != null) {
      Purchases.logIn(user.id);
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current?.availablePackages.isNotEmpty == true) {
        return offerings;
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      Log.e('Error getting offerings: $e');
      return null;
    }
  }

  Future<bool> purchase(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return isEntitlementActive(customerInfo);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        Log.e('Error purchasing: $e');
      }
      return false;
    }
  }

  bool isEntitlementActive(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.all['Kvitter Premium']?.isActive == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isPremiumUser() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      Log.e(e);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return isEntitlementActive(customerInfo);
    } on PlatformException catch (e) {
      Log.e('Error restoring purchases: $e');
      return false;
    }
  }
}
