import 'dart:io';

import 'package:cold_river_express_app/main.dart' show routeObserver;
import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'inventory_details_screen.dart';

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
  bool _isLoading = false;

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

    setState(() {
      _inventories = items;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
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
    return Dismissible(
      key: Key(inventory.id.toString()),
      background: Container(
        color: Colors.red,
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
      child: ListTile(
        leading:
            inventory.imagePath?.isNotEmpty == true
                ? Hero(
                  tag: inventory.id,
                  child: CircleAvatar(
                    backgroundImage: FileImage(File(inventory.imagePath!)),
                    radius: 24,
                  ),
                )
                : Hero(
                  tag: inventory.id,
                  child: CircleAvatar(child: Icon(Icons.inbox)),
                ),
        title: Text('Box N. ${inventory.boxNumber}'),
        subtitle: Text(inventory.contents.join(', ')),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => InventoryDetailsScreen(inventory: inventory),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cold River Express'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Inventory',
                hintText: 'Enter search text...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadInventories();
                          },
                        )
                        : null,
              ),
            ),
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
