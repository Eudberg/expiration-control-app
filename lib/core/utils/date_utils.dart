class ExpiryHelper {
  static int daysToExpire(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return target.difference(today).inDays;
  }

  static String statusFromDate(DateTime expiryDate, double remainingQuantity) {
    if (remainingQuantity <= 0) return 'esgotado';
    if (daysToExpire(expiryDate) < 0) return 'vencido';
    return 'ativo';
  }
}
