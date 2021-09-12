import 'dart:async';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/db/shipping_method_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/api/ps_api_service.dart';
import 'package:flutterstore/viewobject/shipping_method.dart';

import 'Common/ps_repository.dart';

class ShippingMethodRepository extends PsRepository {
  ShippingMethodRepository(
      {@required PsApiService psApiService,
      @required ShippingMethodDao shippingMethodDao}) {
    _psApiService = psApiService;
    _shippingMethodDao = shippingMethodDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  ShippingMethodDao _shippingMethodDao;

  Future<dynamic> insert(ShippingMethod shippingMethod) async {
    return _shippingMethodDao.insert(primaryKey, shippingMethod);
  }

  Future<dynamic> update(ShippingMethod shippingMethod) async {
    return _shippingMethodDao.update(shippingMethod);
  }

  Future<dynamic> delete(ShippingMethod shippingMethod) async {
    return _shippingMethodDao.delete(shippingMethod);
  }

  Future<dynamic> getAllShippingMethod(
      StreamController<PsResource<List<ShippingMethod>>> shippingMethodStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    shippingMethodStream.sink
        .add(await _shippingMethodDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingMethod>> _resource =
          await _psApiService.getShippingMethod();

      if (_resource.status == PsStatus.SUCCESS) {
        await _shippingMethodDao.deleteAll();
        await _shippingMethodDao.insertAll(primaryKey, _resource.data);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _shippingMethodDao.deleteAll();
        }
      }
      shippingMethodStream.sink.add(await _shippingMethodDao.getAll());
    }
  }
}
