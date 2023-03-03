import 'dart:async';

import 'package:bluetooth_serial/utils/colors.dart';
import 'package:bluetooth_serial/utils/consts.dart';
import 'package:bluetooth_serial/utils/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../utils/app_stype.dart';
import '../utils/methods.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({
    Key? key,
    required this.onDeviceSelected,
    this.onSearchStateChanged,
  }) : super(key: key);

  final Function(BluetoothDevice)? onDeviceSelected;
  final Function(bool)? onSearchStateChanged;

  @override
  State<DevicesPage> createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<BluetoothDevice> _boundedLeDevices = [];
  final List<BluetoothDevice> _boundedClassicDevices = [];
  late StreamSubscription _streamSearch;
  BluetoothState _state = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _state = state;
        _loadBoundedDevices();
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _state = state;
        _loadBoundedDevices();
      });
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: appbar,
          child: Column(
            children: <Widget>[
              Expanded(child: Container()),
              TabBar(
                controller: _tabController,
                tabs: [
                  Padding(
                    padding: edge10,
                    child: Text(
                      translation(context).bluetooth_classic,
                      style: text16,
                    ),
                  ),
                  Padding(
                    padding: edge10,
                    child: Text(
                      translation(context).bluetooth_le,
                      style: text16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              ListView(
                children: _boundedClassicDevices.map((e) {
                  return InkWell(
                    onTap: () {
                      widget.onDeviceSelected!(e);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.white.withOpacity(.15),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: edgeVS10,
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            Container(
                              height: 40,
                              width: 8,
                              color:
                                  prefs!.getString(DEVICE_ADDRESS) == e.address
                                      ? orange
                                      : foreground,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name!,
                                  style: text17,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${e.address} ${e.bondState.isBonded ? '(${translation(context).paired})' : ''}',
                                  style: text15,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              ListView(
                children: _boundedLeDevices.map((e) {
                  return InkWell(
                    onTap: () {
                      widget.onDeviceSelected!(e);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.white.withOpacity(.15),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: edgeVS10,
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            Container(
                              height: 40,
                              width: 8,
                              color:
                                  prefs!.getString(DEVICE_ADDRESS) == e.address
                                      ? orange
                                      : foreground,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name!,
                                  style: text17,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${e.address} ${e.bondState.isBonded ? '(${translation(context).paired})' : ''}',
                                  style: text15,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Visibility(
            visible: _state != BluetoothState.STATE_ON,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  children: [
                    Column(
                      children: [
                        Text(
                          translation(context).please_turn_on_bluetooth,
                          style: text20,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: requestEnable,
                          child: Container(
                            padding: edge8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              translation(context).turn_on,
                              style: bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _loadBoundedDevices() {
    _boundedLeDevices.clear();
    _boundedClassicDevices.clear();
    if (_state != BluetoothState.STATE_ON) return;
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      for (var device in bondedDevices) {
        setState(() {
          if (device.type.stringValue == 'le') {
            _boundedLeDevices.add(device);
          } else {
            _boundedClassicDevices.add(device);
          }
        });
      }
    });
  }

  startDiscovery() {
    widget.onSearchStateChanged!(true);
    _streamSearch =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (r.device.type == BluetoothDeviceType.le) {
        bool exists = false;
        for (var element in _boundedLeDevices) {
          if (element.address == r.device.address) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          setState(() {
            _boundedLeDevices.add(r.device);
          });
        }
      } else {
        bool exists = false;
        for (var element in _boundedClassicDevices) {
          if (element.address == r.device.address) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          setState(() {
            _boundedClassicDevices.add(r.device);
          });
        }
      }
    });
    _streamSearch.onDone(() {
      widget.onSearchStateChanged!(false);
    });
  }

  stopDiscovery() {
    widget.onSearchStateChanged!(false);
    _streamSearch.cancel();
  }
}
