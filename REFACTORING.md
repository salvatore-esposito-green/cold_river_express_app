# Refactoring Multi-Piattaforma

## Panoramica

L'app è stata refactorizzata per supportare sia piattaforme **mobile** (Android/iOS) che **web** utilizzando un'architettura basata su interfacce astratte e implementazioni specifiche per piattaforma.

## Architettura

```
lib/
├── core/
│   ├── interfaces/              # Interfacce astratte
│   │   ├── bluetooth_service_interface.dart
│   │   ├── database_service_interface.dart
│   │   └── file_service_interface.dart
│   └── platform_factory.dart    # Factory per creare implementazioni
│
├── platforms/
│   ├── mobile/                  # Implementazioni mobile
│   │   ├── bluetooth_service_mobile.dart
│   │   ├── database_service_mobile.dart
│   │   └── file_service_mobile.dart
│   └── web/                     # Implementazioni web
│       ├── bluetooth_service_web.dart
│       ├── database_service_web.dart
│       └── file_service_web.dart
│
└── [resto del codice condiviso]
```

## Tecnologie per Piattaforma

### Mobile (Android/iOS)
- **Bluetooth**: `print_bluetooth_thermal` - Bluetooth classico per stampanti termiche
- **Database**: `sqflite` - SQLite nativo
- **File System**: File system nativo tramite `path_provider`
- **Immagini**: File system locale
- **Share**: `share_plus` con file nativi

### Web
- **Bluetooth**: **Web Bluetooth API** - Bluetooth LE per dispositivi moderni
- **Database**: `IndexedDB` (da implementare) o `sqflite_common_ffi_web`
- **File System**: `localStorage` per immagini (base64), Download API per export
- **Immagini**: localStorage con encoding base64
- **Share**: Download via Blob API

## Come Usare

### 1. Bluetooth Service

```dart
import 'package:cold_river_express_app/core/platform_factory.dart';

// Crea il servizio appropriato per la piattaforma
final bluetoothService = PlatformFactory.createBluetoothService();

// Verifica disponibilità
if (await bluetoothService.isBluetoothAvailable()) {
  // Scansiona dispositivi (mobile) o apri dialog selezione (web)
  final devices = await bluetoothService.scanDevices();

  // Connetti
  await bluetoothService.connect(devices.first.id);

  // Stampa
  await bluetoothService.printLabel(
    qrCodeId: 'QR123',
    boxNumber: 'BOX001',
    contents: 'Items list',
  );
}
```

### 2. Database Service

```dart
import 'package:cold_river_express_app/core/platform_factory.dart';

final dbService = PlatformFactory.createDatabaseService();

// Inizializza
await dbService.initialize();

// CRUD operations
await dbService.insertInventory(inventory);
final items = await dbService.getInventories();
```

### 3. File Service

```dart
import 'package:cold_river_express_app/core/platform_factory.dart';

final fileService = PlatformFactory.createFileService();

// Salva immagine
final path = await fileService.saveImage(imageBytes, 'image.png');

// Condividi PDF
await fileService.sharePdf(pdfBytes, 'delivery_note.pdf');
```

## Differenze tra Mobile e Web

### Bluetooth

#### Mobile
- Usa Bluetooth Classic
- Mostra lista dispositivi accoppiati
- Connessione diretta tramite MAC address
- Supporta stampanti termiche ESC/POS

#### Web
- Usa Web Bluetooth API (Bluetooth LE)
- Dialog browser per selezione dispositivo
- Richiede HTTPS (eccetto localhost)
- Limitato a dispositivi che supportano BLE
- UUID servizio stampante: `000018f0-0000-1000-8000-00805f9b34fb`

### Database

#### Mobile
- SQLite nativo con `sqflite`
- Prestazioni eccellenti
- Supporto completo SQL

#### Web (Da Implementare)
- IndexedDB tramite `idb_shim`
- Oppure `sqflite_common_ffi_web` per compatibilità
- Persistenza nel browser
- Limitazioni: dimensione storage, privacy browsing

### File System

#### Mobile
- File system nativo
- Path assoluti
- Share nativo

#### Web
- localStorage per immagini piccole (base64)
- Download via Blob per export
- Nessun "path" reale, solo chiavi storage

## Build e Deploy

### Mobile
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Web
```bash
# Build produzione
flutter build web --release

# Serve localmente per testing
flutter run -d chrome --web-port=8080
```

## Permessi Necessari

### Web (index.html)
```html
<meta http-equiv="Permissions-Policy" content="bluetooth=*">
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

### iOS (Info.plist)
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth access to connect to thermal printers</string>
```

## Limitazioni Web

1. **Web Bluetooth API**:
   - Funziona solo su HTTPS (o localhost)
   - Supportato su Chrome, Edge, Opera (non Safari/Firefox)
   - Richiede interazione utente per avviare scansione
   - Limitato a Bluetooth LE

2. **Storage**:
   - localStorage ha limite ~5-10MB
   - IndexedDB ha limiti variabili per browser

3. **Feature Non Disponibili su Web**:
   - QR Scanner (richiede fotocamera nativa)
   - Speech-to-Text (può essere implementato con Web Speech API)
   - Alcuni gesture e hardware features

## TODO

### Priorità Alta
- [ ] Implementare DatabaseServiceWeb con IndexedDB
- [ ] Testare Web Bluetooth con stampante reale
- [ ] Gestire fallback quando Bluetooth non disponibile

### Priorità Media
- [ ] Implementare QR Scanner Web con `jsQR` o `zxing-js`
- [ ] Ottimizzare storage immagini web (compressione, thumbnail)
- [ ] Aggiungere service worker per PWA offline

### Priorità Bassa
- [ ] Implementare Speech-to-Text web
- [ ] Aggiungere analytics per piattaforma
- [ ] Ottimizzare bundle size per web

## Testing

### Test Bluetooth Web
1. Aprire Chrome/Edge
2. Navigare a `localhost:8080` o sito HTTPS
3. Andare in Settings → Printer
4. Click "Connect" per aprire dialog selezione
5. Selezionare stampante BLE compatibile

### Browser Supportati
- ✅ Chrome 56+
- ✅ Edge 79+
- ✅ Opera 43+
- ❌ Firefox (flag sperimentale)
- ❌ Safari (non supportato)

## Risorse

- [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API)
- [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [Flutter Web](https://docs.flutter.dev/platform-integration/web)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
