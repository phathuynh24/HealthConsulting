import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HalfCircle extends StatelessWidget {
  double height;
  double weight;
  bool isLeft;
  Color color;

  HalfCircle(
      {super.key,
      required this.height,
      required this.weight,
      required this.color,
      required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: weight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 0 : 100),
          bottomLeft: Radius.circular(isLeft ? 0 : 100),
          topRight: Radius.circular(isLeft ? 100 : 0),
          bottomRight: Radius.circular(isLeft ? 100 : 0),
        ),
      ),
    );
  }
}
