class Gs1Data {
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final String? lot;
  final String? gtin;
  final String rawValue;

  Gs1Data({
    required this.rawValue,
    this.expiryDate,
    this.productionDate,
    this.lot,
    this.gtin,
  });
}

class Gs1Parser {
  static Gs1Data parse(String raw) {
    final normalized = raw.replaceAll(' ', '');

    String? gtin;
    DateTime? expiryDate;
    DateTime? productionDate;
    String? lot;

    final ai01 = RegExp(r'\(01\)(\d{14})').firstMatch(normalized);
    if (ai01 != null) {
      gtin = ai01.group(1);
    }

    final ai15 = RegExp(r'\(15\)(\d{6})').firstMatch(normalized);
    if (ai15 != null) {
      expiryDate = _parseGs1Date(ai15.group(1)!);
    }

    final ai17 = RegExp(r'\(17\)(\d{6})').firstMatch(normalized);
    if (ai17 != null) {
      expiryDate ??= _parseGs1Date(ai17.group(1)!);
    }

    final ai11 = RegExp(r'\(11\)(\d{6})').firstMatch(normalized);
    if (ai11 != null) {
      productionDate = _parseGs1Date(ai11.group(1)!);
    }

    final ai10 = RegExp(r'\(10\)([A-Za-z0-9\\-]+)').firstMatch(normalized);
    if (ai10 != null) {
      lot = ai10.group(1);
    }

    return Gs1Data(
      rawValue: raw,
      gtin: gtin,
      expiryDate: expiryDate,
      productionDate: productionDate,
      lot: lot,
    );
  }

  static DateTime? _parseGs1Date(String yymmdd) {
    if (yymmdd.length != 6) return null;

    final year = 2000 + int.parse(yymmdd.substring(0, 2));
    final month = int.parse(yymmdd.substring(2, 4));
    final day = int.parse(yymmdd.substring(4, 6));

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
