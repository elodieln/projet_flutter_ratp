// lib/screens/results_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/positionnement.dart';
import '../services/pathfinding_service.dart';
import '../widgets/trip_card.dart'; // On va bientôt créer ce widget

class ResultsScreen extends StatefulWidget {
  final String startStation;
  final String endStation;

  const ResultsScreen({
    super.key,
    required this.startStation,
    required this.endStation,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Le Future qui contiendra le résultat de notre recherche
  late Future<List<List<Positionnement>>> _journeysFuture;

  @override
  void initState() {
    super.initState();
    // On lance la recherche dès que l'écran est initialisé
    _journeysFuture = findJourneysInIsolate(
      PathfindingParams(
        startStation: widget.startStation,
        endStation: widget.endStation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.startStation} > ${widget.endStation}',
          style: const TextStyle(color: Colors.black, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<List<List<Positionnement>>>(
        future: _journeysFuture,
        builder: (context, snapshot) {
          // État de chargement 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // État en cas d'erreur ou si aucun résultat n'est trouvé 
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucun trajet trouvé.'),
            );
          }

          // Affichage des résultats
          final journeys = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: journeys.length, // Limité à 5 au maximum par la logique de recherche 
            itemBuilder: (context, index) {
              final journey = journeys[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TripCard(journey: journey),
              );
            },
          );
        },
      ),
    );
  }
}