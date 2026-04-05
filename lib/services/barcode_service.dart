import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../core/utils/gs1_parser.dart';

class BarcodeService {
  final BarcodeScanner _scanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  Future<Gs1Data?> readGs1FromImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final barcodes = await _scanner.processImage(inputImage);

    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.trim().isEmpty) continue;

      final parsed = Gs1Parser.parse(raw);

      if (parsed.expiryDate != null ||
          parsed.productionDate != null ||
          parsed.gtin != null) {
        return parsed;
      }
    }

    return null;
  }

  void dispose() {
    _scanner.close();
  }
}
