import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/network/local/cache_helper.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: BlocConsumer<SettingsCubit, SettingsStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = SettingsCubit.get(context);
          return Scaffold(
            backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
            appBar: customAppBar(context, 'Settings'),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  buildCustomTextButton(
                    onPressed: () {
                      StoryCubit.get(context).changeMode();
                      setState(() {

                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.grey[800]),
                        ),
                        FlutterSwitch(
                          width: 70.0,
                          height: 35.0,
                          toggleSize: 30.0,
                          value: isDark,
                          borderRadius: 30.0,
                          padding: 2.0,
                          activeToggleColor: const Color(0xff0f1c1e),
                          activeSwitchBorder: Border.all(
                            color: const Color(0xff0f1c1e),
                            width: 1.0,
                          ),
                          inactiveSwitchBorder: Border.all(
                            color: const Color(0xff22d363),
                            width: 2.0,
                          ),
                          activeColor: const Color(0xff1e2d31),
                          inactiveColor: const Color(0xff22d363),
                          activeIcon: const Icon(
                            Icons.nightlight_round,
                            color: Colors.white,
                          ),
                          inactiveIcon: const Icon(
                            Icons.wb_sunny,
                            color: Color(0xFFFFDF5D),
                          ),
                          onToggle: (val) {
                            StoryCubit.get(context).changeMode();
                            setState(() {

                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  buildCustomTextButton(
                    onPressed: () async {
                      cubit.pickDirectory(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          'Save Path: ',
                          style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.grey[800]),
                        ),
                        Expanded(
                          child: Text(
                            saveFolder,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCustomTextButton(
                        onPressed: () async {
                          setState(() {
                            saveFolder = '/storage/emulated/0/StorySA';
                          });
                          await Directory(saveFolder).create(recursive: true);

                          CacheHelper.saveData(
                              key: 'saveFolder', value: saveFolder);
                          toastShow(
                            text: 'Reset Successfully',
                            state: ToastStates.SUCCESS,
                          );
                        },
                        child: Text(
                          'Reset to default path',
                          style: TextStyle(
                            color: isDark ? Colors.amber : Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCustomTextButton(
                        onPressed: () async {
                          cubit.clearCache(context);
                          toastShow(
                            text: 'Cleared Successfully',
                            state: ToastStates.SUCCESS,
                          );
                        },
                        child: Text(
                          'Clear Cache',
                          style: TextStyle(
                            color: isDark ? Colors.red : Colors.red[800],
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

  Widget buildCustomTextButton({
    required onPressed,
    required Widget child,
  }) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: isDark
            ? MaterialStateProperty.all<Color>(Colors.black12)
            : MaterialStateProperty.all<Color>(Colors.grey.shade100),
        overlayColor: isDark
            ? MaterialStateProperty.all<Color>(Colors.green)
            : MaterialStateProperty.all<Color>(Colors.green.shade100),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
