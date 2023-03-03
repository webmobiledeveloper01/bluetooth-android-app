import 'package:bluetooth_serial/utils/colors.dart';
import 'package:bluetooth_serial/widgets/drawer_button.dart';
import 'package:flutter/material.dart';

import '../utils/methods.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onTerminalTap,
    required this.onDeviceTap,
    required this.onSettingsTap,
    required this.onInfoTap,
  }) : super(key: key);

  final int selectedIndex;
  final VoidCallback onTerminalTap;
  final VoidCallback onDeviceTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 25),
                  color: appbar,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                          image: AssetImage('assets/images/icon.png'),
                          height: 80,
                        ),
                        Text(
                          translation(context).app_name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: background,
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  DrawerButton(
                    text: translation(context).terminal,
                    onTap: onTerminalTap,
                    selected: selectedIndex == 0,
                  ),
                  DrawerButton(
                    text: translation(context).devices,
                    onTap: onDeviceTap,
                    selected: selectedIndex == 1,
                  ),
                  DrawerButton(
                    text: translation(context).settings,
                    onTap: onSettingsTap,
                    selected: selectedIndex == 2,
                  ),
                  DrawerButton(
                    text: translation(context).info,
                    onTap: onInfoTap,
                    selected: selectedIndex == 3,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
