// Implementazioni mobile
import 'package:cold_river_express_app/core/interfaces/bluetooth_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/database_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/file_service_interface.dart';
import 'package:cold_river_express_app/core/interfaces/permission_service_interface.dart';

import 'package:cold_river_express_app/platforms/mobile/bluetooth_service_mobile.dart';
import 'package:cold_river_express_app/platforms/mobile/database_service_mobile.dart';
import 'package:cold_river_express_app/platforms/mobile/file_service_mobile.dart';
import 'package:cold_river_express_app/platforms/mobile/permission_service_mobile.dart';

BluetoothServiceInterface createBluetoothServiceImpl() => BluetoothServiceMobile();
DatabaseServiceInterface createDatabaseServiceImpl() => DatabaseServiceMobile();
FileServiceInterface createFileServiceImpl() => FileServiceMobile();
PermissionServiceInterface createPermissionServiceImpl() => PermissionServiceMobile();
