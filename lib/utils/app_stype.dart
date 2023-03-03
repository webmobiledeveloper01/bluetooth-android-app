import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//text style
TextStyle text20 = const TextStyle(
  color: Colors.white,
  fontSize: 20,
);
TextStyle text17 = const TextStyle(
  color: Colors.white,
  fontSize: 17,
);
TextStyle text16 = const TextStyle(
  color: Colors.white,
  fontSize: 16,
);
TextStyle text15 = const TextStyle(
  color: Colors.white,
  fontSize: 15,
);
TextStyle bold = const TextStyle(fontWeight: FontWeight.bold);
TextStyle text18bold = const TextStyle(
    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

//padding
EdgeInsets edge10 = const EdgeInsets.all(10);
EdgeInsets edge20 = const EdgeInsets.all(20);
EdgeInsets edge8 = const EdgeInsets.all(8);
EdgeInsets edgeVS10 = const EdgeInsets.symmetric(vertical: 10);
EdgeInsets edgeHVS2010 =
    const EdgeInsets.symmetric(horizontal: 20, vertical: 10);

//color filter
ColorFilter whiteColorFilter =
    const ColorFilter.mode(Colors.white, BlendMode.srcIn);

//status bar
SystemUiOverlayStyle statusBarStyle = const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light, // For Android (dark icons)
);
