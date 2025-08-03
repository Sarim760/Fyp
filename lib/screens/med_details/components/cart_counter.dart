import 'package:flutter/material.dart';

import '../../../helper/constants.dart';


class CartCounter extends StatefulWidget {
  const CartCounter({super.key});

  // Public static method to access quantity
  static int get quantity => _CartCounterState.quantity;

  @override
  State<CartCounter> createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  int numOfItems = 1;
  
  // Make the quantity accessible outside the widget
  static int get quantity => _CartCounterState._instance?.numOfItems ?? 1;
  static _CartCounterState? _instance;
  
  @override
  void initState() {
    super.initState();
    _instance = this;
  }
  
  @override
  void dispose() {
    if (_instance == this) {
      _instance = null;
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () {
              setState(() {
                if (numOfItems > 1) {
                  numOfItems--;
                }
              });
            },
            child: const Icon(Icons.remove),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 2),
          child: Text(
            // if our item is less than 10 then it shows 01 02 like that
            numOfItems.toString().padLeft(2, "0"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          width: 40,
          height: 32,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () {
              setState(() {
                numOfItems++;
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
