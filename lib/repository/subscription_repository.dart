import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:glassfy_flutter/models.dart';

import '../utils/log.dart';

class SubscriptionRepository {
  Future<GlassfyOffering?> getOfferings() async {
    try {
      Log.d('Getting offerings');
      var offerings = await Glassfy.offerings();
      var offering = offerings.all
          ?.singleWhere((offering) => offering.offeringId == 'premium');

      offering?.skus?.forEach((sku) {
        Log.d('sku: ${sku.skuId}');
        Log.d('sku: ${sku.product?.description}');
        Log.d('sku: ${sku.product?.price}');
        Log.d('sku: ${sku.product?.currencyCode}');
        Log.d('sku: ${sku.product?.period}');
        Log.d('sku: ${sku.product?.price}');
      });
      return offering;
    } catch (e) {
      Log.e('Error getting offerings: $e');
    }
    return null;
  }

  Future<bool> purchase(GlassfySku skuId) async {
    try {
      var transaction = await Glassfy.purchaseSku(skuId);

      var p = transaction.permissions?.all?.singleWhere(
          (permission) => permission.permissionId == 'kvitter_premium');
      return p?.isValid ?? false;
    } catch (e) {
      Log.e('Error purchasing sku: $e');
      return false;
    }
  }

  Future<bool> isPremiumUser() async {
    try {
      var permission = await Glassfy.permissions();
      return permission.all?.any(
              (permission) => permission.permissionId == 'kvitter_premium') ??
          false;
    } catch (e) {
      Log.e('Error getting permissions: $e');
      return false;
    }
  }

  Future<bool> restoreSubscription() async {
    try {
      final permission = await Glassfy.restorePurchases();
      return permission.all?.any(
              (permission) => permission.permissionId == 'kvitter_premium') ??
          false;
    } catch (e) {
      Log.e('Error getting permissions: $e');
      return false;
    }
  }
}
