import 'dart:io';

import 'package:cold_river_express_app/main.dart' show routeObserver;
import 'package:cold_river_express_app/widgets/new_position_field.dart';
import 'package:cold_river_express_app/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';

class InventorySearchScreen extends StatefulWidget {
  const InventorySearchScreen({super.key});

  @override
  InventorySearchScreenState createState() => InventorySearchScreenState();
}

class InventorySearchScreenState extends State<InventorySearchScreen>
    with RouteAware {
  final InventoryRepository _repository = InventoryRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Inventory> _inventories = [];
  final List<String> _selectedInventory = [];

  bool _isLoading = false;

  String? _selectedEnvironment;
  String? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadInventories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);

    if (route is PageRoute) {
      routeObserver.subscribe(this as RouteAware, route);
    }
  }

  @override
  void didPopNext() {
    _loadInventories();
  }

  Future<void> _loadInventories() async {
    setState(() {
      _isLoading = true;
    });

    List<Inventory> items;

    if (_searchController.text.trim().isEmpty) {
      items = await _repository.fetchAllInventories();
    } else {
      items = await _repository.freeSearchInventory(
        _searchController.text.trim(),
      );
    }

    if (_selectedEnvironment != null || _selectedPosition != null) {
      items =
          items.where((inventory) {
            final matchesEnvironment =
                _selectedEnvironment == null ||
                inventory.environment == _selectedEnvironment;
            final matchesPosition =
                _selectedPosition == null ||
                inventory.position == _selectedPosition;
            return matchesEnvironment && matchesPosition;
          }).toList();
    }

    setState(() {
      _inventories = items;
      _isLoading = false;
      _selectedInventory.clear();
    });
  }

  void _onSearchChanged() {
    _loadInventories();
  }

  Future<void> _onChangeInventoriesPositions(String newPositions) async {
    FocusScope.of(context).unfocus();

    await _repository.updateInventoriesPosition(
      _selectedInventory,
      newPositions,
    );

    setState(() {
      _selectedInventory.clear();
    });

    await _loadInventories();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Positions updated successfully')));
  }

  void _onSelectInventory(String inventoryId) {
    setState(() {
      if (_selectedInventory.contains(inventoryId)) {
        _selectedInventory.remove(inventoryId);
      } else {
        _selectedInventory.add(inventoryId);
      }
    });
  }

  Future<void> _onChangeFilter(String? environment, String? position) async {
    setState(() {
      _selectedEnvironment = environment;
      _selectedPosition = position;
    });
    await _loadInventories();
  }

  void _onClearFilter() {
    setState(() {
      _selectedEnvironment = null;
      _selectedPosition = null;
    });
    _searchController.clear();
    _loadInventories();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    routeObserver.unsubscribe(this as RouteAware);

    super.dispose();
  }

  Widget _buildInventoryItem(Inventory inventory) {
    final bool isSelected = _selectedInventory.contains(inventory.id);

    return Dismissible(
      key: Key(inventory.id.toString()),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _repository.deleteInventoryById(inventory.id);
        _loadInventories();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Item deleted")));
      },
      child: Container(
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: .3)
                : null,

        child: ListTile(
          leading: InkWell(
            onTap: () {
              _onSelectInventory(inventory.id);
            },
            child:
                isSelected
                    ? CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 24,
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                    : inventory.imagePath?.isNotEmpty == true
                    ? Hero(
                      tag: inventory.id,
                      child: CircleAvatar(
                        backgroundImage: FileImage(File(inventory.imagePath!)),
                        radius: 24,
                      ),
                    )
                    : Hero(
                      tag: inventory.id,
                      child: CircleAvatar(
                        radius: 24,
                        child: const Icon(Icons.inbox),
                      ),
                    ),
          ),
          title: Text('Box N. ${inventory.boxNumber}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inventory.contents.join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
              if (inventory.position?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.pin_drop, size: 12),
                      SizedBox(width: 4),
                      Text(inventory.position!, style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          trailing:
              inventory.environment?.isNotEmpty == true
                  ? Chip(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/icons/icon-appbar.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'Cold River Express',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _selectedInventory.isNotEmpty
              ? NewPositionField(
                onPositionChanged: (String value) {
                  _onChangeInventoriesPositions(value);
                },
              )
              : SearchField(
                searchController: _searchController,
                loadInventories: () {
                  _loadInventories();
                },
                onChangeFilter: (env, pos) => _onChangeFilter(env, pos),
                onClearFilter: _onClearFilter,
                selectedEnvironment: _selectedEnvironment,
                selectedPosition: _selectedPosition,
              ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _inventories.isEmpty
                    ? Center(child: Text('No inventory items found.'))
                    : ListView.builder(
                      itemCount: _inventories.length,
                      itemBuilder: (context, index) {
                        return _buildInventoryItem(_inventories[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
