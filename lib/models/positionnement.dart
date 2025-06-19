// lib/models/positionnement.dart

class Positionnement {
  final String? fromType;
  final int? fromId;
  final String? fromName;
  final String? lineId;
  final String? lineName;
  final String? toType;
  final int? toId;
  final String? toName;
  final String? positionAverage;
  final int? position;
  final int? positionMax;
  final String? equipmentType;

  Positionnement({
    this.fromType,
    this.fromId,
    this.fromName,
    this.lineId,
    this.lineName,
    this.toType,
    this.toId,
    this.toName,
    this.positionAverage,
    this.position,
    this.positionMax,
    this.equipmentType,
  });

  factory Positionnement.fromJson(Map<String, dynamic> json) {
    return Positionnement(
      fromType: json['from_type'],
      fromId: json['from_id'],
      fromName: json['from_name'],
      lineId: json['line_id'],
      lineName: json['line_name'],
      toType: json['to_type'],
      toId: json['to_id'],
      toName: json['to_name'],
      positionAverage: json['position_average'],
      position: json['position'],
      positionMax: json['position_max'],
      equipmentType: json['equipment_type'],
    );
  }
}