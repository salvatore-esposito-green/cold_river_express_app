import 'package:cold_river_express_app/providers/printer_provider.dart';
import 'package:cold_river_express_app/repositories/inventory_repository.dart';
import 'package:cold_river_express_app/routes/route_generator.dart';
import 'package:cold_river_express_app/services/bluetooth_service.dart';
import 'package:cold_river_express_app/theme/theme.dart';
import 'package:cold_river_express_app/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  await BluetoothService.requestBluetoothPermissions();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => BluetoothPrinterProvider(),
          ),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final InventoryRepository repository = InventoryRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Cousine", "Cousine");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Cold River Express',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme:
          brightness == Brightness.light
              ? theme.darkHighContrast()
              : theme.lightHighContrast(),
    );
  }
}
