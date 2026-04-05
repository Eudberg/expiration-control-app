import 'package:flutter/material.dart';

import '../core/utils/date_utils.dart';
import '../data/models/meat_item.dart';
import '../data/repositories/meat_item_repository.dart';
import '../services/notification_service.dart';

class EditItemScreen extends StatefulWidget {
  final String imagePath;
  final String detectedText;
  final String detectedMeatType;
  final DateTime? detectedExpiryDate;
  final String expirySource;

  const EditItemScreen({
    super.key,
    required this.imagePath,
    required this.detectedText,
    required this.detectedMeatType,
    required this.detectedExpiryDate,
    required this.expirySource,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final repository = MeatItemRepository();

  late TextEditingController meatTypeController;
  late TextEditingController expiryController;
  final quantityController = TextEditingController(text: '1');
  final remainingController = TextEditingController(text: '1');
  final notesController = TextEditingController();

  String unit = 'kg';
  bool saving = false;
  bool saved = false;
  bool expandDetectedText = true;

  @override
  void initState() {
    super.initState();
    meatTypeController = TextEditingController(text: widget.detectedMeatType);
    expiryController = TextEditingController(
      text: widget.detectedExpiryDate == null
          ? ''
          : '${widget.detectedExpiryDate!.day.toString().padLeft(2, '0')}/${widget.detectedExpiryDate!.month.toString().padLeft(2, '0')}/${widget.detectedExpiryDate!.year}',
    );
  }

  @override
  void dispose() {
    meatTypeController.dispose();
    expiryController.dispose();
    quantityController.dispose();
    remainingController.dispose();
    notesController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (saving || saved) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final expiryDate = _parseDate(expiryController.text)!;
    final remaining =
        double.tryParse(remainingController.text.replaceAll(',', '.')) ?? 0;

    final item = MeatItem(
      meatType: meatTypeController.text.trim(),
      expiryDate: expiryDate,
      createdAt: DateTime.now(),
      initialQuantity:
          double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0,
      remainingQuantity: remaining,
      unit: unit,
      imagePath: widget.imagePath,
      ocrText: widget.detectedText,
      status: ExpiryHelper.statusFromDate(expiryDate, remaining),
      notes: notesController.text.trim(),
    );

    try {
      final alreadyExists = await repository.existsSimilarItem(
        meatType: item.meatType,
        expiryDate: item.expiryDate,
        imagePath: item.imagePath,
      );

      if (alreadyExists) {
        if (!mounted) return;
        setState(() => saving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este item já foi salvo anteriormente.'),
          ),
        );
        return;
      }

      final id = await repository.insert(item);

      await NotificationService.instance.scheduleExpiryAlert(
        id: id,
        meatType: item.meatType,
        expiryDate: item.expiryDate,
      );

      if (!mounted) return;

      setState(() {
        saving = false;
        saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso.')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  String _expiryMessage() {
    switch (widget.expirySource) {
      case 'barcode':
        return 'A validade foi lida do código de barras.';
      case 'ocr':
        return 'A validade foi lida por OCR. Confira antes de salvar.';
      default:
        return 'A validade não foi identificada automaticamente. Preencha manualmente.';
    }
  }

  Color _expiryMessageColor(BuildContext context) {
    switch (widget.expirySource) {
      case 'barcode':
        return Colors.green.shade100;
      case 'ocr':
        return Colors.amber.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar dados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: meatTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de carne'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o tipo de carne'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: expiryController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Validade (dd/mm/aaaa)',
                ),
                validator: (value) =>
                    _parseDate(value ?? '') == null ? 'Data inválida' : null,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _expiryMessageColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_expiryMessage()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantidade inicial',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: remainingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantidade restante',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: unit,
                decoration: const InputDecoration(labelText: 'Unidade'),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'un', child: Text('un')),
                  DropdownMenuItem(value: 'cx', child: Text('caixa')),
                ],
                onChanged: (value) => setState(() => unit = value ?? 'kg'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                initiallyExpanded: expandDetectedText,
                onExpansionChanged: (value) {
                  setState(() => expandDetectedText = value);
                },
                title: const Text('Texto lido da etiqueta'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(widget.detectedText),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving || saved ? null : _save,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(saved ? 'Salvo' : 'Salvar produto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
