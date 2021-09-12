import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/api/ps_api_service.dart';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/db/shipping_city_dao.dart';
import 'package:flutterstore/repository/Common/ps_repository.dart';
import 'package:flutterstore/viewobject/holder/shipping_city_parameter_holder.dart';
import 'package:flutterstore/viewobject/shipping_city.dart';
import 'package:sembast/sembast.dart';

class ShippingCityRepository extends PsRepository {
  ShippingCityRepository(
      {@required PsApiService psApiService,
      @required ShippingCityDao shippingCityDao}) {
    _psApiService = psApiService;
    _shippingCityDao = shippingCityDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  ShippingCityDao _shippingCityDao;

  Future<dynamic> insert(ShippingCity shippingCity) async {
    return _shippingCityDao.insert(primaryKey, shippingCity);
  }

  Future<dynamic> update(ShippingCity shippingCity) async {
    return _shippingCityDao.update(shippingCity);
  }

  Future<dynamic> delete(ShippingCity shippingCity) async {
    return _shippingCityDao.delete(shippingCity);
  }

  Future<dynamic> getAllShippingCityList(
      StreamController<PsResource<List<ShippingCity>>> shippingCityListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      ShippingCityParameterHolder holder,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    final Finder finder =
        Finder(filter: Filter.equals('country_id', holder.countryId));
    shippingCityListStream.sink
        .add(await _shippingCityDao.getAll(finder: finder, status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingCity>> _resource =
          await _psApiService.getCityList(limit, offset, holder.toMap());

      if (_resource.status == PsStatus.SUCCESS) {
        if (isNeedDelete) {
          await _shippingCityDao.deleteAll();
        }
        await _shippingCityDao.insertAll(primaryKey, _resource.data);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          if (isNeedDelete) {
            await _shippingCityDao.deleteAll();
          }
        }
      }
      shippingCityListStream.sink.add(await _shippingCityDao.getAll());
    }
  }

  Future<dynamic> getNextPageShippingCityList(
      StreamController<PsResource<List<ShippingCity>>> shippingCityListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      ShippingCityParameterHolder holder,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    final Finder finder =
        Finder(filter: Filter.equals('country_id', holder.countryId));
    shippingCityListStream.sink
        .add(await _shippingCityDao.getAll(finder: finder, status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingCity>> _resource =
          await _psApiService.getCityList(limit, offset, holder.toMap());

      if (_resource.status == PsStatus.SUCCESS) {
        await _shippingCityDao.insertAll(primaryKey, _resource.data);
      }
      shippingCityListStream.sink.add(await _shippingCityDao.getAll());
    }
  }
}
