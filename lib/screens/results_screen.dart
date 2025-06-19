// lib/screens/results_screen.dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/positionnement.dart';
import '../services/pathfinding_service.dart';
import '../widgets/trip_card.dart';

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
  // Le Future qui contiendra le résultat de notre recherche asynchrone
  late Future<List<List<Positionnement>>> _journeysFuture;

  @override
  void initState() {
    super.initState();
    // On lance la recherche en arrière-plan avec compute dès l'initialisation de l'écran
    _journeysFuture = compute(
      findJourneysInIsolate,
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1CAF72)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.startStation} > ${widget.endStation}',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<List<Positionnement>>>(
        future: _journeysFuture,
        builder: (context, snapshot) {
          // 1. État de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. État en cas d'erreur
          if (snapshot.hasError) {
            log("Erreur dans le FutureBuilder: ${snapshot.error}");
            return const Center(
              child: Text(
                'Une erreur est survenue lors de la recherche.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          
          // 3. État si aucun résultat n'est trouvé
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun trajet trouvé pour cette sélection.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. Affichage des résultats
          final journeys = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: journeys.length, // Limité à 5 au maximum par l'algorithme 
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