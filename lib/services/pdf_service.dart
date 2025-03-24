import 'dart:typed_data';
import 'package:cold_river_express_app/models/environment_group.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cold_river_express_app/models/box_summary.dart';

class PdfService {
  Future<Uint8List> generateDeliveryNotePdf(
    List<BoxSummary> summaries,
    List<EnvironmentGroup> groupedByEnvironment,
  ) async {
    final double totalVolume = summaries.fold(
      0,
      (acc, item) => acc + item.volume,
    );
    final Map<String, double> subTotalVolumes = {};

    groupedByEnvironment.forEach((environmentGroup) {
      final environment = environmentGroup.environment;
      final boxes = environmentGroup.summary;

      subTotalVolumes[environment] = boxes.fold(
        0,
        (acc, box) => acc + box.volume,
      );
    });

    final pdf = pw.Document(
      version: PdfVersion.pdf_1_5,
      compress: true,
      pageMode: PdfPageMode.outlines,
      title: 'Delivery Note',
      author: 'Cold River Express',
      subject: 'Delivery Note',
      keywords: 'delivery, note, cold river express',
      creator: 'Cold River Express App',
      producer: 'Cold River Express App',
    );

    const int itemsPerPage = 25;
    List<List<BoxSummary>> chunks = [];
    for (var i = 0; i < summaries.length; i += itemsPerPage) {
      chunks.add(
        summaries.sublist(
          i,
          i + itemsPerPage > summaries.length
              ? summaries.length
              : i + itemsPerPage,
        ),
      );
    }

    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];

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
                    ...chunk.map(
                      (summary) => [
                        'N. ${summary.count}',
                        summary.boxSize,
                        '${summary.volume.toStringAsFixed(3)} m³',
                      ],
                    ),
                  ],
                ),
                if (i == chunks.length - 1)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
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
                  ),
              ],
            );
          },
        ),
      );
    }

    groupedByEnvironment.forEach((group) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Column(
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
                  pw.Text(
                    'Packages grouped by environment',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    group.environment,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                  pw.SizedBox(height: 20),
                  pw.TableHelper.fromTextArray(
                    cellAlignment: pw.Alignment.center,
                    data: <List<String>>[
                      <String>['Number', 'Box Size', 'Volume'],
                      ...group.summary.map(
                        (summary) => [
                          'N. ${summary.count}',
                          summary.boxSize,
                          '${summary.volume.toStringAsFixed(3)} m³',
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
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
                        '${group.summary.fold(0, (total, summary) => total + summary.count)}',
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
                        subTotalVolumes[group.environment]?.toStringAsFixed(
                              2,
                            ) ??
                            '0.00',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        group.numbers.map((number) {
                          return pw.Container(
                            width: 61,
                            height: 61,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 1),
                            ),
                            child: pw.Text(
                              number,
                              style: pw.TextStyle(
                                fontSize: 28,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ];
          },
        ),
      );
    });

    return pdf.save();
  }

  Future<bool> previewDeliveryNotePdf(
    List<BoxSummary> summaries,
    List<EnvironmentGroup> groupedByEnvironment,
  ) async {
    final Uint8List pdfData = await generateDeliveryNotePdf(
      summaries,
      groupedByEnvironment,
    );

    return await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  Future<bool> shareDeliveryNotePdf(
    List<BoxSummary> summaries,
    List<EnvironmentGroup> groupedByEnvironment,
  ) async {
    final Uint8List pdfData = await generateDeliveryNotePdf(
      summaries,
      groupedByEnvironment,
    );

    return await Printing.sharePdf(
      bytes: pdfData,
      filename: 'delivery_note.pdf',
    );
  }
}
