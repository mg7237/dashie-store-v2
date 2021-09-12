import 'dart:async';
import 'package:flutterstore/repository/contact_us_repository.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/api_status.dart';
import 'package:flutter/material.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/provider/common/ps_provider.dart';

class ContactUsProvider extends PsProvider {
  ContactUsProvider({@required ContactUsRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('ContactUs Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }

  ContactUsRepository _repo;

  PsResource<ApiStatus> _contactUs =
      PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get user => _contactUs;

  @override
  void dispose() {
    isDispose = true;
    print('ContactUs Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> postContactUs(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _contactUs = await _repo.postContactUs(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _contactUs;
  }
}
