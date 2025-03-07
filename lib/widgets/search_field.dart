import 'package:cold_river_express_app/widgets/filter_modal.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController searchController;

  final VoidCallback loadInventories;

  final dynamic selectedEnvironment;
  final dynamic selectedPosition;

  final VoidCallback onClearFilter;

  final void Function(String?, String?) onChangeFilter;

  const SearchField({
    super.key,
    required this.searchController,
    required this.loadInventories,
    this.selectedEnvironment,
    this.selectedPosition,
    required this.onClearFilter,
    required this.onChangeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search Inventory',
          hintText: 'Enter search text...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    loadInventories();
                  },
                ),
              if (selectedEnvironment != null || selectedPosition != null)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: onClearFilter,
                )
              else
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterModal(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterModal(
          onChangeFilter: onChangeFilter,
          selectedEnvironment: selectedEnvironment,
          selectedPosition: selectedPosition,
        );
      },
    );
  }
}
