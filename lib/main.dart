import 'package:flutter/material.dart';
import 'auth_screens.dart';
import 'dart:async';
import 'dart:math';

// --- Modelos de Dados ---
// Enum para definir o tipo de alerta.
enum AlertType { gas, fire }

// Classe para representar um registro de alerta no histórico.
class AlertRecord {
  final String id;
  final AlertType type;
  final String location;
  final String description;
  final DateTime timestamp;

  AlertRecord({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.timestamp,
  });
}

// Modelo simples para um dispositivo
class Device {
  String id;
  String name;
  String location;
  bool isConnected;
  int gasLevel;
  bool fireDetected;
  bool alarmEnabled;
  bool smsEnabled;
  bool notificationEnabled;

  Device({
    required this.id,
    required this.name,
    required this.location,
    this.isConnected = false,
    this.gasLevel = 0,
    this.fireDetected = false,
    this.alarmEnabled = false,
    this.smsEnabled = false,
    this.notificationEnabled = true,
  });
}

// Estado da aplicação (simplificado)
class AppState extends ChangeNotifier {
  List<Device> devices = [
    Device(
      id: 'device-001',
      name: 'Detector HP-001',
      location: 'Cozinha',
      isConnected: true,
      gasLevel: 12,
      fireDetected: false,
      alarmEnabled: true,
      smsEnabled: true,
      notificationEnabled: true,
    ),
    Device(
      id: 'device-002',
      name: 'Detector AZ-250',
      location: 'Área de Serviço',
      isConnected: true,
      gasLevel: 8,
      fireDetected: false,
      alarmEnabled: true,
      smsEnabled: false,
      notificationEnabled: true,
    ),
  ];
  List<AlertRecord> alertHistory = [];
  ThemeMode themeMode = ThemeMode.light;

  bool _isFireAlertActive = false;
  Device? fireAlertDevice;

  bool get isFireAlertActive => _isFireAlertActive;

  void addNewDevice(Device device) {
    devices.add(device);
    notifyListeners();
  }

  void updateDevice(Device device,
      {String? name,
      bool? alarmEnabled,
      bool? smsEnabled,
      bool? notificationEnabled}) {
    final idx = devices.indexWhere((d) => d.id == device.id);
    if (idx == -1) return;
    final d = devices[idx];
    if (name != null) d.name = name;
    if (alarmEnabled != null) d.alarmEnabled = alarmEnabled;
    if (smsEnabled != null) d.smsEnabled = smsEnabled;
    if (notificationEnabled != null) d.notificationEnabled = notificationEnabled;
    notifyListeners();
  }

  void simulateGasLeak(String location) {
    // Atualiza o nível de gás e fogo do dispositivo no local
    final deviceIdx = devices.indexWhere((d) => d.location.toLowerCase() == location.toLowerCase());
    if (deviceIdx != -1) {
      devices[deviceIdx].gasLevel = 150; // Nível crítico de gás
      devices[deviceIdx].fireDetected = true; // Fogo também detectado
    }
    
    final rec = AlertRecord(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.gas,
        location: location,
        description: 'Vazamento de gás detectado em $location',
        timestamp: DateTime.now());
    alertHistory.insert(0, rec);
    notifyListeners();
  }

  void simulateFire(String location) {
    _isFireAlertActive = true;
    final dev = devices.firstWhere(
        (d) => d.location.toLowerCase() == location.toLowerCase(),
        orElse: () => Device(id: 'tmp', name: 'Dispositivo', location: location));
    dev.fireDetected = true;
    fireAlertDevice = dev;
    final rec = AlertRecord(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.fire,
        location: location,
        description: 'Incêndio detectado em $location',
        timestamp: DateTime.now());
    alertHistory.insert(0, rec);
    notifyListeners();
  }

  void dismissFireAlert() {
    _isFireAlertActive = false;
    if (fireAlertDevice != null) fireAlertDevice!.fireDetected = false;
    fireAlertDevice = null;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// --- Ponto de Entrada da Aplicação ---
void main() {
  runApp(GasAlertaApp());
}

class GasAlertaApp extends StatelessWidget {
  final AppState appState = AppState();

  GasAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => MaterialApp(
        title: 'GasAlerta',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFF0F8FF),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF0F8FF),
            elevation: 2,
            iconTheme: IconThemeData(color: Color(0xFF008080)),
            titleTextStyle: TextStyle(
                color: Color(0xFF008080),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF008080),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFF0F8FF),
            selectedItemColor: Color(0xFF008080),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Color(0xFF008080), fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Color(0xFF222222)),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF181A20),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF22252A),
            elevation: 2,
            iconTheme: IconThemeData(color: Colors.tealAccent),
            titleTextStyle: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          cardTheme: CardTheme(
            color: Color(0xFF23262B),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF181A20),
            selectedItemColor: Colors.tealAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Colors.tealAccent, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        themeMode: appState.themeMode,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(appState: appState),
      ),
    );
  }
}

// --- Telas Principais ---
class SplashScreen extends StatefulWidget {
  final AppState appState;
  const SplashScreen({super.key, required this.appState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthEntryScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFFe3f2fd), const Color(0xFFffffff)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('imagens/logo.png', width: 120, height: 120),
              const SizedBox(height: 24),
              Text('GasAlerta',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700])),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final AppState appState;
  const MainScreen({super.key, required this.appState});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DispositivoScreen(appState: widget.appState),
      HistoricoScreen(appState: widget.appState),
      UsuarioScreen(appState: widget.appState),
    ];
    // Listener para mostrar o alerta de fogo
    widget.appState.addListener(_handleFireAlert);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_handleFireAlert);
    super.dispose();
  }

  void _handleFireAlert() {
    if (widget.appState.isFireAlertActive &&
        ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => AlertaFogoScreen(appState: widget.appState)),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Dispositivos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuário'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Tela de Dispositivos ---
class DispositivoScreen extends StatefulWidget {
  final AppState appState;
  const DispositivoScreen({super.key, required this.appState});

  @override
  State<DispositivoScreen> createState() => _DispositivoScreenState();
}

class _DispositivoScreenState extends State<DispositivoScreen> {
  // Código relacionado à impressora removido.

  void _showSimulationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simular Evento'),
        content: const Text('Qual alerta você gostaria de simular na Cozinha?'),
        actions: [
          TextButton(
            onPressed: () {
              widget.appState.simulateGasLeak('Cozinha');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Alerta de Gás Crítico Simulado!'),
                  backgroundColor: Colors.orange));
            },
            child: const Text('Vazamento de Gás'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.appState.simulateFire('Cozinha');
              // O alerta de fogo será mostrado automaticamente via listener em MainScreen
            },
            child: const Text('Incêndio', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final Color hpPrimary = Colors.teal[400]!;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            onPressed: () {
              _showSimulationDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => NotificationsScreen(appState: widget.appState),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.grey, size: 28),
            onPressed: () {
              // Navegar para a tela de usuário
              if (context.findAncestorStateOfType<_MainScreenState>() != null) {
                context.findAncestorStateOfType<_MainScreenState>()!._onItemTapped(2);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: hpPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                elevation: 6,
              ),
              child: const Text('Entrar',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
            ),
          ),
        ],
        backgroundColor: Colors.grey[200],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          return Container(
            color: Colors.grey[200],
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Meus Dispositivos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (appState.devices.isEmpty)
                    // Hero card - Mostrado quando não há dispositivos
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Vamos começar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              'Adicione o seu primeiro dispositivo para\ngerenciar configurações e obter suporte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: 240,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AddDeviceScreen(appState: appState)));
                              },
                              icon: const Icon(Icons.add, size: 20, color: Colors.white),
                              label: const Text('Adicionar dispositivo', style: TextStyle(fontSize: 16, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hpPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                elevation: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Illustration placeholder
                          SizedBox(
                            height: 160,
                            child: Center(
                              child: Image.asset('imagens/logo.png', width: 220, height: 140, fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Lista de dispositivos adicionados
                    Column(
                      children: [
                        ...appState.devices.map((device) => DeviceStatusCard(
                          device: device,
                          appState: appState,
                        )),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => AddDeviceScreen(appState: appState)));
                            },
                            icon: const Icon(Icons.add, size: 20, color: Colors.white),
                            label: const Text('Adicionar', style: TextStyle(color: Colors.white, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hpPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                              elevation: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Método de descoberta de impressoras removido.
}

// --- Tela de Histórico ---
class HistoricoScreen extends StatelessWidget {
  final AppState appState;
  const HistoricoScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('Histórico de Alertas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.teal, size: 28),
            onPressed: () {},
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          if (appState.alertHistory.isEmpty) {
            return const Center(child: Text('Nenhum alerta registrado.'));
          }
          return ListView.builder(
            itemCount: appState.alertHistory.length,
            itemBuilder: (context, index) {
              final record = appState.alertHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    record.type == AlertType.gas
                        ? Icons.cloud
                        : Icons.local_fire_department,
                    color: record.type == AlertType.gas
                        ? Colors.orange
                        : Colors.red,
                  ),
                  title: Text(record.description),
                  subtitle: Text(
                    '${record.location} - ${record.timestamp.day}/${record.timestamp.month} ${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Tela de Adicionar Dispositivo (FLUXO ATUALIZADO) ---
enum ConnectionStep {
  welcome,
  searching,
  deviceFound,
  wifiConfig,
  connecting,
  success
}

class AddDeviceScreen extends StatefulWidget {
  final AppState appState;
  const AddDeviceScreen({super.key, required this.appState});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  ConnectionStep _currentStep = ConnectionStep.welcome;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();

  void _runConnectionFlow() async {
    // Step 1: Start Searching
    setState(() => _currentStep = ConnectionStep.searching);
    await Future.delayed(const Duration(seconds: 4)); // Simulate search
    if (!mounted) return;

    // Step 2: Device Found
    setState(() => _currentStep = ConnectionStep.deviceFound);
  }

  void _connectDevice() async {
    if (_locationController.text.isEmpty || _wifiSsidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red));
      return;
    }

    // Step 4: Connecting
    setState(() => _currentStep = ConnectionStep.connecting);
    await Future.delayed(const Duration(seconds: 4)); // Simulate connection
    if (!mounted) return;

    final newDevice = Device(
      id: 'new-device-${Random().nextInt(100)}',
      name: 'Detector G-Alert Pro',
      location: _locationController.text,
      isConnected: true,
    );
    widget.appState.addNewDevice(newDevice);

    // Step 5: Success
    setState(() => _currentStep = ConnectionStep.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('Adicionar Novo Dispositivo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildStepContent(),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case ConnectionStep.welcome:
        return _buildWelcomeStep();
      case ConnectionStep.searching:
        return const _StatusIndicator(
            icon: Icons.search, text: 'Procurando dispositivos próximos...');
      case ConnectionStep.deviceFound:
        return _buildDeviceFoundStep();
      case ConnectionStep.wifiConfig:
        return _buildWifiConfigStep();
      case ConnectionStep.connecting:
        return const _StatusIndicator(
            icon: Icons.wifi_tethering, text: 'Conectando à rede Wi-Fi...');
      case ConnectionStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sensors_off, size: 60, color: Colors.grey),
        const SizedBox(height: 20),
        const Text('Vamos conectar seu GasAlerta',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text(
            'Certifique-se de que seu dispositivo está ligado e no modo de configuração.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _runConnectionFlow,
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
          child: const Text('Iniciar'),
        ),
      ],
    );
  }

  Widget _buildDeviceFoundStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Dispositivo Encontrado!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sensors, color: Colors.teal),
            title: const Text('Detector G-Alert Pro'),
            subtitle: const Text('Pronto para configurar'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () =>
                setState(() => _currentStep = ConnectionStep.wifiConfig),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Toque no dispositivo para continuar.',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildWifiConfigStep() {
    return ListView(
      children: [
        const Text('Configuração da Rede',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
            controller: _locationController,
            decoration: const InputDecoration(
                labelText: 'Nome do Local (ex: Cozinha)',
                border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(
            controller: _wifiSsidController,
            decoration: const InputDecoration(
                labelText: 'Nome da Rede Wi-Fi (SSID)',
                border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(
            controller: _wifiPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'Senha do Wi-Fi', border: OutlineInputBorder())),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _connectDevice,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15)),
          child: const Text('Conectar Dispositivo'),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text('Conectado com Sucesso!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
            'Seu dispositivo em "${_locationController.text}" está pronto para uso.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Voltar para MainScreen certificando que o dispositivo foi salvo
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => MainScreen(appState: widget.appState)),
            );
          },
          child: const Text('Concluir'),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatusIndicator({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 50, color: Colors.teal),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

// --- Tela de Notificações ---
class NotificationsScreen extends StatelessWidget {
  final AppState appState;
  const NotificationsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('Notificações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          if (appState.alertHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma notificação',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: appState.alertHistory.length,
            itemBuilder: (context, index) {
              final notification = appState.alertHistory[index];
              final isGasAlert = notification.type == AlertType.gas;
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: isGasAlert ? Colors.orange : Colors.red,
                        width: 4,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Icon(
                      isGasAlert ? Icons.cloud : Icons.local_fire_department,
                      color: isGasAlert ? Colors.orange : Colors.red,
                      size: 32,
                    ),
                    title: Text(
                      isGasAlert ? 'Alerta de Gás' : 'Alerta de Fogo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year} às ${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Tela de Alerta de Fogo ---
class AlertaFogoScreen extends StatelessWidget {
  final AppState appState;
  const AlertaFogoScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[700],
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 120),
            const SizedBox(height: 20),
            const Text('ALERTA DE FOGO!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'Sensor de fogo ativado em "${appState.fireAlertDevice?.location ?? 'Local Desconhecido'}"',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                // Adicionar lógica para ligar para emergência
                debugPrint('Ligando para 193...');
              },
              icon: const Icon(Icons.call),
              label: const Text('LIGAR PARA 193'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                appState.dismissFireAlert();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Estou seguro, dispensar alerta',
                style: TextStyle(
                    color: Colors.white, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tela de Usuário ---
class UsuarioScreen extends StatelessWidget {
  final AppState? appState;
  const UsuarioScreen({super.key, this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            color: Colors.teal[300],
            child: Column(
              children: const [
                CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.teal)),
                SizedBox(height: 10),
                Text('Marcos Paulo',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text('marcos.paulo@email.com',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                    child: ListTile(
                        leading: const Icon(Icons.account_circle_outlined,
                            color: Colors.teal),
                        title: const Text('Perfil do Usuário'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {})),
                const SizedBox(height: 10),
                Card(
                    child: ListTile(
                        leading:
                            const Icon(Icons.info_outline, color: Colors.teal),
                        title: const Text('Sobre o App'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {})),
                const SizedBox(height: 10),
                Card(
                    child: ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.teal),
                  title: Text(isDark ? 'Tema Claro' : 'Tema Escuro'),
                  onTap: () => appState?.toggleTheme(),
                )),
                const SizedBox(height: 10),
                Card(
                    child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.teal),
                        title: const Text('Sair'),
                        onTap: () {})),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Widgets Customizados ---
// Card que exibe o status de um dispositivo.
class DeviceStatusCard extends StatelessWidget {
  final Device device;
  final AppState appState;

  const DeviceStatusCard(
      {super.key, required this.device, required this.appState});

  void _navigateToDeviceDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DeviceDetailScreen(device: device, appState: appState),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGasCritical = device.gasLevel > 50;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor = device.fireDetected
        ? (isDark ? Colors.red.shade900 : Colors.red.shade100)
        : (isDark ? theme.cardColor : Colors.white);
    final Color borderColor = device.fireDetected
        ? (isDark ? Colors.redAccent : Colors.red.shade400)
        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.grey[400]! : Colors.grey;
    final Color gasColor = isGasCritical
        ? (isDark ? Colors.orangeAccent : Colors.orange.shade800)
        : (isDark ? Colors.greenAccent : Colors.green);
    final Color fireColor = device.fireDetected
        ? (isDark ? Colors.redAccent : Colors.red.shade800)
        : (isDark ? Colors.greenAccent : Colors.green);

    return GestureDetector(
      onTap: () => _navigateToDeviceDetail(context),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device.location,
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              Text(device.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.cloud_outlined, color: gasColor),
                  const SizedBox(width: 8),
                  Text(
                      'Gas: ${device.gasLevel} ppm - ${isGasCritical ? "CRÍTICO" : "Normal"}',
                      style: TextStyle(
                          color: gasColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_fire_department_outlined, color: fireColor),
                  const SizedBox(width: 8),
                  Text('Fogo: ${device.fireDetected ? "DETECTADO!" : "OK"}',
                      style: TextStyle(
                          color: fireColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pequeno widget para os feature cards usados na tela inicial estilo HP
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _FeatureCard(
      {required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, color: Colors.blueGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// Nova tela de detalhes do dispositivo
class DeviceDetailScreen extends StatefulWidget {
  final Device device;
  final AppState appState;
  const DeviceDetailScreen(
      {super.key, required this.device, required this.appState});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Text('Detalhes do Dispositivo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações principais
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Dispositivo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Local:', widget.device.location),
                    _buildInfoRow('Nome:', widget.device.name),
                    _buildInfoRow(
                      'Status:',
                      widget.device.isConnected ? 'Conectado' : 'Desconectado',
                      color: widget.device.isConnected ? Colors.green : Colors.red,
                    ),
                    _buildInfoRow('Gás (ppm):', '${widget.device.gasLevel}'),
                    _buildInfoRow(
                      'Fogo:',
                      widget.device.fireDetected ? 'DETECTADO' : 'Normal',
                      color: widget.device.fireDetected ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Configurações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome do Dispositivo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Renomear dispositivo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Permissões
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissões',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    CheckboxListTile(
                      title: const Text('Alarme no aparelho'),
                      value: alarmEnabled,
                      onChanged: (val) => setState(() => alarmEnabled = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Receber SMS'),
                      value: smsEnabled,
                      onChanged: (val) => setState(() => smsEnabled = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Receber notificações'),
                      value: notificationEnabled,
                      onChanged: (val) => setState(() => notificationEnabled = val ?? false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Informações do Produto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Produto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildProductInfo('Modelo:', 'Detector G-Alert Pro'),
                    _buildProductInfo('Série:', 'GAP-2024-${widget.device.id.substring(0, 6).toUpperCase()}'),
                    _buildProductInfo('Versão Firmware:', 'v2.1.3'),
                    _buildProductInfo('Última Atualização:', '15 de Novembro de 2024'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Suporte e Ajuda
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Obter Ajuda',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    // Iniciar pedido de reparo
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido de reparo iniciado! Entraremos em contato em breve.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.build, color: Colors.white),
                        label: const Text('Iniciar Pedido de Reparo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Obter ajuda no site
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Abrindo nosso site de suporte...'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.language, color: Colors.white),
                        label: const Text('Obter Mais Ajuda em Nosso Site', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[300],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fale conosco
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Abrindo formulário de contato...'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                        icon: const Icon(Icons.mail, color: Colors.white),
                        label: const Text('Fale Conosco', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[300],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.appState.updateDevice(
                    widget.device,
                    name: nameController.text,
                    alarmEnabled: alarmEnabled,
                    smsEnabled: smsEnabled,
                    notificationEnabled: notificationEnabled,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alterações salvas com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                ),
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  late TextEditingController nameController;
  late bool alarmEnabled;
  late bool smsEnabled;
  late bool notificationEnabled;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.device.name);
    alarmEnabled = widget.device.alarmEnabled;
    smsEnabled = widget.device.smsEnabled;
    notificationEnabled = widget.device.notificationEnabled;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
