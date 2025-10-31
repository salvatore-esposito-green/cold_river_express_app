import 'package:cold_river_express_app/widgets/app_drawer.dart';
import 'package:cold_river_express_app/widgets/modal/confirm_archive_inventory_modal.dart';
import 'package:cold_river_express_app/widgets/platform_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cold_river_express_app/config/app_config.dart';
import 'package:cold_river_express_app/controllers/inventory_search_controller.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/widgets/new_position_field.dart';
import 'package:cold_river_express_app/widgets/search_field.dart';
import 'package:cold_river_express_app/main.dart' show routeObserver;

class InventorySearchScreen extends StatefulWidget {
  const InventorySearchScreen({super.key});

  @override
  InventorySearchScreenState createState() => InventorySearchScreenState();
}

class InventorySearchScreenState extends State<InventorySearchScreen>
    with RouteAware {
  late final InventorySearchController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = InventorySearchController();
    _controller.loadInventories();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _controller.onSearchChanged(_searchController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _controller.loadInventories();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInventoryAvatar(Inventory inventory, bool isSelected) {
    if (isSelected) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        radius: 24,
        child: Icon(
          Icons.check,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    if (inventory.image_path?.isNotEmpty == true) {
      return Hero(
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
      );
    }

    return Hero(
      tag: inventory.id,
      child: const CircleAvatar(
        radius: 24,
        child: Icon(Icons.inbox),
      ),
    );
  }

  Widget _buildInventoryItem(Inventory inventory) {
    final bool isSelected = _controller.selectedInventoryIds.contains(
      inventory.id,
    );

    return Dismissible(
      key: Key(inventory.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _controller.archiveInventory(inventory.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item archived")));
      },
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return ConfirmArchiveInventoryModal(
              onCancel: () => Navigator.of(context).pop(false),
              onConfirm: () => Navigator.of(context).pop(true),
            );
          },
        );
      },
      child: Container(
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha((0.3 * 255).round())
                : null,
        child: ListTile(
          leading: InkWell(
            onTap: () => _controller.toggleSelectInventory(inventory.id),
            child: _buildInventoryAvatar(inventory, isSelected),
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
      ),
    );
  }

  Widget _buildInventoryCard(Inventory inventory) {
    final bool isSelected = _controller.selectedInventoryIds.contains(
      inventory.id,
    );

    return Dismissible(
      key: Key(inventory.id),
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.delete, color: Colors.white, size: 48),
      ),
      direction: DismissDirection.up,
      onDismissed: (direction) {
        _controller.archiveInventory(inventory.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item archived")));
      },
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return ConfirmArchiveInventoryModal(
              onCancel: () => Navigator.of(context).pop(false),
              onConfirm: () => Navigator.of(context).pop(true),
            );
          },
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isSelected
                  ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                  : BorderSide.none,
        ),
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha((0.3 * 255).round())
                : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, '/details', arguments: inventory);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section with selection overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child:
                          inventory.image_path?.isNotEmpty == true
                              ? Hero(
                                tag: inventory.id,
                                child: PlatformImage(
                                  imagePath: inventory.image_path!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : Hero(
                                tag: inventory.id,
                                child: Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: const Center(
                                    child: Icon(Icons.inbox, size: 48),
                                  ),
                                ),
                              ),
                    ),
                    // Selection button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () =>
                            _controller.toggleSelectInventory(inventory.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.9 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child:
                              isSelected
                                  ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  )
                                  : Icon(
                                    Icons.circle_outlined,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                        ),
                      ),
                    ),
                    // Environment chip
                    if (inventory.environment?.isNotEmpty == true)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Chip(
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            inventory.environment!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          elevation: 2,
                        ),
                      ),
                  ],
                ),
              ),
              // Content section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Box number
                      Text(
                        'Box N. ${inventory.box_number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Contents
                      Expanded(
                        child: Text(
                          inventory.contents.join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Position and size
                      if (inventory.position?.isNotEmpty ?? false)
                        Row(
                          children: [
                            Icon(
                              Icons.pin_drop,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                inventory.position!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '[${inventory.size}]',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InventorySearchController>.value(
      value: _controller,
      child: Consumer<InventorySearchController>(
        builder: (context, controller, child) {
          return Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child:
                          AppConfig.logoPath.isNotEmpty
                              ? Image.asset(
                                AppConfig.logoPath,
                                fit: BoxFit.contain,
                              )
                              : const Icon(Icons.home),
                    ),
                  );
                },
              ),
              title: Text(
                AppConfig.appName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pushNamed(context, '/share');
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                controller.selectedInventoryIds.isNotEmpty
                    ? NewPositionField(
                      onPositionChanged: (String value) async {
                        await controller.updateInventoriesPositions(value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Positions updated successfully'),
                            ),
                          );
                        }
                      },
                    )
                    : SearchField(
                      searchController: _searchController,
                      loadInventories: controller.loadInventories,
                      onChangeFilter:
                          (env, pos) async =>
                              await controller.changeFilter(env, pos),
                      onClearFilter: controller.clearFilter,
                      selectedEnvironment: controller.selectedEnvironment,
                      selectedPosition: controller.selectedPosition,
                    ),
                Expanded(
                  child:
                      controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : controller.inventories.isEmpty
                          ? const Center(
                            child: Text('No inventory items found.'),
                          )
                          : kIsWeb
                          ? LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive column count based on screen width
                              int crossAxisCount = 2;
                              if (constraints.maxWidth > 1200) {
                                crossAxisCount = 4;
                              } else if (constraints.maxWidth > 800) {
                                crossAxisCount = 3;
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: controller.inventories.length,
                                itemBuilder: (context, index) {
                                  return _buildInventoryCard(
                                    controller.inventories[index],
                                  );
                                },
                              );
                            },
                          )
                          : ListView.builder(
                            itemCount: controller.inventories.length,
                            itemBuilder: (context, index) {
                              return _buildInventoryItem(
                                controller.inventories[index],
                              );
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
