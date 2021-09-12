import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/api/ps_api_service.dart';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/db/shipping_country_dao.dart';
import 'package:flutterstore/viewobject/holder/shipping_country_parameter_holder.dart';
import 'package:flutterstore/viewobject/shipping_country.dart';

import 'Common/ps_repository.dart';

class ShippingCountryRepository extends PsRepository {
  ShippingCountryRepository(
      {@required PsApiService psApiService,
      @required ShippingCountryDao shippingCountryDao}) {
    _psApiService = psApiService;
    _shippingCountryDao = shippingCountryDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  ShippingCountryDao _shippingCountryDao;

  Future<dynamic> insert(ShippingCountry shippingCountry) async {
    return _shippingCountryDao.insert(primaryKey, shippingCountry);
  }

  Future<dynamic> update(ShippingCountry shippingCountry) async {
    return _shippingCountryDao.update(shippingCountry);
  }

  Future<dynamic> delete(ShippingCountry shippingCountry) async {
    return _shippingCountryDao.delete(shippingCountry);
  }

  Future<dynamic> getAllShippingCountryList(
      StreamController<PsResource<List<ShippingCountry>>>
          shippingCountryListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      ShippingCountryParameterHolder holder,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    shippingCountryListStream.sink
        .add(await _shippingCountryDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingCountry>> _resource =
          await _psApiService.getCountryList(limit, offset, holder.toMap());

      if (_resource.status == PsStatus.SUCCESS) {
        if (isNeedDelete) {
          await _shippingCountryDao.deleteAll();
        }
        await _shippingCountryDao.insertAll(primaryKey, _resource.data);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          if (isNeedDelete) {
            await _shippingCountryDao.deleteAll();
          }
        }
      }
      shippingCountryListStream.sink.add(await _shippingCountryDao.getAll());
    }
  }

  Future<dynamic> getNextPageShippingCountryList(
      StreamController<PsResource<List<ShippingCountry>>>
          shippingCountryListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      ShippingCountryParameterHolder holder,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    shippingCountryListStream.sink
        .add(await _shippingCountryDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingCountry>> _resource =
          await _psApiService.getCountryList(limit, offset, holder.toMap());

      if (_resource.status == PsStatus.SUCCESS) {
        await _shippingCountryDao.insertAll(primaryKey, _resource.data);
      }
      shippingCountryListStream.sink.add(await _shippingCountryDao.getAll());
    }
  }
}
