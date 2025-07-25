import 'package:flutter/material.dart';

import '../../../helper/constants.dart';
import '../../../model/medicine.dart';

class Description extends StatefulWidget {
  const Description({super.key, required this.product});

  final medicine product;

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Determine if we need a "Show more" link
    final showToggle = widget.product.description.length > 140;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.description,
            style: const TextStyle(height: 1.5),
            maxLines: _isExpanded ? null : 5,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (showToggle)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
