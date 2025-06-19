// lib/screens/results_screen.dart
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
  late Future<List<List<Positionnement>>> _journeysFuture;

  @override
  void initState() {
    super.initState();
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun trajet trouvé pour cette sélection.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final journeys = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: journeys.length,
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