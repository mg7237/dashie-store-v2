import 'package:flutterstore/config/ps_config.dart';

import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/provider/productcollection/product_collection_provider.dart';
import 'package:flutterstore/repository/product_collection_repository.dart';
import 'package:flutterstore/ui/collection/item/collection_header_list_item.dart';
import 'package:flutterstore/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterstore/ui/common/ps_ui_widget.dart';
import 'package:flutterstore/ui/product/collection_product/product_list_by_collection_id_view.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionHeaderListView extends StatefulWidget {
  const CollectionHeaderListView({Key key, @required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  State<StatefulWidget> createState() => _CollectionHeaderListItem();
}

class _CollectionHeaderListItem extends State<CollectionHeaderListView> {
  final ScrollController _scrollController = ScrollController();
  ProductCollectionProvider _productCollectionProvider;
  ProductCollectionRepository productCollectionRepository;
  PsValueHolder psValueHolder;
  dynamic data;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _productCollectionProvider.nextProductCollectionList();
      }
    });

    super.initState();
  }

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    productCollectionRepository =
        Provider.of<ProductCollectionRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }

    return ChangeNotifierProvider<ProductCollectionProvider>(
      lazy: false,
      create: (BuildContext context) {
        final ProductCollectionProvider provider =
            ProductCollectionProvider(repo: productCollectionRepository);
        provider.loadProductCollectionList();
        _productCollectionProvider = provider;
        return _productCollectionProvider;
      },
      child: Consumer<ProductCollectionProvider>(builder: (BuildContext context,
          ProductCollectionProvider provider, Widget child) {
        return Column(
          children: <Widget>[
            const PsAdMobBannerWidget(),
            // Visibility(
            //   visible: PsConfig.showAdMob &&
            //       isSuccessfullyLoaded &&
            //       isConnectedToInternet,
            //   child: AdmobBanner(
            //     adUnitId: Utils.getBannerAdUnitId(),
            //     adSize: AdmobBannerSize.FULL_BANNER,
            //     listener: (AdmobAdEvent event, Map<String, dynamic> map) {
            //       print('BannerAd event is $event');
            //       if (event == AdmobAdEvent.loaded) {
            //         isSuccessfullyLoaded = true;
            //       } else {
            //         isSuccessfullyLoaded = false;
            //         setState(() {});
            //       }
            //     },
            //   ),
            // ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: RefreshIndicator(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: provider.productCollectionList.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (provider.productCollectionList.data != null ||
                                provider.productCollectionList.data.isEmpty) {
                              final int count =
                                  provider.productCollectionList.data.length;
                              return CollectionHeaderListItem(
                                animationController: widget.animationController,
                                animation:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: widget.animationController,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                                  ),
                                ),
                                productCollectionHeader:
                                    provider.productCollectionList.data[index],
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      RoutePaths.productListByCollectionId,
                                      arguments: ProductListByCollectionIdView(
                                        productCollectionHeader: provider
                                            .productCollectionList.data[index],
                                        appBarTitle: provider
                                            .productCollectionList
                                            .data[index]
                                            .name,
                                      ));
                                },
                              );
                            } else {
                              return null;
                            }
                          }),
                      onRefresh: () {
                        return provider.resetProductCollectionList();
                      },
                    ),
                  ),
                  PSProgressIndicator(provider.productCollectionList.status)
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
