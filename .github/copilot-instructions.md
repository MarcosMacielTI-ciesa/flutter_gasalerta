# AI Coding Agent Instructions for GasAlerta

## Project Overview
**GasAlerta** is a Flutter mobile application for smart home safety monitoring, detecting gas leaks and fire hazards. The app features a centralized state management system, multi-screen navigation flow, and dark/light theme support.

## Architecture & Key Components

### State Management Pattern
- **Single AppState class** (`AppState extends ChangeNotifier`) in `main.dart` manages all app state
- All screens access state through `widget.appState` parameter passing
- Direct `notifyListeners()` calls trigger rebuilds via `AnimatedBuilder`
- **No dependency injection framework** - use constructor parameter passing for state

### Data Models
Located in `main.dart`:
- **AlertType enum**: `gas`, `fire` - categorizes sensor alerts
- **AlertRecord**: Immutable alert history entry (id, type, location, description, timestamp)
- **Device**: Mutable device model with connection status, gas/fire readings, and permission flags

### Screen Structure
- **Auth Flow**: `AuthEntryScreen` → `LoginScreen` → `RegisterScreen` / `ForgotPasswordScreen`
- **Main App**: `MainScreen` (bottom nav) → `DispositivoScreen`, `HistoricoScreen`, `UsuarioScreen`
- **Device Management**: `AddDeviceScreen` (multi-step wizard with `ConnectionStep` enum), `DeviceDetailScreen`
- **Alert Screens**: `AlertaFogoScreen` (full-screen fire alert), `SplashScreen`

### Theme System
- Dual theme configuration in `GasAlertaApp` (light: blue/teal, dark: grey/teal accent)
- Check `Theme.of(context).brightness == Brightness.dark` to apply conditional styling
- Primary colors: Teal (`Colors.teal[700]`), secondary: maroon for login button

## Project-Specific Patterns

### Widget Styling Convention
All form inputs use consistent pattern:
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Field Label',
    prefixIcon: Icon(Icons.icon_name, color: Colors.teal[700]),
    filled: true,
    fillColor: isDark ? Colors.grey[800]?.withOpacity(0.5) : Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal[700]!, width: 2)),
  ),
)
```
- Rounded corners: 12-16px
- Teal accent on focus
- Opacity-based backgrounds for dark mode

### Navigation Pattern
- Use `Navigator.push()` for forward navigation
- Use `Navigator.pushReplacement()` for auth transitions
- Pass `AppState` to all screens requiring state modification

### Localization Notes
All UI text is in **Portuguese (Brazilian)**. Common terms:
- "Dispositivos" (Devices), "Histórico" (History), "Usuário" (User)
- "Alerta de Gás" (Gas Alert), "Incêndio" (Fire)
- "CEP" (Postal Code), "Rua" (Street), "Município" (City)

## Development Workflows

### Build & Run
```bash
flutter pub get              # Install dependencies
flutter run                  # Debug on connected device/emulator
flutter run --release        # Production build
```

### Code Analysis
```bash
flutter analyze             # Check for lints (uses analysis_options.yaml)
dart format lib/            # Format Dart files
```

### Asset Management
- Images located in `imagens/` and `assets/` directories
- Logo: `imagens/logo.png` (referenced as `Image.asset('imagens/logo.png')`)
- Register new assets in `pubspec.yaml` under `flutter: assets:`

## Critical Integration Points

### Fire Alert System
- `AppState.simulateFire()` sets `_isFireAlertActive = true` and stores device reference
- `MainScreen._handleFireAlert()` listens for state changes and pushes `AlertaFogoScreen`
- User can dismiss via button or "Estou seguro, dispensar alerta" text button
- Always check `appState.isFireAlertActive` before showing fire alert UI

### Device Addition Workflow
- Multi-step process defined by `ConnectionStep` enum (welcome → searching → deviceFound → wifiConfig → connecting → success)
- `AddDeviceScreen._connectDevice()` creates new `Device` and calls `widget.appState.addNewDevice()`
- Device validation: requires location and SSID before connection step

### Alert History
- Stored in `AppState.alertHistory` (List<AlertRecord>)
- New alerts inserted at index 0 (most recent first)
- Display in `HistoricoScreen` with icon based on `AlertType`

## Common Tasks & Patterns

### Adding a New Screen
1. Create screen class extending `StatelessWidget` or `StatefulWidget`
2. Accept `AppState appState` as constructor parameter
3. Use `Theme.of(context).brightness` for dark mode detection
4. Navigate via `Navigator.push(MaterialPageRoute(builder: (_) => NewScreen(appState: appState)))`

### Updating Device Settings
Call `appState.updateDevice()` with partial update parameters:
```dart
appState.updateDevice(device, name: 'New Name', alarmEnabled: true);
```

### Creating Alert Dialogs
Use `showDialog()` with `AlertDialog` widget; always include `Navigator.of(context).pop()` in action handlers

### Form Validation
Use `GlobalKey<FormState>` with `TextFormField` validators:
```dart
validator: (v) => (v == null || v.trim().isEmpty) ? 'Error message' : null
```

## File Structure
```
lib/
  main.dart                 # AppState, data models, main screens
  auth_screens.dart         # Authentication UI (login, register, forgot password)
pubspec.yaml               # Dependencies: flutter, cupertino_icons
imagens/                   # Logo and imagery assets
android/ / ios/            # Platform-specific configuration
```

## Dependencies & Constraints
- **Flutter SDK**: ^3.5.4
- **Dart 3.5+** required
- **Material Design 3** via Flutter's default material package
- **No external state management** (Provider, Riverpod, etc.) - use built-in ChangeNotifier
- **No HTTP client** yet - simulate API calls with `Future.delayed()`

## Critical Patterns to Preserve
1. **Single AppState instance** passed through constructor chain
2. **Portuguese UI text** for all user-facing strings
3. **Teal color scheme** for primary branding
4. **Consistent border radius** (12-16px) for all containers
5. **Dark mode compatibility** - always check `isDark` and conditionally style
6. **Bottom navigation** for main app sections (Devices, History, User)
