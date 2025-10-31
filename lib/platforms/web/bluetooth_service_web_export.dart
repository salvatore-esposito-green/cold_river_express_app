// Export condizionale per BluetoothServiceWeb
// Su web, esporta l'implementazione reale
// Su altre piattaforme, esporta lo stub (che non sarà mai usato)

export 'bluetooth_service_web_stub.dart'
    if (dart.library.html) 'bluetooth_service_web.dart';
