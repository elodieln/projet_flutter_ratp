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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(journey.length, (index) {
            final segment = journey[index];
            // Affiche une ligne de connexion sauf pour le dernier élément
            final bool isLastSegment = index == journey.length - 1;
            return _buildLegWidget(context, segment, isLastSegment);
          }),
        ),
      ),
    );
  }

  // Construit la vue pour un seul tronçon (une ligne de métro)
  Widget _buildLegWidget(BuildContext context, Positionnement segment, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // La ligne verticale et l'icône
          SizedBox(
            width: 40,
            child: Column(
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
          // Les informations du tronçon
          Expanded(
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
                const SizedBox(height: 16),
                _buildPositionIndicator(segment.positionAverage),
                const SizedBox(height: 24),
                if (isLast)
                   Text(
                     segment.toName,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Le petit indicateur de position dans la rame
  Widget _buildPositionIndicator(String position) {
    IconData iconData;
    String label;

    switch (position) {
      case 'Avant':
        iconData = Icons.arrow_upward;
        label = 'Avant';
        break;
      case 'Milieu':
        iconData = Icons.swap_horiz;
        label = 'Milieu';
        break;
      case 'Arrière':
        iconData = Icons.arrow_downward;
        label = 'Arrière';
        break;
      default:
        iconData = Icons.help_outline;
        label = 'N/A';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.train, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}