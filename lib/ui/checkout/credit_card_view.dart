import 'dart:io';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/provider/basket/basket_provider.dart';
import 'package:flutterstore/provider/shipping_cost/shipping_cost_provider.dart';
import 'package:flutterstore/provider/shipping_method/shipping_method_provider.dart';
import 'package:flutterstore/provider/transaction/transaction_header_provider.dart';
import 'package:flutterstore/provider/user/user_provider.dart';
import 'package:flutterstore/ui/common/base/ps_widget_with_appbar_with_no_provider.dart';
import 'package:flutterstore/ui/common/dialog/error_dialog.dart';
import 'package:flutterstore/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterstore/ui/common/ps_button_widget.dart';
import 'package:flutterstore/utils/ps_progress_dialog.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import 'package:flutterstore/viewobject/transaction_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CreditCardView extends StatefulWidget {
  const CreditCardView(
      {Key key,
      @required this.basketList,
      @required this.couponDiscount,
      @required this.psValueHolder,
      @required this.transactionSubmitProvider,
      @required this.userLoginProvider,
      @required this.basketProvider,
      @required this.shippingMethodProvider,
      @required this.shippingCostProvider,
      @required this.memoText,
      @required this.publishKey})
      : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final TransactionHeaderProvider transactionSubmitProvider;
  final UserProvider userLoginProvider;
  final BasketProvider basketProvider;
  final ShippingMethodProvider shippingMethodProvider;
  final ShippingCostProvider shippingCostProvider;
  final String memoText;
  final String publishKey;

  @override
  State<StatefulWidget> createState() {
    return CreditCardViewState();
  }
}

dynamic callTransactionSubmitApi(
    BuildContext context,
    BasketProvider basketProvider,
    UserProvider userLoginProvider,
    TransactionHeaderProvider transactionSubmitProvider,
    ShippingMethodProvider shippingMethodProvider,
    List<Basket> basketList,
    String token,
    String couponDiscount,
    String memoText) async {
  if (await Utils.checkInternetConnectivity()) {
    if (userLoginProvider.user != null && userLoginProvider.user.data != null) {
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userLoginProvider.user.data,
              basketList,
              Platform.isIOS ? token : token,
              couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingTax.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              '',
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              (shippingMethodProvider.selectedShippingName == null)
                  ? shippingMethodProvider.defaultShippingName
                  : shippingMethodProvider.selectedShippingName,
              memoText);

      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider.deleteWholeBasketList();

          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data,
              ));
        } else {
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: _apiStatus.message,
                );
              });
        }
      } else {
        PsProgressDialog.dismissDialog();

        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
      }
    }
  } else {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        });
  }
}


class CreditCardViewState extends State<CreditCardView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  CardFieldInputDetails cardData;

  @override
  void initState() {
    Stripe.publishableKey = widget.publishKey; 
    super.initState();
  }

  void setError(dynamic error) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, error.toString()),
          );
        });
  }

  dynamic callWarningDialog(BuildContext context, String text) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return WarningDialog(
            message: Utils.getString(context, text),
            onPressed: () {},
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dynamic stripeNow(String token) async {
      if (widget.psValueHolder.standardShippingEnable == PsConst.ONE) {
        widget.basketProvider.checkoutCalculationHelper.calculate(
            basketList: widget.basketList,
            couponDiscountString: widget.couponDiscount,
            psValueHolder: widget.psValueHolder,
            shippingPriceStringFormatting:
                widget.shippingMethodProvider.selectedPrice == '0.0'
                    ? widget.shippingMethodProvider.defaultShippingPrice
                    : widget.shippingMethodProvider.selectedPrice ?? '0.0');
      } else if (widget.psValueHolder.zoneShippingEnable == PsConst.ONE) {
        widget.basketProvider.checkoutCalculationHelper.calculate(
            basketList: widget.basketList,
            couponDiscountString: widget.couponDiscount,
            psValueHolder: widget.psValueHolder,
            shippingPriceStringFormatting: widget.shippingCostProvider
                .shippingCost.data.shippingZone.shippingCost);
      }

      callTransactionSubmitApi(
          context,
          widget.basketProvider,
          widget.userLoginProvider,
          widget.transactionSubmitProvider,
          widget.shippingMethodProvider,
          widget.basketList,
          token,
          widget.couponDiscount,
          widget.memoText);
    }

    return PsWidgetWithAppBarWithNoProvider(
      appBarTitle: 'Credit Card',
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(PsDimens.space16),
            child: CardField(
              autofocus: true,
              onCardChanged: (CardFieldInputDetails card) async {
                setState(() {
                  cardData = card;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
                left: PsDimens.space12, right: PsDimens.space12),
            child: PSButtonWidget(
              hasShadow: true,
              width: double.infinity,
              titleText: Utils.getString(context, 'credit_card__pay'),
              onPressed: () async {
                if (cardData != null && cardData.complete) {
                  await PsProgressDialog.showDialog(context);
                  final PaymentMethod paymentMethod = await Stripe.instance
                      .createPaymentMethod(const PaymentMethodParams.card());
                  Utils.psPrint(paymentMethod.id);
                  await stripeNow(paymentMethod.id);
                } else {
                  callWarningDialog(
                      context, Utils.getString(context, 'contact_us__fail'));
                }
              },
            ),
          ),            
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
