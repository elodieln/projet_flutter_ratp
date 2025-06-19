// lib/screens/search_screen.dart
import 'package:projet_ratp/screens/results_screen.dart';
import 'package:flutter/material.dart';
import '../services/data_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DataService _dataService = DataService();
  String? _startStation;
  String? _endStation;

  bool get isSearchButtonEnabled =>
      _startStation != null && _endStation != null && _startStation != _endStation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Nouveau trajet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildAutocompleteField(
                label: 'STATION DE DÉPART',
                hint: 'Ex : Gare Saint-Lazare',
                onSelected: (station) {
                  setState(() {
                    _startStation = station;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildAutocompleteField(
                label: 'STATION D\'ARRIVÉE',
                hint: 'Ex : République',
                onSelected: (station) {
                  setState(() {
                    _endStation = station;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isSearchButtonEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultsScreen(
                              startStation: _startStation!,
                              endStation: _endStation!,
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
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required String hint,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _dataService.stationNames.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: onSelected,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.trip_origin),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 250,
                      maxWidth: MediaQuery.of(context).size.width - 40),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}