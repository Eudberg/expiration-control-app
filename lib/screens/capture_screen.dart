import 'package:flutter/material.dart';

import '../services/barcode_service.dart';
import '../services/image_service.dart';
import '../services/ocr_service.dart';
import 'edit_item_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImageService imageService = ImageService();
  final OcrService ocrService = OcrService();
  final BarcodeService barcodeService = BarcodeService();

  bool loading = false;
  bool finished = false;
  String status = 'Abrindo câmera...';

  @override
  void dispose() {
    ocrService.dispose();
    barcodeService.dispose();
    super.dispose();
  }

  Future<void> _captureAndRead() async {
    if (loading || finished) return;

    setState(() {
      loading = true;
      status = 'Abrindo câmera...';
    });

    final imagePath = await imageService.captureImage();

    if (imagePath == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        status = 'Captura cancelada.';
      });
      Navigator.pop(context);
      return;
    }

    setState(() => status = 'Tentando ler código de barras...');
    final gs1Data = await barcodeService.readGs1FromImage(imagePath);

    setState(() => status = 'Lendo texto da etiqueta...');
    final ocrResult = await ocrService.extractFromImage(imagePath);

    final bestExpiryDate = gs1Data?.expiryDate ?? ocrResult.detectedExpiryDate;
    final expirySource = gs1Data?.expiryDate != null
        ? 'barcode'
        : (ocrResult.detectedExpiryDate != null ? 'ocr' : 'none');

    final extraInfo = [
      'Origem da validade: $expirySource',
      if (gs1Data?.rawValue != null) 'BARCODE: ${gs1Data!.rawValue}',
      if (gs1Data?.gtin != null) 'GTIN: ${gs1Data!.gtin}',
      if (gs1Data?.lot != null) 'LOTE: ${gs1Data!.lot}',
      if (gs1Data?.productionDate != null)
        'FABRICAÇÃO (barcode): ${gs1Data!.productionDate!.day.toString().padLeft(2, '0')}/${gs1Data.productionDate!.month.toString().padLeft(2, '0')}/${gs1Data.productionDate!.year}',
      if (ocrResult.detectedProductionDate != null)
        'FABRICAÇÃO (ocr): ${ocrResult.detectedProductionDate!.day.toString().padLeft(2, '0')}/${ocrResult.detectedProductionDate!.month.toString().padLeft(2, '0')}/${ocrResult.detectedProductionDate!.year}',
      '',
      'OCR:',
      ocrResult.fullText,
    ].join('\n');

    if (!mounted) return;

    setState(() {
      loading = false;
      finished = true;
    });

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditItemScreen(
          imagePath: imagePath,
          detectedText: extraInfo,
          detectedMeatType: ocrResult.detectedMeatType,
          detectedExpiryDate: bestExpiryDate,
          expirySource: expirySource,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureAndRead());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar etiqueta')),
      body: Center(
        child: loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(status, textAlign: TextAlign.center),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(status, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _captureAndRead,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
