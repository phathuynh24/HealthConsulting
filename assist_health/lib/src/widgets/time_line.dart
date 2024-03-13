import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLine extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  const TimeLine({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        alignment: TimelineAlign.center,
        // gap between events
        isFirst: isFirst,
        isLast: isLast,
        // decorate the lines
        beforeLineStyle: const LineStyle(
          thickness: 10,
          color: Themes.primaryColor,
        ),
        // decorate the icon
        indicatorStyle: IndicatorStyle(
          width: 30,
          height: 30,
          color: Themes.primaryColor,
          iconStyle: IconStyle(
            iconData: Icons.done,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
