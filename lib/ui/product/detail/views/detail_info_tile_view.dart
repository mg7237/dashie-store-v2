import 'package:flutter/material.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/provider/product/product_provider.dart';
import 'package:flutterstore/ui/common/ps_expansion_tile.dart';
import 'package:flutterstore/ui/product/detail/views/color_list_item_view.dart';
import 'package:flutterstore/ui/product/specification/product_specification_list_item.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/product.dart';

class DetailInfoTileView extends StatelessWidget {
  const DetailInfoTileView({
    Key key,
    @required this.productDetail,
  }) : super(key: key);

  final ProductDetailProvider productDetail;

  @override
  Widget build(BuildContext context) {
    final Widget _expansionTileTitleWidget = Text(
        Utils.getString(context, 'detail_info_tile__detail_info'),
        style: Theme.of(context).textTheme.subtitle1);
    if (productDetail != null &&
        productDetail.productDetail != null &&
        productDetail.productDetail.data != null) {
      return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space12,
            right: PsDimens.space12,
            bottom: PsDimens.space12),
        decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: PsExpansionTile(
          initiallyExpanded: true,
          title: _expansionTileTitleWidget,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  bottom: PsDimens.space16,
                  left: PsDimens.space16,
                  right: PsDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    Utils.getString(context, 'detail_info_tile__product_name'),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: PsDimens.space12,
                        left: PsDimens.space12,
                        bottom: PsDimens.space12),
                    child: Text(
                      productDetail.productDetail.data.name ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: PsColors.mainColor),
                    ),
                  ),
                  if (productDetail.productDetail.data.productUnit != '')
                    Text(
                      Utils.getString(
                          context, 'detail_info_tile__product_unit'),
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.productUnit != '')
                    Padding(
                      padding: const EdgeInsets.only(
                          top: PsDimens.space12,
                          left: PsDimens.space12,
                          bottom: PsDimens.space12),
                      child: Text(
                        productDetail.productDetail.data.productUnit ?? '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.productMeasurement != '')
                    Text(
                      Utils.getString(
                          context, 'detail_info_tile__product_measurement'),
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.productMeasurement != '')
                    Padding(
                      padding: const EdgeInsets.only(
                          top: PsDimens.space12,
                          left: PsDimens.space12,
                          bottom: PsDimens.space12),
                      child: Text(
                        productDetail.productDetail.data.productMeasurement ??
                            '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.minimumOrder != '0')
                    Text(
                      Utils.getString(context, 'detail_info_tile__mim_order'),
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.minimumOrder != '0')
                    Padding(
                      padding: const EdgeInsets.only(
                          top: PsDimens.space12, left: PsDimens.space12),
                      child: Text(
                        productDetail.productDetail.data.minimumOrder ?? '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )
                  else
                    Container(),
                  if (productDetail.productDetail.data.minimumOrder != '0')
                    const SizedBox(
                      height: PsDimens.space16,
                    )
                  else
                    Container(),
                  _ColorsWidget(product: productDetail.productDetail.data),
                  _ProductSpecificationWidget(
                      product: productDetail.productDetail.data),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return const Card();
    }
  }
}

class _ColorsWidget extends StatefulWidget {
  const _ColorsWidget({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Product product;
  @override
  __ColorsWidgetState createState() => __ColorsWidgetState();
}

class __ColorsWidgetState extends State<_ColorsWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.product.itemColorList.isNotEmpty &&
        widget.product.itemColorList[0].id != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space4,
          ),
          Text(
            Utils.getString(context, 'product_detail__available_color'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(
            height: PsDimens.space4,
          ),
          Container(
            height: 50,
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.product.itemColorList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ColorListItemView(
                        color: widget.product.itemColorList[index],
                        selectedColorId: '',
                        onColorTap: () {},
                      );
                    })),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

class _ProductSpecificationWidget extends StatefulWidget {
  const _ProductSpecificationWidget({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Product product;
  @override
  __ProductSpecificationWidgetState createState() =>
      __ProductSpecificationWidgetState();
}

class __ProductSpecificationWidgetState
    extends State<_ProductSpecificationWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.product.itemSpecList.isNotEmpty &&
        widget.product.itemSpecList[0].id != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space20,
          ),
          Text(
            Utils.getString(context, 'detail_info_tile__detail_info'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.product.itemSpecList.length,
            itemBuilder: (BuildContext context, int index) {
              return ProductSpecificationListItem(
                productSpecification: widget.product.itemSpecList[index],
              );
            },
          ),
          const SizedBox(
            height: PsDimens.space4,
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
