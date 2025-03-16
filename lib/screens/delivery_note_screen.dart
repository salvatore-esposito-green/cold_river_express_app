import 'package:cold_river_express_app/models/box_size.dart';
import 'package:cold_river_express_app/models/box_summary.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/services/pdf_service.dart';
import 'package:flutter/material.dart';

class DeliveryNoteScreen extends StatelessWidget {
  DeliveryNoteScreen({super.key});

  final PdfService _pdfService = PdfService();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  List<BoxSummary> _generateSummaries(List<Inventory> inventories) {
    final Map<String, List<Inventory>> groups = {};

    for (var inventory in inventories) {
      final key = inventory.size ?? '';

      if (key.isEmpty) continue;

      groups.putIfAbsent(key, () => []).add(inventory);
    }

    final List<BoxSummary> summaries = [];

    groups.forEach((boxSizeStr, groupInventories) {
      final count = groupInventories.length;

      final BoxSize box = BoxSize.fromString(boxSizeStr);

      final double totalGroupVolume = count * box.volume;

      summaries.add(
        BoxSummary(count: count, boxSize: box.value, volume: totalGroupVolume),
      );
    });

    return summaries;
  }

  Future<Map<String, List<BoxSummary>>>
  _generateGroupedByEnvironmentInventories(List<Inventory> inventories) async {
    final Map<String, List<Inventory>> inventoriesByEnvironment = {};

    for (var inventory in inventories) {
      final env = inventory.environment ?? 'default';

      inventoriesByEnvironment.putIfAbsent(env, () => []).add(inventory);
    }

    final Map<String, List<BoxSummary>> summariesByEnvironment = {};

    inventoriesByEnvironment.forEach((environment, invList) {
      summariesByEnvironment[environment] = _generateSummaries(invList);
    });

    return summariesByEnvironment;
  }

  Future<void> _shareDeliveryNote(BuildContext context) async {
    final inventories = await _inventoryRepository.fetchAllInventories();

    final summaries = _generateSummaries(inventories);
    final groupedByEnvironment = await _generateGroupedByEnvironmentInventories(
      inventories,
    );

    final pdf = await _pdfService.shareDeliveryNotePdf(
      summaries,
      groupedByEnvironment,
    );

    if (pdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error generating delivery note.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery note shared successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _printDeliveryNote(BuildContext context) async {
    final inventories = await _inventoryRepository.fetchAllInventories();

    final summaries = _generateSummaries(inventories);
    final groupedByEnvironment = await _generateGroupedByEnvironmentInventories(
      inventories,
    );

    final pdf = await _pdfService.previewDeliveryNotePdf(
      summaries,
      groupedByEnvironment,
    );

    if (pdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error generating delivery note.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery note print successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inventory>>(
      future: _inventoryRepository.fetchAllInventories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Delivery Note'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final inventories = snapshot.data!;
        final summaries = _generateSummaries(inventories);

        final double totalVolume = summaries.fold<double>(
          0,
          (sum, item) => sum + item.volume,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Delivery Note'), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DataTable(
                  columnSpacing: 0,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Number',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      columnWidth: FlexColumnWidth(1),
                      headingRowAlignment: MainAxisAlignment.center,
                    ),
                    DataColumn(
                      label: Text(
                        'Box Size',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      columnWidth: FlexColumnWidth(1),
                      headingRowAlignment: MainAxisAlignment.center,
                    ),
                    DataColumn(
                      label: Text(
                        'Volume',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      columnWidth: FlexColumnWidth(1),
                      headingRowAlignment: MainAxisAlignment.center,
                    ),
                  ],
                  rows:
                      summaries.map((summary) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  'N. ${summary.count}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  summary.boxSize,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  summary.volume.toStringAsFixed(3),
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tot. Vol ${totalVolume.toStringAsFixed(2)} m³',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _shareDeliveryNote(context);
                  },
                  child: const Text('Share Note'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _printDeliveryNote(context);
                  },
                  child: const Text('Print Note'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
