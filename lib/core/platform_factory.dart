import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';

import 'platform_services.dart'
    if (dart.library.html) 'platform_services_web.dart';

/// Factory per creare le implementazioni corrette in base alla piattaforma
class PlatformFactory {
  static BluetoothServiceInterface createBluetoothService() {
    return createBluetoothServiceImpl();
  }

  static DatabaseServiceInterface createDatabaseService() {
    return createDatabaseServiceImpl();
  }

  static FileServiceInterface createFileService() {
    return createFileServiceImpl();
  }

  static PermissionServiceInterface createPermissionService() {
    return createPermissionServiceImpl();
  }

  static bool get isWeb => kIsWeb;

  static bool get isMobile => !kIsWeb;
}
