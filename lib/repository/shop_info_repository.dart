import 'dart:async';

import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/db/shop_info_dao.dart';
import 'package:flutterstore/viewobject/shop_info.dart';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/api/ps_api_service.dart';
import 'Common/ps_repository.dart';

class ShopInfoRepository extends PsRepository {
  ShopInfoRepository(
      {@required PsApiService psApiService,
      @required ShopInfoDao shopInfoDao}) {
    _psApiService = psApiService;
    _shopInfoDao = shopInfoDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  ShopInfoDao _shopInfoDao;

  Future<dynamic> insert(ShopInfo shopInfo) async {
    return _shopInfoDao.insert(primaryKey, shopInfo);
  }

  Future<dynamic> update(ShopInfo shopInfo) async {
    return _shopInfoDao.update(shopInfo);
  }

  Future<dynamic> delete(ShopInfo shopInfo) async {
    return _shopInfoDao.delete(shopInfo);
  }

  Future<dynamic> getShopInfo(
      StreamController<PsResource<ShopInfo>> shopInfoListStream,
      bool isConnectedToInternet,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    shopInfoListStream.sink.add(await _shopInfoDao.getOne(status: status));

    if (isConnectedToInternet) {
      final PsResource<ShopInfo> _resource = await _psApiService.getShopInfo();

      if (_resource.status == PsStatus.SUCCESS) {
        await _shopInfoDao.deleteAll();
        await _shopInfoDao.insert(primaryKey, _resource.data);
      } else {
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _shopInfoDao.deleteAll();
        }
      }
      shopInfoListStream.sink.add(await _shopInfoDao.getOne());
    }
  }
}
