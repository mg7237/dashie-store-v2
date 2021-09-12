import 'package:flutter/material.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/provider/shipping_method/shipping_method_provider.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/shipping_method.dart';

class ShippingMethodItemView extends StatelessWidget {
  const ShippingMethodItemView({
    Key key,
    @required this.shippingMethod,
    @required this.shippingMethodProvider,
    this.onShippingMethodTap(),
  }) : super(key: key);

  final Function onShippingMethodTap;
  final ShippingMethod shippingMethod;
  final ShippingMethodProvider shippingMethodProvider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShippingMethodTap,
      child: Container(
          margin: const EdgeInsets.only(left: 5),
          child: checkIsSelected(shippingMethod, context)),
    );
  }

  Widget checkIsSelected(ShippingMethod shippingMethod, BuildContext context) {
    if (shippingMethodProvider.selectedShippingMethod == null &&
        shippingMethodProvider.psValueHolder.shippingId == shippingMethod.id) {
      return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.mainColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space12,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                    '${shippingMethod.currencySymbol}${shippingMethod.price}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: PsColors.white)),
              ),
              const SizedBox(
                height: PsDimens.space20,
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(shippingMethod.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: PsColors.white)),
                ),
              ),
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                child: Text(
                    '${shippingMethod.days}  ' +
                        Utils.getString(context, 'checkout2__days'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: PsColors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (shippingMethodProvider.selectedShippingMethod != null &&
        shippingMethod != null &&
        shippingMethodProvider.selectedShippingMethod.id == shippingMethod.id &&
        shippingMethodProvider.selectedShippingMethod.id.isNotEmpty) {
      return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.mainColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space12,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                    '${shippingMethod.currencySymbol}${shippingMethod.price}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: PsColors.white)),
              ),
              const SizedBox(
                height: PsDimens.space20,
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(shippingMethod.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: PsColors.white)),
                ),
              ),
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                child: Text(
                    '${shippingMethod.days}  ' +
                        Utils.getString(context, 'checkout2__days'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: PsColors.white)),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: PsDimens.space140,
        child: Container(
          decoration: BoxDecoration(
            color: PsColors.coreBackgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(PsDimens.space8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: PsDimens.space12,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                    '${shippingMethod.currencySymbol}${shippingMethod.price}',
                    style: Theme.of(context).textTheme.headline5),
              ),
              const SizedBox(
                height: PsDimens.space20,
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(shippingMethod.name,
                      style: Theme.of(context).textTheme.bodyText2),
                ),
              ),
              const SizedBox(
                height: PsDimens.space4,
              ),
              Container(
                child: Text(
                    '${shippingMethod.days}  ' +
                        Utils.getString(context, 'checkout2__days'),
                    style: Theme.of(context).textTheme.subtitle1),
              ),
            ],
          ),
        ),
      );
    }
  }
}
