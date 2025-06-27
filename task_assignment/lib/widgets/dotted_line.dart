import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.maxWidth;
          const dashWidth = 5.0;
          const dashSpace = 3.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade400,
              );
            }),
          );
        },
      ),
    );
  }
}
