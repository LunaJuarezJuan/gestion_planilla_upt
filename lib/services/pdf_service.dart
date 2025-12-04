import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/planilla.dart';
import '../models/detalle_planilla.dart';
import '../models/planilla_estado.dart';
import '../models/user_role.dart';
import 'package:intl/intl.dart';

class PDFService {
  final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: 'S/. ',
    decimalDigits: 2,
  );

  Future<Uint8List> generarPDFPlanilla(Planilla planilla) async {
    final pdf = pw.Document();

    // Cargar fuente (opcional, puedes usar la fuente por defecto)
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          _buildEncabezado(planilla, fontBold),
          pw.SizedBox(height: 20),

          // Información general
          _buildInfoGeneral(planilla),
          pw.SizedBox(height: 20),

          // Tabla de detalles
          _buildTablaDetalles(planilla.detalles),
          pw.SizedBox(height: 20),

          // Resumen total
          _buildResumenTotal(planilla),
          pw.SizedBox(height: 30),

          // Firmas
          _buildSeccionFirmas(planilla),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildEncabezado(Planilla planilla, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PLANILLA DE PAGOS',
          style: pw.TextStyle(
            fontSize: 24,
            font: fontBold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Text(
          'Periodo: ${planilla.mes}',
          style: const pw.TextStyle(fontSize: 16),
        ),
        pw.Text(
          'Fecha de generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildInfoGeneral(Planilla planilla) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Total Empleados: ${planilla.cantidadEmpleados}'),
              pw.Text('Estado: ${planilla.estado.displayName}'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Monto Total:'),
              pw.Text(
                currencyFormat.format(planilla.montoTotal),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTablaDetalles(List<DetallePlanilla> detalles) {
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blue900,
      ),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      headers: [
        'Empleado',
        'Horas',
        'Salario Base',
        'Deducciones',
        'Bonif.',
        'Neto a Pagar'
      ],
      data: detalles.map((detalle) => [
        detalle.nombreEmpleado,
        detalle.horasTrabajadas.toString(),
        currencyFormat.format(detalle.salarioBase),
        currencyFormat.format(detalle.totalDeducciones),
        currencyFormat.format(detalle.totalBonificaciones),
        currencyFormat.format(detalle.netoAPagar),
      ]).toList(),
    );
  }

  pw.Widget _buildResumenTotal(Planilla planilla) {
    final totalHoras = planilla.detalles.fold(0, (sum, d) => sum + d.horasTrabajadas);
    final totalDeducciones = planilla.detalles.fold(0.0, (sum, d) => sum + d.totalDeducciones);
    final totalBonificaciones = planilla.detalles.fold(0.0, (sum, d) => sum + d.totalBonificaciones);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue900, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'RESUMEN GENERAL',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Divider(),
          _buildResumenLinea('Total Horas Trabajadas:', totalHoras.toString()),
          _buildResumenLinea('Total Deducciones:', currencyFormat.format(totalDeducciones)),
          _buildResumenLinea('Total Bonificaciones:', currencyFormat.format(totalBonificaciones)),
          pw.Divider(),
          _buildResumenLinea(
            'TOTAL NETO A PAGAR:',
            currencyFormat.format(planilla.montoTotal),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildResumenLinea(String titulo, String valor, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
          pw.Text(
            valor,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? PdfColors.green900 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSeccionFirmas(Planilla planilla) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FIRMAS DE AUTORIZACIÓN',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 20,
          runSpacing: 20,
          children: planilla.firmas.entries.map((entry) {
            final firma = entry.value;
            return pw.Container(
              width: 200,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    firma.rolUsuario.displayName,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    firma.nombreUsuario,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(firma.fechaFirma),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                  if (firma.comentarios != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Comentario: ${firma.comentarios}',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Método para previsualizar el PDF
  Future<void> previsualizarPDF(Planilla planilla) async {
    final pdfBytes = await generarPDFPlanilla(planilla);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Método para imprimir el PDF
  Future<void> imprimirPDF(Planilla planilla) async {
    final pdfBytes = await generarPDFPlanilla(planilla);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
