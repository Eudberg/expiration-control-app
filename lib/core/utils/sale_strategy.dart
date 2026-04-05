class SaleStrategy {
  static List<String> getSuggestions({
    required int daysToExpire,
    required String meatType,
    required double remainingQuantity,
  }) {
    if (daysToExpire <= 0) {
      return [
        'Retire imediatamente da exposição e revise o lote.',
        'Confirme a data e aplique protocolo interno do açougue.',
      ];
    }

    if (daysToExpire <= 3) {
      return [
        'Coloque em área de maior visibilidade.',
        'Monte oferta relâmpago com destaque visual.',
        'Treine o balconista para sugerir esse corte primeiro.',
        'Crie combo com temperos ou acompanhamentos.',
      ];
    }

    if (daysToExpire <= 7) {
      return [
        'Use etiqueta com destaque de oportunidade.',
        'Reforce exposição na vitrine principal.',
        'Ofereça sugestão de preparo ao cliente.',
        'Agrupe cortes similares em promoção moderada.',
      ];
    }

    if (remainingQuantity > 20) {
      return [
        'Planeje campanha de giro para alto volume.',
        'Divida em porções menores para aumentar saída.',
        'Exponha cortes com melhor margem junto ao item.',
      ];
    }

    return [
      'Manter exposição padrão.',
      'Acompanhar giro diariamente.',
      'Revisar volume restante no fim do turno.',
    ];
  }
}
