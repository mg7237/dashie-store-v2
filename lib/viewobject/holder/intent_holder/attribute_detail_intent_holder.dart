import 'package:flutter/material.dart';
import 'package:flutterstore/viewobject/AttributeDetail.dart';
import 'package:flutterstore/viewobject/product.dart';

class AttributeDetailIntentHolder {
  const AttributeDetailIntentHolder({
    @required this.product,
    @required this.attributeDetail,
  });
  final Product product;
  final List<AttributeDetail> attributeDetail;
}
