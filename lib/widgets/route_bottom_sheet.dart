import 'package:flutter/material.dart';

class RouteBottomSheet extends StatelessWidget {
  final double distance;
  final int duration;
  final VoidCallback onStart;

  const RouteBottomSheet({
    super.key,
    required this.distance,
    required this.duration,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "⭐ StreetFlow Smart",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "${distance.toStringAsFixed(1)} km",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "$duration min",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                child: const Text("Start Navigation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}