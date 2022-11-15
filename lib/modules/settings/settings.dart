import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import 'package:whatsapp_story/shared/network/local/cache_helper.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    Future<void> _pickDirectory(BuildContext context) async {
      Directory directory = Directory(saveFolder);
      // directory ??= Directory(FolderPicker.rootPath);
      print(directory.path);

      Directory? newDirectory = await FolderPicker.pick(
        allowFolderCreation: true,
        context: context,
        rootDirectory: directory,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      );
      setState(() {
        saveFolder = newDirectory!.path;
        CacheHelper.saveData(key: 'saveFolder', value: saveFolder);
      });
    }

    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        return Scaffold(
          backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
          appBar: CustomAppBar(context, 'Settings'),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                buildCustomTextButton(
                  onPressed: () {
                    cubit.changeMode();
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
                          cubit.changeMode();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                buildCustomTextButton(
                  onPressed: () async{
                    await cubit.checkPermissions(context);
                    _pickDirectory(context);
                    // cubit.checkPermissions(context).then((value) {
                    //
                    // });
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
                      onPressed: () {
                        setState(() {
                          saveFolder = '/storage/emulated/0/StorySA/Status';
                        });
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
                )
              ],
            ),
          ),
        );
      },
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
