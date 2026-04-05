import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String fullText;
  final String detectedMeatType;
  final DateTime? detectedExpiryDate;
  final DateTime? detectedProductionDate;

  OcrResult({
    required this.fullText,
    required this.detectedMeatType,
    required this.detectedExpiryDate,
    required this.detectedProductionDate,
  });
}

class OcrService {
  final TextRecognizer textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<OcrResult> extractFromImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizedText = await textRecognizer.processImage(inputImage);

    final fullText = recognizedText.text;
    final detectedMeatType = _detectMeatType(recognizedText);
    final detectedProductionDate = _detectProductionDate(recognizedText);
    final detectedExpiryDate = _detectExpiryDate(
      recognizedText,
      productionDate: detectedProductionDate,
    );

    return OcrResult(
      fullText: fullText,
      detectedMeatType: detectedMeatType,
      detectedExpiryDate: detectedExpiryDate,
      detectedProductionDate: detectedProductionDate,
    );
  }

  String _detectMeatType(RecognizedText recognizedText) {
    final text = recognizedText.text.toLowerCase();

    final knownCuts = <String, List<String>>{
      'Patinho': ['patinho'],
      'Picanha': ['picanha'],
      'Alcatra': ['alcatra'],
      'Contra-filé': [
        'contra filé',
        'contrafile',
        'contra-file',
        'contra file',
      ],
      'Costela': ['costela'],
      'Acém': ['acem', 'acém'],
      'Fraldinha': ['fraldinha'],
      'Maminha': ['maminha'],
      'Coxão mole': ['coxao mole', 'coxão mole'],
      'Coxão duro': ['coxao duro', 'coxão duro'],
      'Lagarto': ['lagarto'],
      'Frango': ['frango'],
      'Linguiça': ['linguica', 'linguiça'],
      'Suíno': ['suino', 'suíno', 'porco'],
    };

    for (final entry in knownCuts.entries) {
      for (final alias in entry.value) {
        if (text.contains(alias)) {
          return entry.key;
        }
      }
    }

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final lineText = line.text.trim();
        if (lineText.isEmpty) continue;

        if (_looksLikeMeatType(lineText)) {
          return _normalizeMeatType(lineText);
        }
      }
    }

    return 'Carne não identificada';
  }

  bool _looksLikeMeatType(String text) {
    final t = text.toLowerCase();

    return t.contains('patinho') ||
        t.contains('picanha') ||
        t.contains('alcatra') ||
        t.contains('costela') ||
        t.contains('fraldinha') ||
        t.contains('maminha') ||
        t.contains('lagarto') ||
        t.contains('frango') ||
        t.contains('linguiça') ||
        t.contains('linguica') ||
        t.contains('suino') ||
        t.contains('suíno') ||
        t.contains('contra filé') ||
        t.contains('contrafile') ||
        t.contains('coxao mole') ||
        t.contains('coxão mole') ||
        t.contains('coxao duro') ||
        t.contains('coxão duro');
  }

  String _normalizeMeatType(String text) {
    final t = text.toLowerCase();

    if (t.contains('patinho')) return 'Patinho';
    if (t.contains('picanha')) return 'Picanha';
    if (t.contains('alcatra')) return 'Alcatra';
    if (t.contains('costela')) return 'Costela';
    if (t.contains('fraldinha')) return 'Fraldinha';
    if (t.contains('maminha')) return 'Maminha';
    if (t.contains('lagarto')) return 'Lagarto';
    if (t.contains('frango')) return 'Frango';
    if (t.contains('linguiça') || t.contains('linguica')) return 'Linguiça';
    if (t.contains('suino') || t.contains('suíno') || t.contains('porco')) {
      return 'Suíno';
    }
    if (t.contains('contra filé') || t.contains('contrafile')) {
      return 'Contra-filé';
    }
    if (t.contains('coxao mole') || t.contains('coxão mole')) {
      return 'Coxão mole';
    }
    if (t.contains('coxao duro') || t.contains('coxão duro')) {
      return 'Coxão duro';
    }

    return text.trim();
  }

  DateTime? _detectProductionDate(RecognizedText recognizedText) {
    final dateRegex = RegExp(r'(\d{2})[\/\-.](\d{2})[\/\-.](\d{2,4})');

    DateTime? bestCandidate;
    int bestScore = -999;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final original = line.text;
        final text = original.toLowerCase();

        final match = dateRegex.firstMatch(original);
        if (match == null) continue;

        final date = _buildDate(match);
        if (date == null) continue;

        int score = 0;

        if (text.contains('data de produção')) score += 120;
        if (text.contains('data de producao')) score += 120;
        if (text.contains('produção')) score += 100;
        if (text.contains('producao')) score += 100;
        if (text.contains('lote')) score += 20;

        if (text.contains('validade')) score -= 120;
        if (text.contains('venc')) score -= 100;

        if (score > bestScore) {
          bestScore = score;
          bestCandidate = date;
        }
      }
    }

    if (bestCandidate != null && bestScore >= 60) {
      return bestCandidate;
    }

    return null;
  }

  DateTime? _detectExpiryDate(
    RecognizedText recognizedText, {
    DateTime? productionDate,
  }) {
    final dateRegex = RegExp(r'(\d{2})[\/\-.](\d{2})[\/\-.](\d{2,4})');

    DateTime? bestCandidate;
    int bestScore = -999;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final original = line.text;
        final text = original.toLowerCase();

        final matches = dateRegex.allMatches(original).toList();
        if (matches.isEmpty) continue;

        for (final match in matches) {
          final date = _buildDate(match);
          if (date == null) continue;

          int score = 0;

          if (text.contains('data validade')) score += 140;
          if (text.contains('validade')) score += 120;
          if (text.contains('venc')) score += 100;

          if (text.contains('produção')) score -= 140;
          if (text.contains('producao')) score -= 140;
          if (text.contains('data de produção')) score -= 160;
          if (text.contains('data de producao')) score -= 160;
          if (text.contains('embalagem')) score -= 80;
          if (text.contains('congelamento')) score -= 80;
          if (text.contains('lote')) score -= 20;

          if (productionDate != null && _sameDate(date, productionDate)) {
            score -= 150;
          }

          if (bestCandidate != null && date.isAfter(bestCandidate)) {
            score += 10;
          }

          if (score > bestScore) {
            bestScore = score;
            bestCandidate = date;
          }
        }
      }
    }

    if (bestCandidate != null && bestScore >= 60) {
      return bestCandidate;
    }

    for (final block in recognizedText.blocks) {
      for (int i = 0; i < block.lines.length; i++) {
        final current = block.lines[i].text.toLowerCase();

        if (current.contains('data validade') ||
            current.contains('validade') ||
            current.contains('venc')) {
          if (i + 1 < block.lines.length) {
            final nextLine = block.lines[i + 1].text;
            final nextMatch = dateRegex.firstMatch(nextLine);
            if (nextMatch != null) {
              final nextDate = _buildDate(nextMatch);
              if (nextDate != null &&
                  (productionDate == null ||
                      !_sameDate(nextDate, productionDate))) {
                return nextDate;
              }
            }
          }
        }
      }
    }

    final candidates = <DateTime>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.toLowerCase();

        if (text.contains('produção') ||
            text.contains('producao') ||
            text.contains('embalagem') ||
            text.contains('congelamento')) {
          continue;
        }

        final matches = dateRegex.allMatches(line.text);
        for (final match in matches) {
          final parsed = _buildDate(match);
          if (parsed == null) continue;
          if (productionDate != null && _sameDate(parsed, productionDate)) {
            continue;
          }
          candidates.add(parsed);
        }
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort();
      return candidates.last;
    }

    return null;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _buildDate(RegExpMatch match) {
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    var year = int.tryParse(match.group(3)!);

    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
