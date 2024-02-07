import 'package:glassfy_flutter/glassfy_flutter.dart';
import 'package:glassfy_flutter/models.dart';

import '../utils/log.dart';

class SubscriptionRepository {
  Future<void> getOfferings() async {
    try {
      var offerings = await Glassfy.offerings();
      var offering = offerings.all
          ?.singleWhere((offering) => offering.offeringId == 'kvitter_premium');

      offering?.skus?.forEach((sku) {
        Log.d('sku: ${sku.skuId}');
        Log.d('sku: ${sku.product?.description}');
        Log.d('sku: ${sku.product?.price}');
      });
    } catch (e) {
      Log.e('Error getting offerings: $e');
    }
  }

  Future<void> purchase(GlassfySku skuId) async {
    try {
      var transaction = await Glassfy.purchaseSku(skuId);

      var p = transaction.permissions?.all?.singleWhere((permission) => permission.permissionId == 'kvitter_premium');
      if (p?.isValid==true) {
        // unlock aFeature
      }
      else {
        // lock aFeature
      }

    } catch (e) {
      Log.e('Error purchasing sku: $e');
    }
  }

  Future<bool> isPremiumUser() async {
    try {
      var permission = await Glassfy.permissions();
      return permission.all?.any((permission) => permission.permissionId == 'kvitter_premium') ?? false;
    } catch (e) {
      Log.e('Error getting permissions: $e');
      return false;
    }
  }
}
