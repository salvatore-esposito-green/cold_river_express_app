import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cold_river_express_app/models/box_summary.dart';

class PdfService {
  Future<Uint8List> generateDeliveryNotePdf(List<BoxSummary> summaries) async {
    final double totalVolume = summaries.fold(
      0,
      (acc, item) => acc + item.volume,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text(
                'Delivery Note',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                cellAlignment: pw.Alignment.center,
                data: <List<String>>[
                  <String>['Number', 'Box Size', 'Volume'],
                  ...summaries.map(
                    (summary) => [
                      'N. ${summary.count}',
                      summary.boxSize,
                      '${summary.volume.toStringAsFixed(3)} m³',
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Tot. Box.s ',
                    style: pw.TextStyle(fontSize: 18),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '${summaries.fold(0, (total, summary) => total + summary.count)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Tot. Vol. (m³) ',
                    style: pw.TextStyle(fontSize: 18),
                    textAlign: pw.TextAlign.right,
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    totalVolume.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<bool> previewDeliveryNotePdf(List<BoxSummary> summaries) async {
    final Uint8List pdfData = await generateDeliveryNotePdf(summaries);

    return await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  Future<bool> shareDeliveryNotePdf(List<BoxSummary> summaries) async {
    final Uint8List pdfData = await generateDeliveryNotePdf(summaries);

    return await Printing.sharePdf(
      bytes: pdfData,
      filename: 'delivery_note.pdf',
    );
  }
}
