import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorPopularCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final int count;
  final String expert;
  final String workplace;
  final double rating;

  const DoctorPopularCardWidget({
    super.key,
    required this.image,
    required this.name,
    required this.count,
    required this.workplace,
    required this.expert,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 115,
            width: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(image, fit: BoxFit.cover, errorBuilder:
                  (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      FontAwesomeIcons.userDoctor,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            height: 80,
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 5,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 4,
                ),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.video,
                      color: Themes.gradientDeepClr.withOpacity(0.8),
                      size: 10,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      count.toInt().toString(),
                      style: const TextStyle(
                          color: Colors.black, fontSize: 11, height: 1.5),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      FontAwesomeIcons.solidStar,
                      color: Themes.gradientDeepClr.withOpacity(0.8),
                      size: 10,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      rating.toInt().toString(),
                      style: const TextStyle(
                          color: Colors.black, fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  workplace,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              expert,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 11,
                  color: Themes.gradientDeepClr,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'Tư vấn trực tuyến',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
