class MeatItem {
  final int? id;
  final String meatType;
  final DateTime expiryDate;
  final DateTime createdAt;
  final double initialQuantity;
  final double remainingQuantity;
  final String unit;
  final String imagePath;
  final String ocrText;
  final String status;
  final String notes;

  MeatItem({
    this.id,
    required this.meatType,
    required this.expiryDate,
    required this.createdAt,
    required this.initialQuantity,
    required this.remainingQuantity,
    required this.unit,
    required this.imagePath,
    required this.ocrText,
    required this.status,
    required this.notes,
  });

  MeatItem copyWith({
    int? id,
    String? meatType,
    DateTime? expiryDate,
    DateTime? createdAt,
    double? initialQuantity,
    double? remainingQuantity,
    String? unit,
    String? imagePath,
    String? ocrText,
    String? status,
    String? notes,
  }) {
    return MeatItem(
      id: id ?? this.id,
      meatType: meatType ?? this.meatType,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      ocrText: ocrText ?? this.ocrText,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meatType': meatType,
      'expiryDate': expiryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'initialQuantity': initialQuantity,
      'remainingQuantity': remainingQuantity,
      'unit': unit,
      'imagePath': imagePath,
      'ocrText': ocrText,
      'status': status,
      'notes': notes,
    };
  }

  factory MeatItem.fromMap(Map<String, dynamic> map) {
    return MeatItem(
      id: map['id'] as int?,
      meatType: map['meatType'] as String,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      initialQuantity: (map['initialQuantity'] as num).toDouble(),
      remainingQuantity: (map['remainingQuantity'] as num).toDouble(),
      unit: map['unit'] as String,
      imagePath: map['imagePath'] as String,
      ocrText: map['ocrText'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String,
    );
  }
}
