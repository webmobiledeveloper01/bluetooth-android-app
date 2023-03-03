import 'package:bluetooth_serial/main.dart';
import 'package:bluetooth_serial/utils/colors.dart';
import 'package:bluetooth_serial/utils/consts.dart';
import 'package:bluetooth_serial/utils/methods.dart';
import 'package:flutter/material.dart';

import '../utils/app_stype.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedLanguage = 0;
  @override
  void initState() {
    _selectedLanguage = languages.indexOf(getLanguage());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _languageSelectionDialog,
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
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translation(context).language,
                            style: text16,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            translation(context).selected_language,
                            style:
                                TextStyle(color: Colors.white.withOpacity(.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _languageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (ctx, state) {
          return Dialog(
            backgroundColor: background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            child: Wrap(
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        state(() {
                          _selectedLanguage = 0;
                        });
                        MyApp.setLocale(context, languages[0]);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Radio(
                              value: _selectedLanguage,
                              groupValue: 0,
                              onChanged: (value) {},
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white),
                            ),
                            Text('English', style: text17),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        state(() {
                          _selectedLanguage = 1;
                        });
                        MyApp.setLocale(context, languages[1]);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Radio(
                              value: _selectedLanguage,
                              groupValue: 1,
                              onChanged: (value) {},
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white),
                            ),
                            Text('Spanish', style: text17),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }
}
