import 'package:flutter/material.dart';

import '../../../model/medicine.dart';
import 'cart_counter.dart';

class CounterWithFavBtn extends StatefulWidget {
  final medicine product;
  
  const CounterWithFavBtn({super.key, required this.product});

  @override
  State<CounterWithFavBtn> createState() => _CounterWithFavBtnState();
}

class _CounterWithFavBtnState extends State<CounterWithFavBtn> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const CartCounter(),
      ],
    );
  }
}
