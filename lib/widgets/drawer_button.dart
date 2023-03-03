import 'package:bluetooth_serial/utils/colors.dart';
import 'package:flutter/material.dart';

class DrawerButton extends StatelessWidget {
  const DrawerButton({
    Key? key,
    required this.text,
    required this.onTap,
    required this.selected,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? foreground : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
