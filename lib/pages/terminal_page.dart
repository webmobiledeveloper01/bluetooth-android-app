import 'package:bluetooth_serial/utils/methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_stype.dart';
import '../utils/colors.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({
    Key? key,
    required this.onButtonPress,
    required this.status,
  }) : super(key: key);
  final Function(List<int>)? onButtonPress;
  final String status;

  @override
  Widget build(BuildContext context) {
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
                  onButtonPress!([
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
                  onButtonPress!([
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
                onButtonPress!([
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
                    onButtonPress!([
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
                      child: Center(
                        child: Text(
                          status,
                          textAlign: TextAlign.center,
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
                    onButtonPress!([
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
                onButtonPress!([
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
