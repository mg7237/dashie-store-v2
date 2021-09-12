import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/provider/basket/basket_provider.dart';
import 'package:flutterstore/provider/coupon_discount/coupon_discount_provider.dart';
import 'package:flutterstore/provider/shipping_cost/shipping_cost_provider.dart';
import 'package:flutterstore/provider/shipping_method/shipping_method_provider.dart';
import 'package:flutterstore/provider/user/user_provider.dart';
import 'package:flutterstore/repository/basket_repository.dart';
import 'package:flutterstore/repository/coupon_discount_repository.dart';
import 'package:flutterstore/repository/shipping_cost_repository.dart';
import 'package:flutterstore/repository/shipping_method_repository.dart';
import 'package:flutterstore/repository/transaction_header_repository.dart';
import 'package:flutterstore/repository/user_repository.dart';
import 'package:flutterstore/ui/checkout/shipping_method_item_view.dart';
import 'package:flutterstore/ui/common/dialog/error_dialog.dart';
import 'package:flutterstore/ui/common/dialog/success_dialog.dart';
import 'package:flutterstore/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterstore/ui/common/ps_textfield_widget.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/coupon_discount.dart';
import 'package:flutterstore/viewobject/holder/coupon_discount_holder.dart';
import 'package:provider/provider.dart';

class Checkout2View extends StatefulWidget {
  const Checkout2View({
    Key key,
    @required this.updateCheckout2ViewState,
    @required this.basketList,
    @required this.publishKey,
  }) : super(key: key);

  final List<Basket> basketList;
  final Function updateCheckout2ViewState;
  final String publishKey;
  @override
  _Checkout2ViewState createState() {
    final _Checkout2ViewState _state = _Checkout2ViewState();
    updateCheckout2ViewState(_state);
    return _state;
  }
}

class _Checkout2ViewState extends State<Checkout2View> {
  final TextEditingController couponController = TextEditingController();
  CouponDiscountRepository couponDiscountRepo;
  TransactionHeaderRepository transactionHeaderRepo;
  BasketRepository basketRepository;
  ShippingCostRepository shippingCostRepository;
  ShippingMethodRepository shippingMethodRepository;
  UserRepository userRepository;
  PsValueHolder valueHolder;
  ShippingMethodProvider shippingMethodProvider;
  CouponDiscountProvider couponDiscountProvider;
  ShippingCostProvider shippingCostProvider;
  UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    shippingCostRepository = Provider.of<ShippingCostRepository>(context);
    shippingMethodRepository = Provider.of<ShippingMethodRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);

    valueHolder = Provider.of<PsValueHolder>(context);
    shippingMethodProvider = Provider.of<ShippingMethodProvider>(context);
    userRepository = Provider.of<UserRepository>(context);

    return Consumer<ShippingMethodProvider>(builder: (BuildContext context,
        ShippingMethodProvider shippingMethodProvider, Widget child) {
      couponDiscountProvider = Provider.of<CouponDiscountProvider>(context,
          listen: false); // Listen : False is important.
      shippingCostProvider = Provider.of<ShippingCostProvider>(context,
          listen: false); // Listen : False is important.

      final BasketProvider basketProvider =
          Provider.of<BasketProvider>(context);
      userProvider = Provider.of<UserProvider>(context);
      if (shippingMethodProvider.psValueHolder.zoneShippingEnable ==
              PsConst.ONE &&
          userProvider.user.data != null) {
        shippingCostProvider.postZoneShippingMethod(
            userProvider.user.data.country.id,
            userProvider.user.data.city.id,
            userProvider.psValueHolder.shopId,
            widget.basketList);
      }

      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (shippingMethodProvider.psValueHolder.standardShippingEnable ==
                PsConst.ONE)
              Container(
                color: PsColors.backgroundColor,
                padding: const EdgeInsets.only(
                  left: PsDimens.space12,
                  right: PsDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: PsDimens.space16,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: PsDimens.space16, right: PsDimens.space16),
                      child: Text(
                        Utils.getString(context, 'checkout2__shipping_method'),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    const SizedBox(
                      height: PsDimens.space16,
                    ),
                    const Divider(
                      height: 2,
                    ),
                    const SizedBox(
                      height: PsDimens.space16,
                    ),
                    Container(
                      height: PsDimens.space140,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: shippingMethodProvider
                              .shippingMethodList.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ShippingMethodItemView(
                              shippingMethod: shippingMethodProvider
                                  .shippingMethodList.data[index],
                              shippingMethodProvider: shippingMethodProvider,
                              onShippingMethodTap: () {
                                setState(() {
                                  shippingMethodProvider
                                          .selectedShippingMethod =
                                      shippingMethodProvider
                                          .shippingMethodList.data[index];
                                  shippingMethodProvider.selectedPrice =
                                      shippingMethodProvider
                                          .shippingMethodList.data[index].price;
                                  shippingMethodProvider.selectedShippingName =
                                      shippingMethodProvider
                                          .shippingMethodList.data[index].name;
                                });
                                basketProvider
                                    .checkoutCalculationHelper
                                    .calculate(
                                        psValueHolder: valueHolder,
                                        basketList: widget.basketList,
                                        couponDiscountString:
                                            couponDiscountProvider
                                                    .couponDiscount ??
                                                '-',
                                        shippingPriceStringFormatting:
                                            shippingMethodProvider
                                                        .selectedPrice ==
                                                    '0.0'
                                                ? shippingMethodProvider
                                                    .defaultShippingPrice
                                                : shippingMethodProvider
                                                        .selectedPrice ??
                                                    '0.0');
                              },
                            );
                          }),
                    ),
                    const SizedBox(
                      height: PsDimens.space24,
                    ),
                  ],
                ),
              )
            else if (shippingMethodProvider.psValueHolder.noShippingEnable ==
                PsConst.ONE)
              Container()
            else
              Container(),
            Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              padding: const EdgeInsets.only(
                left: PsDimens.space12,
                right: PsDimens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space16, right: PsDimens.space16),
                    child: Text(
                      Utils.getString(
                          context, 'transaction_detail__coupon_discount'),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: PsTextFieldWidget(
                        hintText:
                            Utils.getString(context, 'checkout__coupon_code'),
                        textEditingController: couponController,
                        showTitle: false,
                      )),
                      Container(
                        margin: const EdgeInsets.only(right: PsDimens.space8),
                        child: MaterialButton(
                          color: PsColors.mainColor,
                          shape: const BeveledRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(7.0)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(MaterialCommunityIcons.ticket_percent,
                                  color: PsColors.white),
                              const SizedBox(
                                width: PsDimens.space4,
                              ),
                              Text(
                                Utils.getString(
                                    context, 'checkout__claim_button_name'),
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: PsColors.white),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            if (couponController.text.isNotEmpty) {
                              final CouponDiscountParameterHolder
                                  couponDiscountParameterHolder =
                                  CouponDiscountParameterHolder(
                                couponCode: couponController.text,
                              );

                              final PsResource<CouponDiscount> _apiStatus =
                                  await couponDiscountProvider
                                      .postCouponDiscount(
                                          couponDiscountParameterHolder
                                              .toMap());

                              if (_apiStatus.data != null &&
                                  couponController.text ==
                                      _apiStatus.data.couponCode) {
                                final BasketProvider basketProvider =
                                    Provider.of<BasketProvider>(context,
                                        listen: false);

                                if (valueHolder.standardShippingEnable ==
                                    PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data.couponAmount,
                                          psValueHolder: valueHolder,
                                          shippingPriceStringFormatting:
                                              shippingMethodProvider
                                                          .selectedPrice ==
                                                      '0.0'
                                                  ? shippingMethodProvider
                                                      .defaultShippingPrice
                                                  : shippingMethodProvider
                                                          .selectedPrice ??
                                                      '0.0');
                                } else if (valueHolder.zoneShippingEnable ==
                                    PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data.couponAmount,
                                          psValueHolder: valueHolder,
                                          shippingPriceStringFormatting:
                                              shippingCostProvider
                                                  .shippingCost
                                                  .data
                                                  .shippingZone
                                                  .shippingCost);
                                } else if (valueHolder.noShippingEnable ==
                                    PsConst.ONE) {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data.couponAmount,
                                          psValueHolder: valueHolder,
                                          shippingPriceStringFormatting: '0.0');
                                } else {
                                  basketProvider.checkoutCalculationHelper
                                      .calculate(
                                          basketList: widget.basketList,
                                          couponDiscountString:
                                              _apiStatus.data.couponAmount,
                                          psValueHolder: valueHolder,
                                          shippingPriceStringFormatting: '0.0');
                                }

                                showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SuccessDialog(
                                        message: Utils.getString(context,
                                            'checkout__couponcode_add_dialog_message'),
                                      );
                                    });

                                couponController.clear();
                                print(_apiStatus.data.couponAmount);
                                setState(() {
                                  couponDiscountProvider.couponDiscount =
                                      _apiStatus.data.couponAmount;
                                });
                              } else {
                                showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        message: _apiStatus.message,
                                      );
                                    });
                              }
                            } else {
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                      message: Utils.getString(context,
                                          'checkout__warning_dialog_message'),
                                      onPressed: (){},
                                    );
                                  });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space16, right: PsDimens.space16),
                    child: Text(
                        Utils.getString(context, 'checkout__description'),
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                  const SizedBox(
                    height: PsDimens.space16,
                  ),
                ],
              ),
            ),
            _OrderSummaryWidget(
              psValueHolder: valueHolder,
              basketList: widget.basketList,
              couponDiscount: couponDiscountProvider.couponDiscount ?? '-',
              shippingMethodProvider: shippingMethodProvider,
              basketProvider: basketProvider,
              shippingCostProvider: shippingCostProvider,
            ),
          ],
        ),
      );
    });
  }
}

class _OrderSummaryWidget extends StatelessWidget {
  const _OrderSummaryWidget({
    Key key,
    @required this.basketList,
    @required this.couponDiscount,
    @required this.psValueHolder,
    @required this.shippingMethodProvider,
    @required this.basketProvider,
    @required this.shippingCostProvider,
  }) : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final ShippingMethodProvider shippingMethodProvider;
  final BasketProvider basketProvider;
  final ShippingCostProvider shippingCostProvider;
  @override
  Widget build(BuildContext context) {
    String currencySymbol;

    if (basketList.isNotEmpty) {
      currencySymbol = basketList[0].product.currencySymbol;
    }
    if (shippingMethodProvider.psValueHolder.standardShippingEnable ==
        PsConst.ONE) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: basketList,
          couponDiscountString: couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting:
              shippingMethodProvider.selectedPrice == '0.0'
                  ? shippingMethodProvider.defaultShippingPrice
                  : shippingMethodProvider.selectedPrice ?? '0.0');
    } else if (shippingMethodProvider.psValueHolder.zoneShippingEnable ==
            PsConst.ONE &&
        shippingCostProvider.shippingCost.data != null &&
        shippingCostProvider.shippingCost.data.shippingZone != null) {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: basketList,
          couponDiscountString: couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: shippingCostProvider
                  .shippingCost.data.shippingZone.shippingCost ??
              '0.0');
      shippingMethodProvider.selectedPrice =
          shippingCostProvider.shippingCost.data.shippingZone.shippingCost;
      shippingMethodProvider.selectedShippingName = shippingCostProvider
          .shippingCost.data.shippingZone.shippingZonePackageName;
    } else {
      basketProvider.checkoutCalculationHelper.calculate(
          basketList: basketList,
          couponDiscountString: couponDiscount,
          psValueHolder: psValueHolder,
          shippingPriceStringFormatting: '0.0');
    }

    const Widget _dividerWidget = Divider(
      height: PsDimens.space2,
    );

    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space12,
    );

    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                Utils.getString(context, 'checkout__order_summary'),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText: basketProvider
                  .checkoutCalculationHelper.totalItemCount
                  .toString(),
              title:
                  '${Utils.getString(context, 'checkout__total_item_count')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '${basketList[0].product.currencySymbol} ${basketProvider.checkoutCalculationHelper.totalOriginalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__total_item_price')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.totalDiscountFormattedString}',
              title: '${Utils.getString(context, 'checkout__discount')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText: couponDiscount == '-'
                  ? '-'
                  : '$currencySymbol ${basketProvider.checkoutCalculationHelper.couponDiscountFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__coupon_discount')} :',
            ),
            _spacingWidget,
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText: basketProvider
                  .checkoutCalculationHelper.subTotalPriceFormattedString
                  .toString(),
              title: '${Utils.getString(context, 'checkout__sub_total')} :',
            ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.taxFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__tax')} (${psValueHolder.overAllTaxLabel} %) :',
            ),
            if (shippingCostProvider.shippingCost.data != null &&
                shippingCostProvider.shippingCost.data.shippingZone != null &&
                shippingCostProvider
                        .shippingCost.data.shippingZone.shippingCost !=
                    null)
              _OrderSummeryTextWidget(
                transationInfoText:
                    '$currencySymbol ${double.parse(shippingCostProvider.shippingCost.data.shippingZone.shippingCost)}',
                title:
                    '${Utils.getString(context, 'checkout__shipping_cost')} :',
              )
            else
              _OrderSummeryTextWidget(
                transationInfoText: shippingMethodProvider.selectedPrice ==
                        '0.0'
                    ? '$currencySymbol ${Utils.getPriceFormat(shippingMethodProvider.defaultShippingPrice)}'
                    : '$currencySymbol ${Utils.getPriceFormat(shippingMethodProvider.selectedPrice)}',
                title:
                    '${Utils.getString(context, 'checkout__shipping_cost')} :',
              ),
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.shippingTaxFormattedString}',
              title:
                  '${Utils.getString(context, 'checkout__shipping_tax')} (${psValueHolder.shippingTaxLabel} %) :',
            ),
            _spacingWidget,
            _dividerWidget,
            _OrderSummeryTextWidget(
              transationInfoText:
                  '$currencySymbol ${basketProvider.checkoutCalculationHelper.totalPriceFormattedString}',
              title:
                  '${Utils.getString(context, 'transaction_detail__total')} :',
            ),
            _spacingWidget,
          ],
        ));
  }
}

class _OrderSummeryTextWidget extends StatelessWidget {
  const _OrderSummeryTextWidget({
    Key key,
    @required this.transationInfoText,
    this.title,
  }) : super(key: key);

  final String transationInfoText;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
          top: PsDimens.space12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.normal),
          ),
          Text(
            transationInfoText ?? '-',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}
