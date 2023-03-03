import 'dart:convert';

import 'package:bluetooth_serial/pages/settings_page.dart';
import 'package:bluetooth_serial/utils/colors.dart';
import 'package:bluetooth_serial/utils/methods.dart';
import 'package:bluetooth_serial/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_stype.dart';
import 'devices_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedDrawerButton = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<DevicesPageState> _devicePageKey =
      GlobalKey<DevicesPageState>();

  bool _isSearching = false;

  BluetoothConnection? _connection;
  BluetoothDevice? currentDevice;

  bool _connected = false;

  bool _connectedResponseReceived = false;

  String _status = 'Not Connected';

  late final List<Widget> _pages = [
    DevicesPage(
      key: _devicePageKey,
      onDeviceSelected: _connectToDevice,
      onSearchStateChanged: _updateSearchStatus,
    ),
    const SettingsPage(),
  ];

  _onDataReceived(Uint8List data) async {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    //connection response
    if (dataString.codeUnits.toString() ==
            [0x15, 0x00, 0x0f, 0x20].toString() &&
        !_connectedResponseReceived) {
      setState(() {
        _connectedResponseReceived = true;
        _status = 'Connected with response';
      });
      devPrint('Fully connected by getting response');
      while (true) {
        _sendMessage([0x17, 0xff, 0x4e]); //line 1
        _sendMessage([0x18, 0xbf, 0x4a]); //line 2
        if (_connectedResponseReceived == false) {
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void initState() {
    _checkPermission();
    currentDevice = getCurrentDevice();

    super.initState();
  }

  _closeDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  _updateSearchStatus(bool status) {
    setState(() {
      _isSearching = status;
    });
  }

  _checkPermission() async {
    if ((await Permission.bluetooth.status).isDenied ||
        (await Permission.bluetoothConnect.status).isDenied ||
        (await Permission.bluetoothScan.status).isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();
      for (PermissionStatus status in statuses.values) {
        if (!status.isGranted) {
          _showPermissionDialog();
          break;
        }
      }
    }
  }

  _sendMessage(List<int> hex) async {
    if (hex.isNotEmpty) {
      try {
        _connection!.output.add(Uint8List.fromList(hex + utf8.encode('\r\n')));
        await _connection!.output.allSent;
      } catch (e) {
        setState(() {});
      }
    }
  }

  _connectToDevice(BluetoothDevice device) {
    setState(() {
      _selectedDrawerButton = 0;
    });

    saveCurrentDevice(device);
    currentDevice = device;

    BluetoothConnection.toAddress(device.address).then((connection) {
      devPrint('Connected to the device!');
      setState(() {
        _connected = true;
        _status = 'Connected';
      });
      _connection = connection;
      _sendMessage([0x15, 0x7e, 0x8f]);
      Future.delayed(const Duration(seconds: 1)).then((value) {
        _sendMessage([0x15, 0x7e, 0x8f]);
      });
      Future.delayed(const Duration(seconds: 2)).then((value) {
        _sendMessage([0x15, 0x7e, 0x8f]);
      });
      connection.input!.listen(_onDataReceived).onDone(() {
        setState(() {
          _connected = false;
          _connectedResponseReceived = false;
          _status = 'Not Connected';
        });
        devPrint('Disconnected by remote request!');
      });
    }).catchError((error) {
      devPrint('Cannot connect, exception occurred!');
      devPrint(error);
      setState(() {
        _connected = false;
        _status = 'Not Connected';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,
      appBar: AppBar(
        systemOverlayStyle: statusBarStyle,
        backgroundColor: appbar,
        title: Text(
          _selectedDrawerButton == 0
              ? translation(context).terminal
              : (_selectedDrawerButton == 1
                  ? _isSearching
                      ? translation(context).searching
                      : translation(context).devices
                  : translation(context).settings),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: _selectedDrawerButton == 0
            ? [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (_connected) {
                      _connection!.dispose();
                      _connection = null;
                      setState(() {
                        _connected = false;
                        _connectedResponseReceived = false;
                        _status = 'Not Connected';
                      });
                    } else {
                      setState(() {
                        _status = 'Connecting...';
                      });
                      _connectToDevice(currentDevice!);
                    }
                  },
                  icon: _connected
                      ? SvgPicture.asset(
                          'assets/svgs/close_jack.svg',
                          colorFilter: whiteColorFilter,
                        )
                      : SvgPicture.asset(
                          'assets/svgs/open_jack.svg',
                          colorFilter: whiteColorFilter,
                        ),
                ),
              ]
            : (_selectedDrawerButton == 1
                ? [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: _handleScan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              _isSearching
                                  ? translation(context).stop
                                  : translation(context).scan,
                              style: text17,
                            ),
                          ),
                        ),
                      ),
                    )
                  ]
                : []),
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedDrawerButton,
        onTerminalTap: () {
          _closeDrawer();
          setState(() {
            _selectedDrawerButton = 0;
          });
        },
        onDeviceTap: () {
          _closeDrawer();
          setState(() {
            _selectedDrawerButton = 1;
          });
        },
        onSettingsTap: () {
          _closeDrawer();
          setState(() {
            _selectedDrawerButton = 2;
          });
        },
        onInfoTap: () {
          _closeDrawer();
          _showInfoDialog();
        },
      ),
      body: _selectedDrawerButton == 0
          ? _terminalPage(_status)
          : _pages[_selectedDrawerButton - 1],
    );
  }

  _handleScan() {
    FlutterBluetoothSerial.instance.state.then((state) {
      if (state != BluetoothState.STATE_ON) {
        requestEnable();
        return;
      }
      if (_isSearching) {
        _devicePageKey.currentState!.stopDiscovery();
      } else {
        _devicePageKey.currentState!.startDiscovery();
      }
    });
  }

  _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Dialog(
            backgroundColor: background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)), //this right here
            child: Wrap(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.white.withOpacity(.15),
                                ),
                              ),
                            ),
                            child: Text(
                              translation(context).permission_required,
                              style: text18bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Text(
                        translation(context).permission_required_message,
                        style: text16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.pop(context);
                              _checkPermission();
                            },
                            child: Text(
                              translation(context).retry,
                              style: text17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0)), //this right here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.white.withOpacity(.15),
                          ),
                        ),
                      ),
                      child: Text(
                        translation(context).info,
                        style: text18bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Serial Bluetooth terminal 1.0.0 Supports:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bluetooth Classic',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Devices implementing Bluetooth 2.0 standard SPP profile:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          '• HC-05, H6-06, ...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bluetooth LE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Devices implementing Bluetooth 4.0 vendor specific GATT profiles:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          '• Nordic Semiconductor nRF53822, ... (e.g. BBC micro:bit)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          '• Texas Instruments CC254x (e.g. HM-10, CC41-A, ... modules)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          '• Microchip RN4870/71, BM70/71 "transparent UART service"',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          '• Telit Bluemod and user defined profiles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: [
                            const Text(
                              'For troubleshooting look ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const Text(
                                'here.',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Baud Rate, Parity, ...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Communication is done at full bluetooth speed, so these properties are not configurable here. Devices implementing a bluetooth to serial converter typically set these properties with AT commands from serial side or additional BLE GATT characteristics.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Control characters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'To send control characters use Macros in HEX mode (e.g. 03 for Ctrl+c). With Settings- Receive- Display Mode Text they are shown in caret notation (e.g. ^C).',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            '.com',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: const Text(
                            '.com',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _terminalPage(String status) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            margin: edge20,
            child: Column(
              children: [
                Container(
                  padding: edge10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Line 1, scroll',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: edge10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Line 1, scroll',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  _sendMessage([
                    0x16,
                    0x20,
                    0x0E,
                    0x08,
                  ]);
                },
                child: Container(
                  padding: edgeHVS2010,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  child: Text(
                    translation(context).esc,
                    style: text20,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _sendMessage([
                    0x16,
                    0x01,
                    0xCE,
                    0x10,
                  ]);
                },
                child: Container(
                  padding: edgeHVS2010,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: Text(
                    translation(context).enter,
                    style: text20,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                _sendMessage([
                  0x16,
                  0x08,
                  0x0E,
                  0x16,
                ]);
              },
              child: Container(
                padding: edge10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/svgs/thick_up_arrow.svg',
                  height: 50,
                  colorFilter: whiteColorFilter,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    _sendMessage([
                      0x16,
                      0x10,
                      0x0E,
                      0x1C,
                    ]);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/thick_left_arrow.svg',
                      height: 50,
                      colorFilter: whiteColorFilter,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Visibility(
                      maintainState: true,
                      maintainSize: true,
                      maintainAnimation: true,
                      visible: false,
                      child: Container(
                        padding: edge10,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          'assets/svgs/thick_right_arrow.svg',
                          height: 50,
                          colorFilter: whiteColorFilter,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                      color: _connected ? Colors.green : Colors.red,
                      child: Center(
                        child: Text(
                          status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    _sendMessage([
                      0x16,
                      0x02,
                      0x8E,
                      0x11,
                    ]);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/thick_right_arrow.svg',
                      height: 50,
                      colorFilter: whiteColorFilter,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 35),
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                _sendMessage([
                  0x16,
                  0x04,
                  0x0E,
                  0x13,
                ]);
              },
              child: Container(
                padding: edge10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/svgs/thick_down_arrow.svg',
                  height: 50,
                  colorFilter: whiteColorFilter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
