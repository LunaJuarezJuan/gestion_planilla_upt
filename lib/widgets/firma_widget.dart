import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

class FirmaWidget extends StatefulWidget {
  final Function(Uint8List) onFirmaCaptured;
  final String? titulo;

  const FirmaWidget({
    Key? key,
    required this.onFirmaCaptured,
    this.titulo,
  }) : super(key: key);

  @override
  State<FirmaWidget> createState() => _FirmaWidgetState();
}

class _FirmaWidgetState extends State<FirmaWidget> {
  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();
  bool _isSigned = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.titulo != null)
              Text(
                widget.titulo!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SfSignaturePad(
                key: _signatureKey,
                backgroundColor: Colors.white,
                strokeColor: Colors.black,
                minimumStrokeWidth: 1,
                maximumStrokeWidth: 3,
                onDrawStart: () {
                  setState(() {
                    _isSigned = true;
                  });
                  return false;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _limpiarFirma,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSigned ? _guardarFirma : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar Firma'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _limpiarFirma() {
    _signatureKey.currentState?.clear();
    setState(() {
      _isSigned = false;
    });
  }

  Future<void> _guardarFirma() async {
    if (!_isSigned) return;

    try {
      final ui.Image? image = await _signatureKey.currentState?.toImage();
      if (image == null) return;

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List imageBytes = byteData.buffer.asUint8List();
      
      widget.onFirmaCaptured(imageBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firma capturada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar firma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
