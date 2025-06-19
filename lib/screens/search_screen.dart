// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projet_ratp/services/pathfinding_service.dart';
import 'package:projet_ratp/screens/results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _startStationController = TextEditingController();
  final TextEditingController _endStationController = TextEditingController();
  final PathfindingService _pathfindingService = PathfindingService();
  
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _startStationController.addListener(_validateFields);
    _endStationController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      _isButtonEnabled = _startStationController.text.isNotEmpty && _endStationController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _startStationController.dispose();
    _endStationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un itinéraire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // NOUVEAU: Utilisation de TypeAheadField pour l'auto-complétion
            TypeAheadField<String>(
              suggestionsCallback: (pattern) async {
                return await _pathfindingService.getStationSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                _startStationController.text = suggestion;
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: _startStationController,
                decoration: const InputDecoration(
                  labelText: 'Départ',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TypeAheadField<String>(
              suggestionsCallback: (pattern) async {
                return await _pathfindingService.getStationSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                _endStationController.text = suggestion;
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: _endStationController,
                decoration: const InputDecoration(
                  labelText: 'Arrivée',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              // CHANGEMENT: Activation/Désactivation dynamique du bouton
              onPressed: _isButtonEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsScreen(
                            startStation: _startStationController.text,
                            endStation: _endStationController.text,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}