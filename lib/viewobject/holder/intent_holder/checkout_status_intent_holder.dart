import 'package:flutter/cupertino.dart';
import 'package:flutterstore/viewobject/transaction_header.dart';

class CheckoutStatusIntentHolder {
  const CheckoutStatusIntentHolder({
    @required this.transactionHeader,
  });

  final TransactionHeader transactionHeader;
}
