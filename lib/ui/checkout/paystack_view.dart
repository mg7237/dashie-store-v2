import 'dart:io';

import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/config/ps_config.dart';
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
import 'package:flutterstore/ui/common/ps_credit_card_form_for_pay_stack.dart';
import 'package:flutterstore/utils/ps_progress_dialog.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import 'package:flutterstore/viewobject/transaction_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PayStackView extends StatefulWidget {
  const PayStackView({
    Key key,
    @required this.basketList,
    @required this.couponDiscount,
    @required this.psValueHolder,
    @required this.transactionSubmitProvider,
    @required this.shippingMethodProvider,
    @required this.shippingCostProvider,
    @required this.userLoginProvider,
    @required this.basketProvider,
    @required this.memoText,
    @required this.payStackKey,
  }) : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final TransactionHeaderProvider transactionSubmitProvider;
  final ShippingMethodProvider shippingMethodProvider;
  final ShippingCostProvider shippingCostProvider;
  final UserProvider userLoginProvider;
  final BasketProvider basketProvider;
  final String memoText;
  final String payStackKey;

  @override
  State<StatefulWidget> createState() {
    return PayStackViewState();
  }
}

final TextEditingController memoController = TextEditingController();

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
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              PsConst.ZERO,
              '',
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              (shippingMethodProvider.selectedShippingName == null)
                  ? shippingMethodProvider.defaultShippingName
                  : shippingMethodProvider.selectedShippingName,
              memoText);

      PsProgressDialog.dismissDialog();

      if (_apiStatus.data != null) {
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

PaymentCard callCard(
  String cardNumber,
  String expiryDate,
  String cardHolderName,
  String cvvCode,
) {
  final List<String> monthAndYear = expiryDate.split('/');
  return PaymentCard(
      number: cardNumber,
      expiryMonth: int.parse(monthAndYear[0]),
      expiryYear: int.parse(monthAndYear[1]),
      name: cardHolderName,
      cvc: cvvCode);
}

class PayStackViewState extends State<PayStackView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final PaystackPlugin plugin = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(publicKey: widget.payStackKey);
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
    dynamic payStackNow(String token) async {
      // widget.basketProvider.checkoutCalculationHelper.calculate(
      //     basketList: widget.basketList,
      //     couponDiscountString: widget.couponDiscount,
      //     psValueHolder: widget.psValueHolder,
      //     shippingPriceStringFormatting:
      //         widget.shippingMethodProvider.defaultShippingPrice
      //         );
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

      await PsProgressDialog.showDialog(context);
      callTransactionSubmitApi(
          context,
          widget.basketProvider,
          widget.userLoginProvider,
          widget.transactionSubmitProvider,
          widget.shippingMethodProvider,
          widget.basketList,
          // progressDialog,
          token,
          widget.couponDiscount,
          widget.memoText);
    }

    return PsWidgetWithAppBarWithNoProvider(
      appBarTitle: Utils.getString(context, 'checkout3__pay_stack'),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  height: 175,
                  width: MediaQuery.of(context).size.width,
                  animationDuration: PsConfig.animation_duration,
                ),
                // PayStackCreditCardWidget(
                //   cardNumber: cardNumber,
                //   expiryDate: expiryDate,
                //   cardHolderName: cardHolderName,
                //   cvvCode: cvvCode,
                // ),
                // PsCreditCardForm(
                //   onCreditCardModelChange: onCreditCardModelChange,
                // ),
                PsCreditCardFormForPayStack(
                  onCreditCardModelChange: onCreditCardModelChange,
                  themeColor: Colors.black,
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: PsDimens.space12, right: PsDimens.space12),
                    child: PSButtonWidget(
                        hasShadow: true,
                        width: double.infinity,
                        titleText: Utils.getString(context, 'credit_card__pay'),
                        onPressed: () async {
                          if (cardNumber.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_number'));
                          } else if (expiryDate.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_date'));
                          } else if (cardHolderName.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(context,
                                    'warning_dialog__input_holder_name'));
                          } else if (cvvCode.isEmpty) {
                            callWarningDialog(
                                context,
                                Utils.getString(
                                    context, 'warning_dialog__input_cvv'));
                          } else {
                            final Charge charge = Charge()
                              ..amount = (double.parse(Utils.getPriceTwoDecimal(
                                          widget
                                              .basketProvider
                                              .checkoutCalculationHelper
                                              .totalPrice
                                              .toString())) *
                                      100)
                                  .round()
                              ..email =
                                  widget.userLoginProvider.user.data.userEmail
                              ..reference = _getReference()
                              ..card = callCard(cardNumber, expiryDate,
                                  cardHolderName, cvvCode);
                            try {
                              final CheckoutResponse response =
                                  await plugin.checkout(
                                context,
                                method: CheckoutMethod.card,
                                charge: charge,
                                fullscreen: false,
                                // logo: MyLogo(),
                              );
                              if (response.status) {
                                payStackNow(response.reference);
                              }
                            } catch (e) {
                              print('Check console for error');
                              rethrow;
                            }
                          }
                        })),
                const SizedBox(height: PsDimens.space40)
              ],
            )),
          ),
        ],
      ),
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
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
