import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {

  final String routeName;
  final double distance;
  final int time;
  final String traffic;
  final String emoji;
  final bool recommended;

  const RouteCard({
    super.key,
    required this.routeName,
    required this.distance,
    required this.time,
    required this.traffic,
    required this.emoji,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: ListTile(

        title: Text(

          recommended
              ? "⭐ $routeName"
              : routeName,

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        subtitle: Text(

          "$distance km\n"
              "$time mins\n"
              "$emoji $traffic",

        ),

      ),
    );
  }
}