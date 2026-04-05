import 'package:flutter/material.dart';
import '../core/utils/date_utils.dart';
import '../data/models/meat_item.dart';

class MeatItemCard extends StatelessWidget {
  final MeatItem item;
  final VoidCallback onTap;

  const MeatItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = ExpiryHelper.daysToExpire(item.expiryDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(item.meatType),
        subtitle: Text(
          'Validade: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}\n'
          'Restante: ${item.remainingQuantity} ${item.unit}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Icon(Icons.schedule), Text('$days d')],
        ),
      ),
    );
  }
}
