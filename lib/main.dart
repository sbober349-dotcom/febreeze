import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bool isProduction = true;
const bool testingMode = true;

// App definitions
final List<Map<String, dynamic>> apps = [
  {"name": "Phone", "icon": "phone.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled","https://web.telegram.org"] : ["notepad.exe"]},
  {"name": "Messages", "icon": "messages.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled", "https://web.whatsapp.com"] : ["notepad.exe"]},
  {"name": "Camera", "icon": "camera.png", "exec": isProduction ? ["pkill", "Xorg"] : ["notepad.exe"]},
  {"name": "Photos", "icon": "photos.png", "exec": isProduction ? ["thunar"] : ["notepad.exe"]},
  {"name": "Youtube", "icon": "youtube.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled", "https://youtube.com"] : ["notepad.exe"]},
  {"name": "Tiktok", "icon": "music.png", "exec": isProduction ?  ["chromium", "--kiosk","--touch-events=enabled", "https://tiktok.com"] : ["notepad.exe"]},
  {"name": "Settings", "icon": "settings.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled", "chrome://settings"] : ["notepad.exe"]},
  {"name": "Maps", "icon": "maps.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled", "https://maps.google.com"] : ["notepad.exe"]},
  {"name": "Mail", "icon": "mail.png", "exec": isProduction ? ["chromium", "--kiosk", "--touch-events=enabled", "https://mail.google.com"] : ["notepad.exe"]},
  {"name": "Browser", "icon": "browser.png", "exec": isProduction ? ["chromium", "--kiosk", "--touch-events=enabled"] : ["notepad.exe"]},
];

// Dock apps
final List<Map<String, dynamic>> dockApps = [
  {"name": "Phone", "icon": "phone.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled","https://web.telegram.org"] : ["notepad.exe"]},
  {"name": "Messages", "icon": "messages.png", "exec": isProduction ? ["chromium", "--kiosk","--touch-events=enabled", "https://web.whatsapp.com"] : ["notepad.exe"]},
  {"name": "Camera", "icon": "camera.png", "exec": isProduction ? ["pkill", "Xorg"] : ["notepad.exe"]},
  {"name": "Browser", "icon": "browser.png", "exec": isProduction ? ["chromium", "--kiosk", "--touch-events=enabled", "https://google.com"] : ["notepad.exe"]},
];

void log(String msg) {
  debugPrint("[${DateTime.now().toString()}] $msg");
}

Future<void> launchApp(List<String> execCmd, String appName) async {
  try {
    log("🚀 Launching $appName -> ${execCmd.join(' ')}");
    await Process.run(execCmd[0], execCmd.length > 1 ? execCmd.sublist(1) : []);
  } catch (e) {
    log("❌ Launch failed for $appName: $e");
  }
}

class GlassEffect extends StatelessWidget {
  final double intensity;

  const GlassEffect({
    super.key,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1 * intensity),
        border: Border.all(
          color: Colors.white.withOpacity(0.5 * intensity),
          width: 2.0,
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 20.0 * intensity,
          sigmaY: 20.0 * intensity,
        ),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class OnScreenKeyboard extends StatefulWidget {
  final Function(String) onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;
  final VoidCallback onClose;
  final double keySize;
  final double fontSize;

  const OnScreenKeyboard({
    super.key,
    required this.onTextInput,
    required this.onBackspace,
    required this.onEnter,
    required this.onClose,
    required this.keySize,
    required this.fontSize,
  });

  @override
  State<OnScreenKeyboard> createState() => _OnScreenKeyboardState();
}

class _OnScreenKeyboardState extends State<OnScreenKeyboard> {
  bool _capsEnabled = false;
  bool _numbersEnabled = false;

  List<List<String>> get _keyboardLayout {
    if (_numbersEnabled) {
      return [
        ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
        ['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"'],
        ['.', ',', '?', '!', '\'', '⌫'],
        ['ABC', 'space', '⮐', '⏎'],
      ];
    } else {
      return [
        [
          _capsEnabled ? 'Q' : 'q',
          _capsEnabled ? 'W' : 'w',
          _capsEnabled ? 'E' : 'e',
          _capsEnabled ? 'R' : 'r',
          _capsEnabled ? 'T' : 't',
          _capsEnabled ? 'Y' : 'y',
          _capsEnabled ? 'U' : 'u',
          _capsEnabled ? 'I' : 'i',
          _capsEnabled ? 'O' : 'o',
          _capsEnabled ? 'P' : 'p',
        ],
        [
          _capsEnabled ? 'A' : 'a',
          _capsEnabled ? 'S' : 's',
          _capsEnabled ? 'D' : 'd',
          _capsEnabled ? 'F' : 'f',
          _capsEnabled ? 'G' : 'g',
          _capsEnabled ? 'H' : 'h',
          _capsEnabled ? 'J' : 'j',
          _capsEnabled ? 'K' : 'k',
          _capsEnabled ? 'L' : 'l',
        ],
        [
          '⇧',
          _capsEnabled ? 'Z' : 'z',
          _capsEnabled ? 'X' : 'x',
          _capsEnabled ? 'C' : 'c',
          _capsEnabled ? 'V' : 'v',
          _capsEnabled ? 'B' : 'b',
          _capsEnabled ? 'N' : 'n',
          _capsEnabled ? 'M' : 'm',
          '⌫',
        ],
        ['123', 'space', '⮐', '⏎'],
      ];
    }
  }

  void _handleKeyPress(String key) {
    if (key == '⇧') {
      setState(() => _capsEnabled = !_capsEnabled);
    } else if (key == '123' || key == 'ABC') {
      setState(() => _numbersEnabled = !_numbersEnabled);
    } else if (key == '⌫') {
      widget.onBackspace();
    } else if (key == '⮐') {
      widget.onEnter();
    } else if (key == '⏎') {
      widget.onClose();
    } else if (key == 'space') {
      widget.onTextInput(' ');
    } else {
      widget.onTextInput(key);
    }
  }

  Widget _buildKey(String key) {
    final bool isSpecial = ['⇧', '⌫', '⮐', '⏎', '123', 'ABC', 'space'].contains(key);
    final double keyWidth = key == 'space' ? widget.keySize * 3.5 : widget.keySize;
    final Color keyColor = isSpecial ? Colors.blueGrey[700]! : Colors.grey[900]!;

    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: keyColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _handleKeyPress(key),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: keyWidth,
            height: widget.keySize,
            alignment: Alignment.center,
            child: Text(
              key == 'space' ? ' ' : key,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: Colors.white,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _keyboardLayout
            .map((row) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) => _buildKey(key)).toList(),
                ))
            .toList(),
      ),
    );
  }
}

class PhoneHomeScreen extends StatefulWidget {
  const PhoneHomeScreen({super.key});

  @override
  State<PhoneHomeScreen> createState() => _PhoneHomeScreenState();
}

class _PhoneHomeScreenState extends State<PhoneHomeScreen> with TickerProviderStateMixin {
  late DateTime _currentTime;
  late Timer _minuteTimer;
  double _lockScreenTop = 0;
  double _lockScreenOpacity = 1;
  bool _showHomeScreen = false;
  bool _isAnimating = false;
  double _startY = 0;
  TextEditingController _commandController = TextEditingController();
  bool _keyboardVisible = false;
  FocusNode _terminalFocusNode = FocusNode();

  // Screen dimensions
  late double screenWidth;
  late double screenHeight;
  late double timeFontSize;
  late double dateFontSize;
  late double pillWidth;
  late double pillHeight;
  late double pillBottom;
  late double swipeThreshold;
  late double clockTopPadding;
  late double iconSize;
  late double iconFontSize;
  late double gridSpacing;
  late double gridPadding;
  late int gridColumns;
  late double iconShadowBlur;
  late Offset iconShadowOffset;
  late Color iconShadowColor;
  late double iconBorderRadius;
  late double dockHeight;
  late double dockIconSize;
  late double keySize;
  late double keyFontSize;

  // Animation controllers
  late AnimationController _unlockAppController;
  late AnimationController _appLaunchController;
  List<Animation<double>> _appAnimations = [];
  List<Animation<double>> _dockAnimations = [];
  Map<String, dynamic>? _launchingApp;
  bool _isUnlockAnimationPlaying = false;
  bool _isLaunching = false;

  // Custom cubic bezier curve
  static const Cubic _launchCurve = Cubic(0.4, 0.0, 0.2, 1.0);

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _minuteTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() => _currentTime = DateTime.now());
    });

    // Initialize dimensions based on testing mode
    if (testingMode) {
      screenWidth = 960;
      screenHeight = 640;
      timeFontSize = 100;
      dateFontSize = 25;
      pillWidth = 200;
      pillHeight = 6;
      pillBottom = 30;
      swipeThreshold = 200;
      clockTopPadding = 150;
      iconSize = 70;
      iconFontSize = 12;
      gridSpacing = 4;
      gridPadding = 50;
      gridColumns = 4;
      iconShadowBlur = 15;
      iconShadowOffset = const Offset(0, 4);
      iconShadowColor = const Color(0x80000000);
      iconBorderRadius = 20;
      dockHeight = 100;
      dockIconSize = 60;
      keySize = 50;
      keyFontSize = 20;
    } else {
      screenWidth = 1080;
      screenHeight = 1920;
      timeFontSize = 150;
      dateFontSize = 40;
      pillWidth = 300;
      pillHeight = 8;
      pillBottom = 40;
      swipeThreshold = 300;
      clockTopPadding = 200;
      iconSize = 120;
      iconFontSize = 18;
      gridSpacing = 40;
      gridPadding = 100;
      gridColumns = 4;
      iconShadowBlur = 25;
      iconShadowOffset = const Offset(0, 6);
      iconShadowColor = const Color(0x80000000);
      iconBorderRadius = 25;
      dockHeight = 150;
      dockIconSize = 90;
      keySize = 70;
      keyFontSize = 24;
    }

    // Focus node listener for keyboard visibility
    _terminalFocusNode.addListener(() {
      setState(() => _keyboardVisible = _terminalFocusNode.hasFocus);
    });

    // Unlock animation controller
    _unlockAppController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // App launch animation controller (450ms duration)
    _appLaunchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    
    // Create unlock animations
    _createUnlockAnimations();
  }

  void _createUnlockAnimations() {
    _appAnimations = [];
    _dockAnimations = [];
    
    // Create fade animations for main apps
    for (int i = 0; i < apps.length; i++) {
      _appAnimations.add(Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _unlockAppController,
        curve: Interval(0.1 + (i * 0.05), 0.6 + (i * 0.05), curve: Curves.easeOut),
      )));
    }
    
    // Create fade animations for dock apps
    for (int i = 0; i < dockApps.length; i++) {
      _dockAnimations.add(Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _unlockAppController,
        curve: Interval(0.6 + (i * 0.1), 0.9 + (i * 0.1), curve: Curves.easeOut),
      )));
    }
  }

  void _startUnlockAnimation() {
    setState(() {
      _isUnlockAnimationPlaying = true;
      _unlockAppController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _minuteTimer.cancel();
    _commandController.dispose();
    _terminalFocusNode.dispose();
    _unlockAppController.dispose();
    _appLaunchController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _startY = details.globalPosition.dy;
    setState(() => _isAnimating = false);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final double deltaY = details.globalPosition.dy - _startY;
    final double newTop = min(deltaY, 0);
    final double newOpacity = 1 - (newTop.abs() / screenHeight).clamp(0.0, 0.9);

    setState(() {
      _lockScreenTop = newTop;
      _lockScreenOpacity = newOpacity;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isAnimating = true;
      if (_lockScreenTop.abs() > swipeThreshold) {
        _lockScreenTop = -screenHeight;
        _lockScreenOpacity = 0;
        _showHomeScreen = true;
        Future.delayed(const Duration(milliseconds: 100), _startUnlockAnimation);
      } else {
        _lockScreenTop = 0;
        _lockScreenOpacity = 1;
      }
    });
  }

  Future<void> _executeCommand() async {
    if (_commandController.text.isEmpty) return;
    
    String command = _commandController.text;
    _commandController.clear();
    
    try {
      List<String> execCmd;
      if (isProduction) {
        execCmd = ["bash", "-c", command];
      } else {
        execCmd = ["cmd", "/c", command];
      }
      
      await Process.run(execCmd[0], execCmd.length > 1 ? execCmd.sublist(1) : []);
    } catch (e) {
      // Command errors are not displayed
    }
  }

  void _showTerminalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: screenWidth * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Terminal",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontFamily: 'SFProDisplay',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commandController,
                        focusNode: _terminalFocusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: isProduction ? "Enter Linux command..." : "Enter Windows command...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        ),
                        onSubmitted: (_) => _executeCommand(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _executeCommand,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      child: const Text("Execute", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime() {
    return "${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate() {
    return "${_weekdayToString(_currentTime.weekday)}, ${_monthToString(_currentTime.month)} ${_currentTime.day}";
  }

  String _weekdayToString(int weekday) {
    return [
      'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY',
      'THURSDAY', 'FRIDAY', 'SATURDAY'
    ][weekday - 1];
  }

  String _monthToString(int month) {
    return [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ][month - 1];
  }

  Widget _buildClock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(),
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: timeFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _formatDate(),
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: dateFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Future<void> _launchAppWithAnimation(Map<String, dynamic> app) async {
    setState(() {
      _isLaunching = true;
      _appLaunchController.reset();
      _keyboardVisible = false;
      if (_terminalFocusNode.hasFocus) {
        _terminalFocusNode.unfocus();
      }
    });

    // Launch the app
    launchApp(List<String>.from(app["exec"]), app["name"]);

    // Smooth glass effect animation
    await _appLaunchController.forward();
    
    if (mounted) {
      setState(() => _isLaunching = false);
    }
    _appLaunchController.reset();
  }

  Widget _buildAppIcon(Map<String, dynamic> app, int index) {
    return FadeTransition(
      opacity: _appAnimations[index],
      child: InkWell(
        onTap: () => _launchAppWithAnimation(app),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(iconBorderRadius),
        ),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(iconBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: iconShadowColor,
                    blurRadius: iconShadowBlur,
                    offset: iconShadowOffset,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconBorderRadius),
                child: Image.asset(
                  'assets/icons/${app["icon"]}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF444444),
                        borderRadius: BorderRadius.circular(iconBorderRadius),
                      ),
                      child: Center(
                        child: Text(
                          app["name"][0],
                          style: TextStyle(
                            fontSize: iconSize / 2,
                            color: Colors.white,
                            fontFamily: 'SFProDisplay',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              app["name"],
              style: TextStyle(
                fontSize: iconFontSize,
                color: Colors.white,
                fontFamily: 'SFProDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIcon(Map<String, dynamic> app, int index) {
    return FadeTransition(
      opacity: _dockAnimations[index],
      child: GestureDetector(
        onTap: () => _launchAppWithAnimation(app),
        child: Container(
          width: dockIconSize,
          height: dockIconSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(iconBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(iconBorderRadius),
            child: Image.asset(
              'assets/icons/${app["icon"]}',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF444444),
                    borderRadius: BorderRadius.circular(iconBorderRadius),
                  ),
                  child: Center(
                    child: Text(
                      app["name"][0],
                      style: TextStyle(
                        fontSize: dockIconSize / 2,
                        color: Colors.white,
                        fontFamily: 'SFProDisplay',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Dock at the bottom of the home screen
  Widget _buildDock() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: dockHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(dockApps.length, (index) {
            return _buildDockIcon(dockApps[index], index);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // Home Screen
            if (_showHomeScreen)
              Stack(
                children: [
                  // Background
                  Image.asset(
                    'assets/wallpapers/result2.png',
                    width: screenWidth,
                    height: screenHeight,
                    fit: BoxFit.cover,
                  ),
                  
                  // Overlay
                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x19000000),
                          Color(0x4D000000),
                        ],
                      ),
                    ),
                  ),
                  
                  // App grid with unlock animation
                  Padding(
                    padding: EdgeInsets.only(bottom: dockHeight + 20),
                    child: GridView.count(
                      crossAxisCount: gridColumns,
                      padding: EdgeInsets.all(gridPadding),
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      children: List.generate(apps.length, (index) {
                        return _buildAppIcon(apps[index], index);
                      }),
                    ),
                  ),
                  
                  // Dock with unlock animation
                  _buildDock(),
                ],
              ),

            // App Launch Animation - Glass Effect
            if (_isLaunching)
              AnimatedBuilder(
                animation: _appLaunchController,
                builder: (context, child) {
                  // Apply custom curve to animation value
                  final curvedValue = _launchCurve.transform(_appLaunchController.value);
                  return SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: GlassEffect(
                      intensity: curvedValue,
                    ),
                  );
                },
              ),

            // Lock Screen
            AnimatedPositioned(
              duration: _isAnimating
                  ? const Duration(milliseconds: 300)
                  : Duration.zero,
              top: _lockScreenTop,
              child: AnimatedOpacity(
                duration: _isAnimating
                    ? const Duration(milliseconds: 300)
                    : Duration.zero,
                opacity: _lockScreenOpacity,
                child: GestureDetector(
                  onVerticalDragStart: _onVerticalDragStart,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Stack(
                      children: [
                        // Lock screen background
                        Image.asset(
                          'assets/wallpapers/result.jpg',
                          width: screenWidth,
                          height: screenHeight,
                          fit: BoxFit.cover,
                        ),
                        
                        // Clock
                        Positioned(
                          top: clockTopPadding,
                          width: screenWidth,
                          child: Center(child: _buildClock()),
                        ),
                        
                        // Pill (without bottom shadow gradient)
                        Positioned(
                          bottom: pillBottom,
                          left: (screenWidth - pillWidth) / 2,
                          child: Container(
                            width: pillWidth,
                            height: pillHeight,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        
                        // Material You Terminal button - top right corner
                        Positioned(
                          top: 40,
                          right: 40,
                          child: ElevatedButton(
                            onPressed: _showTerminalDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[800]!.withOpacity(0.7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "TERMINAL",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // On-screen keyboard (always on top)
            if (_keyboardVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: OnScreenKeyboard(
                  onTextInput: (text) {
                    _commandController.text += text;
                    _commandController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _commandController.text.length),
                    );
                  },
                  onBackspace: () {
                    if (_commandController.text.isNotEmpty) {
                      _commandController.text = _commandController.text
                          .substring(0, _commandController.text.length - 1);
                      _commandController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _commandController.text.length),
                      );
                    }
                  },
                  onEnter: _executeCommand,
                  onClose: () {
                    _terminalFocusNode.unfocus();
                    setState(() => _keyboardVisible = false);
                  },
                  keySize: keySize,
                  fontSize: keyFontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PhoneHomeScreen(),
      theme: ThemeData(
        fontFamily: 'SFProDisplay',
        scaffoldBackgroundColor: Colors.black,
      ),
    ),
  );

}

