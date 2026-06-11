import 'package:flutter/material.dart';

class FeatureMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const FeatureMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
