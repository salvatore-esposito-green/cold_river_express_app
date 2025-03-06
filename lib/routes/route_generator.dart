import 'package:cold_river_express_app/models/inventory.dart';
import 'package:cold_river_express_app/screens/home_screen.dart';
import 'package:cold_river_express_app/screens/inventory_details_screen.dart';
import 'package:cold_river_express_app/screens/inventory_edit_screen.dart';
import 'package:cold_river_express_app/screens/inventory_insert_screen.dart';
import 'package:cold_river_express_app/screens/inventory_search_screen.dart';
import 'package:cold_river_express_app/screens/qr_scan_screen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/details':
        final inventory = settings.arguments as Inventory;
        return MaterialPageRoute(
          builder: (_) => InventoryDetailsScreen(inventory: inventory),
        );
      case '/insert':
        return MaterialPageRoute(builder: (_) => InventoryInsertScreen());
      case '/edit':
        final inventory = settings.arguments as Inventory;
        return MaterialPageRoute(
          builder: (_) => InventoryEditScreen(inventory: inventory),
        );
      case '/search':
        return MaterialPageRoute(builder: (_) => InventorySearchScreen());
      case '/qr':
        return MaterialPageRoute(builder: (_) => QRScanScreen());
      default:
        return _errorRoute(settings.name ?? 'unknown');
    }
  }
}

Route<dynamic> _errorRoute(String args) {
  final t = args.toString();

  return MaterialPageRoute(
    builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('ERROR: $t')),
      );
    },
  );
}
