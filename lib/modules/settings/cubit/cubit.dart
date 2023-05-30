import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/components/constants.dart';
import '../../../shared/cubit/cubit.dart';
import '../../../shared/network/local/cache_helper.dart';
import 'states.dart';

class SettingsCubit extends Cubit<SettingsStates> {
  SettingsCubit() : super(AppInitialState());

  static SettingsCubit get(context) => BlocProvider.of(context);

  clearCache(context) async {
    final cacheDir = await getTemporaryDirectory();
    await cacheDir.delete(recursive: true);
    StoryCubit.get(context).getStatusFiles();
  }
  Future<void> pickDirectory(context) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    await Directory(saveFolder).create(recursive: true);
    Directory? newDirectory = await FolderPicker.pick(
      allowFolderCreation: true,
      context: context,
      rootDirectory: Directory(saveFolder),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.white,
    );
      if (newDirectory!= null){
        saveFolder = newDirectory.path;
        CacheHelper.saveData(key: 'saveFolder', value: saveFolder);
        emit(UpdateDirectorySaveStatusState());
      }
  }
}