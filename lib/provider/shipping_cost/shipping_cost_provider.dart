import 'dart:async';
import 'package:flutterstore/repository/shipping_cost_repository.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/provider/common/ps_provider.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/shipping_cost.dart';

class ShippingCostProvider extends PsProvider {
  ShippingCostProvider(
      {@required ShippingCostRepository repo,
      this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    print('ShippingCost Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
    shippingMethodListStream =
        StreamController<PsResource<ShippingCost>>.broadcast();
    subscription = shippingMethodListStream.stream
        .listen((PsResource<ShippingCost> resource) {
      _shippingCost = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  ShippingCostRepository _repo;
  PsValueHolder psValueHolder;

  StreamSubscription<PsResource<ShippingCost>> subscription;
  StreamController<PsResource<ShippingCost>> shippingMethodListStream;

  PsResource<ShippingCost> _shippingCost =
      PsResource<ShippingCost>(PsStatus.NOACTION, '', null);
  PsResource<ShippingCost> get shippingCost => _shippingCost;
  @override
  void dispose() {
    subscription.cancel();
    shippingMethodListStream.close();
    isDispose = true;
    print('ShippingMethod Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> postZoneShippingMethod(
    String countryId,
    String cityId,
    String shopId,
    List<Basket> basketList,
  ) async {
    final List<Map<String, dynamic>> produtListJson = <Map<String, dynamic>>[];
    for (int i = 0; i < basketList.length; i++) {
      final ProductListMap carJson = ProductListMap(basketList[i].productId, basketList[i].qty);
      produtListJson.add(carJson.tojsonData());
    }

    final ShippingCostMap shippingCostMap = ShippingCostMap(
      countryId: countryId,
      cityId: cityId,
      shopId: shopId,
      products: produtListJson,
    );

    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _shippingCost = await _repo.postZoneShippingMethod(shippingCostMap.toMap(),
        isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _shippingCost;
  }
}

class ProductListMap {
  ProductListMap(
    this.productId,
    this.qty,
  );
  String productId, qty;
  Map<String, dynamic> tojsonData() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['product_id'] = productId;
    map['qty'] = qty;
    return map;
  }
}

class ShippingCostMap {
  ShippingCostMap({this.countryId, this.cityId, this.shopId, this.products});

  String countryId;
  String cityId;
  String shopId;
  List<Map<String, dynamic>> products;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['country_id'] = countryId;
    map['city_id'] = cityId;
    map['shop_id'] = shopId;
    map['products'] = products;
    return map;
  }
}
