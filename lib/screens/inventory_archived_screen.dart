import 'package:cold_river_express_app/controllers/inventories_archive_controller.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/widgets/modal/confirm_delete_all_inventories_mdoal.dart';
import 'package:cold_river_express_app/widgets/modal/confirm_delete_inventory_modal.dart';
import 'package:cold_river_express_app/widgets/modal/confirm_restore_all_inventories_modal.dart';
import 'package:cold_river_express_app/widgets/modal/confirm_restore_inventory_modal.dart';
import 'package:cold_river_express_app/widgets/platform_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InventoryArchivedScreen extends StatefulWidget {
  const InventoryArchivedScreen({super.key});

  @override
  InventoryArchivedScreenState createState() => InventoryArchivedScreenState();
}

class InventoryArchivedScreenState extends State<InventoryArchivedScreen> {
  late final InventoriesArchiveController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoriesArchiveController();
    _controller.loadInventories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInventoryItem(Inventory inventory) {
    return Dismissible(
      key: Key(inventory.id.toString()),
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.restore, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => ConfirmRestoreInventoryModal(
                  itemId: inventory.id.toString(),
                  onRestore: () => {Navigator.of(context).pop(true)},
                ),
          );
        } else if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => ConfirmDeleteInventoryModal(
                  onDelete: () => {Navigator.of(context).pop(true)},
                ),
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _controller.restoreInventory(inventory.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inventory ${inventory.box_number} ripristinata'),
            ),
          );
        } else if (direction == DismissDirection.endToStart) {
          _controller.deleteInventory(inventory.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Inventory ${inventory.box_number} eliminata definitivamente',
              ),
            ),
          );
        }
      },
      child: ListTile(
        leading: inventory.image_path?.isNotEmpty == true
            ? Hero(
                tag: inventory.id,
                child: ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: PlatformImage(
                      imagePath: inventory.image_path!,
                      fit: BoxFit.cover,
                      errorWidget: const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.image_not_supported, size: 24),
                      ),
                    ),
                  ),
                ),
              )
            : const Hero(
                tag: 'default',
                child: CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.inbox),
                ),
              ),
        title: Text('Box N. ${inventory.box_number}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inventory.contents.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            if (inventory.position?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        inventory.position!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '[${inventory.size}]',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing:
            inventory.environment?.isNotEmpty == true
                ? Chip(
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    inventory.environment!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 0,
                )
                : null,
        onTap: () {
          Navigator.pushNamed(context, '/details', arguments: inventory);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InventoriesArchiveController>.value(
      value: _controller,
      child: Consumer<InventoriesArchiveController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Inventory Archiviate')),
            body: Column(
              children: [
                if (controller.inventories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.restore,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text('Ripristina'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (
                                      context,
                                    ) => ConfirmRestoreAllInventoriesDialog(
                                      onConfirm: () {
                                        _controller.restoreAllInventories();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tutte le inventory ripristinate',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.delete_forever,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text('Elimina'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (
                                      context,
                                    ) => ConfirmDeleteAllInventoriesDialog(
                                      onConfirm: () {
                                        _controller.deleteAllInventories();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tutte le inventory eliminate definitivamente',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child:
                      controller.inventories.isEmpty
                          ? const Center(
                            child: Text('Nessuna inventory archiviata'),
                          )
                          : ListView.builder(
                            itemCount: controller.inventories.length,
                            itemBuilder: (context, index) {
                              final item = controller.inventories[index];
                              return _buildInventoryItem(item);
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
