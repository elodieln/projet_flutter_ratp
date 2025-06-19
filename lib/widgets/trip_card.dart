// lib/widgets/trip_card.dart
import 'package:flutter/material.dart';
import '../models/positionnement.dart';

class TripCard extends StatelessWidget {
  final List<Positionnement> journey;

  const TripCard({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: List.generate(journey.length, (index) {
            final segment = journey[index];
            final bool isLastSegment = index == journey.length - 1;
            return _buildLegWidget(context, segment, isLastSegment);
          }),
        ),
      ),
    );
  }

  Widget _buildLegWidget(BuildContext context, Positionnement segment, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 12, color: Colors.grey[400]),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.fromName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Métro Ligne ${segment.lineName}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  _buildPositionIndicator(segment.positionAverage),
                  const SizedBox(height: 12),
                   if (isLast) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 18),
                          Text(
                            segment.toName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      )
                   ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionIndicator(String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.train_outlined, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            position,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[800], fontSize: 12),
          ),
        ],
      ),
    );
  }
}