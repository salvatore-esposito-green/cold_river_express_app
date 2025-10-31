// Implementazioni web
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';

// Import con export condizionali per evitare che dart:html venga caricato su mobile
import 'package:cold_river_express_app/platforms/web/bluetooth_service_web_export.dart';
import 'package:cold_river_express_app/platforms/web/database_service_web_export.dart';
import 'package:cold_river_express_app/platforms/web/file_service_web_export.dart';
import 'package:cold_river_express_app/platforms/web/permission_service_web_export.dart';

BluetoothServiceInterface createBluetoothServiceImpl() => BluetoothServiceWeb();
DatabaseServiceInterface createDatabaseServiceImpl() => DatabaseServiceWeb();
FileServiceInterface createFileServiceImpl() => FileServiceWeb();
PermissionServiceInterface createPermissionServiceImpl() => PermissionServiceWeb();
