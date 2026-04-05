import 'dart:io';
import 'package:flutter/material.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/sale_strategy.dart';
import '../data/models/meat_item.dart';
import '../data/repositories/meat_item_repository.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final repository = MeatItemRepository();
  MeatItem? item;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    item = await repository.getById(widget.itemId);
    setState(() => loading = false);
  }

  Future<void> _markEmpty() async {
    if (item == null) return;
    final updated = item!.copyWith(remainingQuantity: 0, status: 'esgotado');
    await repository.update(updated);
    await _load();
  }

  Future<void> _updateRemaining() async {
    if (item == null) return;

    final controller = TextEditingController(
      text: item!.remainingQuantity.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar quantidade restante'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade restante'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );
                Navigator.pop(context, value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final updated = item!.copyWith(
      remainingQuantity: result,
      status: ExpiryHelper.statusFromDate(item!.expiryDate, result),
    );

    await repository.update(updated);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item não encontrado.')));
    }

    final days = ExpiryHelper.daysToExpire(item!.expiryDate);
    final suggestions = SaleStrategy.getSuggestions(
      daysToExpire: days,
      meatType: item!.meatType,
      remainingQuantity: item!.remainingQuantity,
    );

    return Scaffold(
      appBar: AppBar(title: Text(item!.meatType)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item!.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item!.imagePath),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Validade: ${item!.expiryDate.day}/${item!.expiryDate.month}/${item!.expiryDate.year}',
            ),
            Text('Dias para vencer: $days'),
            Text(
              'Quantidade restante: ${item!.remainingQuantity} ${item!.unit}',
            ),
            Text('Status: ${item!.status}'),
            const SizedBox(height: 16),
            const Text(
              'Estratégias sugeridas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(s)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Texto OCR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(item!.ocrText),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateRemaining,
                    child: const Text('Atualizar restante'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _markEmpty,
                    child: const Text('Marcar esgotado'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
