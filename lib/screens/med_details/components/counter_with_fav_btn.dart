import 'package:flutter/material.dart';

import '../../../model/medicine.dart';
import '../../../widgets/favorite_button.dart';
import 'cart_counter.dart';

class CounterWithFavBtn extends StatelessWidget {
  final medicine product;
  
  const CounterWithFavBtn({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const CartCounter(),
        FavoriteButton(
          product: product,
        )
      ],
    );
  }
}
