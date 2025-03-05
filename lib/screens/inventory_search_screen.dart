import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'inventory_details_screen.dart';

class InventorySearchScreen extends StatefulWidget {
  const InventorySearchScreen({super.key});

  @override
  InventorySearchScreenState createState() => InventorySearchScreenState();
}

class InventorySearchScreenState extends State<InventorySearchScreen> {
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
    super.dispose();
  }

  Widget _buildInventoryItem(Inventory inventory) {
    return ListTile(
      leading:
          inventory.imagePath?.isNotEmpty == true
              ? CircleAvatar(
                backgroundImage: FileImage(File(inventory.imagePath!)),
                radius: 24,
              )
              : CircleAvatar(child: Icon(Icons.inbox)),
      title: Text('Box Number: ${inventory.boxNumber}'),
      subtitle: Text(inventory.contents.join(', ')),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InventoryDetailsScreen(inventory: inventory),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Search')),
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
