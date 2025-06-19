// lib/models/positionnement.dart
class Positionnement {
  final String fromName;
  final String lineName;
  final String toName;
  final String positionAverage;
  final int position;
  final int positionMax;

  Positionnement({
    required this.fromName,
    required this.lineName,
    required this.toName,
    required this.positionAverage,
    required this.position,
    required this.positionMax,
  });

  factory Positionnement.fromJson(Map<String, dynamic> json) {
    return Positionnement(
      fromName: json['from_name'] ?? 'N/A',
      lineName: json['line_name'] ?? 'N/A',
      toName: json['to_name'] ?? 'N/A',
      positionAverage: json['position_average'] ?? 'N/A',
      position: json['position'] ?? 0,
      positionMax: json['position_max'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'Ligne $lineName: $fromName -> $toName ($positionAverage)';
  }
}