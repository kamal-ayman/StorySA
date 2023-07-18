import 'dart:io';
import 'package:appcheck/appcheck.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import 'package:whatsapp_story/shared/components/components.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../models/files_model.dart';
import '../../modules/photos/photos_screen.dart';
import '../../modules/videos/videos_screen.dart';
import '../network/local/cache_helper.dart';

class StoryCubit extends Cubit<StoryStates> {
  StoryCubit() : super(AppInitialState());

  static StoryCubit get(context) => BlocProvider.of(context);

  changeMode() {
    isDark = !isDark;
    CacheHelper.saveData(key: 'isDark', value: isDark);
    emit(ChangeThemeModeState());
  }

  PermissionStatus permissionStatus = PermissionStatus.granted;

  int index = 0;

  changeIndex(int index) {
    if (this.index != index) {
      if (selectMode) {
        disableSelectMode();
      }
      this.index = index;
      emit(ChangeIndexState());
    }
  }

  List<Widget> screens = const [
    PhotosScreen(),
    VideosScreen(),
  ];

  Future getStoragePermission(context) async {
    permissionStatus = await Permission.storage.request().then((value) async {
      if (value.isGranted) {
        getStatusFiles();
      } else {
        checkPermissions(context);
        emit(PermissionDeniedState());
      }
      return value;
    });
  }

  chanePathStatuses({required bool isNormal}) {
    primaryWhatsApp = isNormal;
    CacheHelper.saveData(key: 'normalWhatsApp', value: primaryWhatsApp);
    if (isShowSavedStatus) changeSavedLayout();
    getStatusFiles();
    emit(ChangePathStatusesState());
  }

  Future checkPermissions(context) async {
    var status = await Permission.manageExternalStorage.status;
    print("loading status");
    if (status.isGranted) {
      await Directory(saveFolder).create(recursive: true);
      getStatusFiles();
      print("status is Granted");
    } else if (status.isRestricted || status.isDenied) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content:
      //     Text('Please add permission for app to manage external storage'),
      //   ),
      // );
      status = await Permission.manageExternalStorage.request();

    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please add permission for app to manage external storage'),
        ),
      );
    }
  }

  // downloadPath() {
  //   emit(AppDownloadLoadingState());
  //   downloadFiles.clear();
  //   Directory(saveFolder).list().forEach((element) {
  //     downloadFiles.add(element as File);
  //     print(element.path);
  //   }).then((value) {
  //     emit(AppDownloadSuccessState());
  //   }).catchError((e) {
  //     emit(AppDownloadErrorState());
  //   });
  // }

  int photoID = 0;
  Map<int, FileModel> photos = {};
  List<int> selectedPhotosID = [];
  List<int> unselectedPhotosID = [];

  int videoID = 0;
  Map<int, FileModel> videos = {};
  List<int> selectedVideosID = [];
  List<int> unselectedVideosID = [];

  Map<int, FileModel> savedPhotos = {};
  List<int> savedSelectedPhotosID = [];
  List<int> savedUnselectedPhotosID = [];

  Map<int, FileModel> savedVideos = {};
  List<int> savedSelectedVideosID = [];
  static List<int> savedUnselectedVideosID = [];


  void clearPhotosData() {
    photos.clear();
    selectedPhotosID.clear();
    unselectedPhotosID.clear();
  }

  void clearVideosData() {
    videos.clear();
    selectedVideosID.clear();
    unselectedVideosID.clear();
  }

  void clearSavedPhotosData() {
    savedPhotos.clear();
    savedSelectedPhotosID.clear();
    savedUnselectedPhotosID.clear();
  }

  void clearSavedVideosData() {
    savedVideos.clear();
    savedSelectedVideosID.clear();
    savedUnselectedVideosID.clear();
  }

  void clearData() {
    photoID = 0;
    videoID = 0;
    if (isShowSavedStatus) {
      clearSavedPhotosData();
      clearSavedVideosData();
    } else {
      clearPhotosData();
      clearVideosData();
    }
    print(savedVideos.isEmpty);
  }


  Map<int, FileModel> sortFiles(Map<int, FileModel> files) {
    if (isShowSavedStatus) {
      for (var i = 0; i < files.length / 2; i++) {
        final FileModel temp = files[i]!;
        files[i] = files[files.length - 1 - i]!;
        files[files.length - 1 - i] = temp;
      }
      files.forEach((key, value) => print(value.file));
    } else {
      File file;
      for (int i = 0; i < files.length; i++) {
        for (int j = i + 1; j < files.length; j++) {
          if (FileStat
              .statSync(files[i]!.file.path)
              .modified
              .isBefore(FileStat
              .statSync(files[j]!.file.path)
              .modified)) {
            file = files[i]!.file;
            files[i]!.file = files[j]!.file;
            files[j]!.file = file;
          }
        }
      }
    }
    return files;
  }

  void setDefaultSort() {
    if (isShowSavedStatus) {
      savedPhotos = sortFiles(savedPhotos);
      savedVideos = sortFiles(savedVideos);
    } else {
      photos = sortFiles(photos);
      videos = sortFiles(videos);
    }
  }

  bool isShowSavedStatus = false;

  changeSavedLayout() {
    disableSelectMode();
    isShowSavedStatus = !isShowSavedStatus;
    emit(AppShowSavedStatusState());
  }

  Future getUnsortedFiles() async {
    if (!isShowSavedStatus) {
      String whatsAppStatusesPath = '/storage/emulated/0/WhatsApp/Media/.Statuses';
      String whatsAppBusinessStatusesPath = '/storage/emulated/0/WhatsApp Business/Media/.Statuses';
      final res = await Directory(
          primaryWhatsApp ? whatsAppStatusesPath : whatsAppBusinessStatusesPath)
          .exists();
      if (!res) {
        const String newPath = 'Android/media/com.whatsapp/WhatsApp';
        whatsAppStatusesPath = '/storage/emulated/0/$newPath/Media/.Statuses';
        whatsAppBusinessStatusesPath =
        '/storage/emulated/0/$newPath Business/Media/.Statuses';
      }
      await Directory(
          primaryWhatsApp ? whatsAppStatusesPath : whatsAppBusinessStatusesPath)
          .list()
          .forEach((file) {
        final String type = file.path
            .split('.')
            .last;
        if (type == 'jpg') {
          photos.addAll({photoID: FileModel(file: File(file.path))});
          unselectedPhotosID.add(photoID++);
        } else if (type == 'mp4') {
          videos.addAll({videoID: FileModel(file: File(file.path))});
          videos[videoID]?.thumb = File('');
          unselectedVideosID.add(videoID++);
        }
      });
    } else {
      Directory(saveFolder).create(recursive: true);
      await Directory(saveFolder).list().forEach((file) {
        final String type = file.path
            .split('.')
            .last;
        if (type == 'jpg') {
          savedPhotos.addAll({photoID: FileModel(file: File(file.path))});
          savedUnselectedPhotosID.add(photoID++);
        } else if (type == 'mp4') {
          savedVideos.addAll({videoID: FileModel(file: File(file.path))});
          savedVideos[videoID]?.thumb = File('');
          savedUnselectedVideosID.add(videoID++);
        }
      });
    }
  }

  Future<void> getStatusFiles() async {
    emit(AppStatusLoadingState());

    disableSelectMode();

    clearData();

    await getUnsortedFiles();


    setDefaultSort();

    await getVideoThumbnail();
    emit(AppStatusSuccessState());
  }

  Future getVideoThumbnail() async {
    if (isShowSavedStatus) {
      print('true');
      final Directory pathThump = Directory(
          '${(await getTemporaryDirectory()).path}/.thumbsSaved}');
      pathThump.create(recursive: true);
      String testPath;
      for (int i = 0; i < savedVideos.length; i++) {
        testPath = '${pathThump.path}/${savedVideos[i]!
            .file.path
            .split('/')
            .last
            .split('.')
            .first}.jpg';
        if (File(testPath).existsSync()) {
          savedVideos[i]?.thumb = File(testPath);
        } else {
          await VideoThumbnail.thumbnailFile(
            imageFormat: ImageFormat.JPEG,
            video: savedVideos[i]!.file.path,
            thumbnailPath: pathThump.path,
            maxHeight: 210,
            quality: 100,
          ).then((value) {
            savedVideos[i]?.thumb = File(testPath);
          }).catchError((e) {
            print('error savedVideosThumbs: $e');
          });
        }
        emit(UpdateThumbnailState());
      }
      return;
    }
    final Directory pathThump = Directory(
        '${(await getTemporaryDirectory()).path}/.thumbs${primaryWhatsApp
            ? 'WhatsApp'
            : 'WhatsApp Business'}');
    pathThump.create(recursive: true);
    String testPath;
    for (int i = 0; i < videos.length; i++) {
      testPath = '${pathThump.path}/${videos[i]!
          .file.path
          .split('/')
          .last
          .split('.')
          .first}.jpg';
      if (File(testPath).existsSync()) {
        videos[i]!.thumb = File(testPath);
      } else {
        await VideoThumbnail.thumbnailFile(
          imageFormat: ImageFormat.JPEG,
          video: videos[i]!.file.path,
          thumbnailPath: pathThump.path,
          maxHeight: 210,
          quality: 100,
        ).then((value) {
          videos[i]?.thumb = File(testPath);
        }).catchError((e) {
          print('error videosThumbs: $e');
        });
      }
      emit(UpdateThumbnailState());
    }
  }

  bool selectMode = false;

  disableSelectMode() {
    if (!selectMode) return;
    selectMode = false;
    emit(DisableSelectModeState());
    unSelectAll();
  }

  bool isSelectAll = false;

  selectAll() {
    isSelectAll = true;
    if (isShowSavedStatus) {
      if (index == 0) {
        for (int i in savedUnselectedPhotosID) {
          savedPhotos[i]!.isSelected = true;
          savedSelectedPhotosID.add(i);
        }
        savedUnselectedPhotosID.clear();
      } else {
        for (int i in savedUnselectedVideosID) {
          savedVideos[i]!.isSelected = true;
          savedSelectedVideosID.add(i);
        }
        savedUnselectedVideosID.clear();
      }
    } else {
      if (index == 0) {
        for (int i in unselectedPhotosID) {
          photos[i]!.isSelected = true;
          selectedPhotosID.add(i);
        }
        unselectedPhotosID.clear();
      } else {
        for (int i in unselectedVideosID) {
          videos[i]!.isSelected = true;
          selectedVideosID.add(i);
        }
        unselectedVideosID.clear();
      }
    }
    emit(SelectAllState());
  }

  unSelectAll() {
    if (isShowSavedStatus) {
      if (index == 0) {
        for (var i in savedSelectedPhotosID) {
          savedPhotos[i]!.isSelected = false;
          savedUnselectedPhotosID.add(i);
        }
        savedSelectedPhotosID.clear();
      } else {
        for (var i in savedSelectedVideosID) {
          savedVideos[i]!.isSelected = false;
          savedUnselectedVideosID.add(i);
        }
        savedSelectedVideosID.clear();
      }
    } else {
      if (index == 0) {
        for (var i in selectedPhotosID) {
          photos[i]!.isSelected = false;
          unselectedPhotosID.add(i);
        }
        selectedPhotosID.clear();
      } else {
        for (var i in selectedVideosID) {
          videos[i]!.isSelected = false;
          unselectedVideosID.add(i);
        }
        selectedVideosID.clear();
      }
    }
    isSelectAll = false;
    emit(UnSelectAllState());
  }

  selectItem(int id) {
    selectMode = true;
    if (isShowSavedStatus) {
      if (index == 0) {
        savedPhotos[id]!.isSelected = true;
        savedSelectedPhotosID.add(id);
        savedUnselectedPhotosID.remove(id);
        if (savedSelectedPhotosID.length == savedPhotos.length) {
          isSelectAll = true;
        }
      } else {
        savedVideos[id]!.isSelected = true;
        savedSelectedVideosID.add(id);
        savedUnselectedVideosID.remove(id);
        if (savedSelectedVideosID.length == savedVideos.length) {
          isSelectAll = true;
        }
      }
    } else {
      if (index == 0) {
        photos[id]!.isSelected = true;
        selectedPhotosID.add(id);
        unselectedPhotosID.remove(id);
        if (selectedPhotosID.length == photos.length) {
          isSelectAll = true;
        }
      } else {
        videos[id]!.isSelected = true;
        selectedVideosID.add(id);
        unselectedVideosID.remove(id);
        if (selectedVideosID.length == videos.length) {
          isSelectAll = true;
        }
      }
    }
    emit(SelectItemState());
  }

  unSelectItem(int id) {
    if (isShowSavedStatus) {
      if (index == 0) {
        savedPhotos[id]!.isSelected = false;
        savedUnselectedPhotosID.add(id);
        savedSelectedPhotosID.remove(id);
        if (savedSelectedPhotosID.isEmpty) {
          selectMode = false;
        }
      } else {
        savedVideos[id]!.isSelected = false;
        savedUnselectedVideosID.add(id);
        savedSelectedVideosID.remove(id);
        if (savedSelectedVideosID.isEmpty) {
          selectMode = false;
        }
      }
    } else {
      if (index == 0) {
        photos[id]!.isSelected = false;
        unselectedPhotosID.add(id);
        selectedPhotosID.remove(id);
        if (selectedPhotosID.isEmpty) {
          selectMode = false;
        }
      } else {
        videos[id]!.isSelected = false;
        unselectedVideosID.add(id);
        selectedVideosID.remove(id);
        if (selectedVideosID.isEmpty) {
          selectMode = false;
        }
      }
    }
    isSelectAll = false;
    emit(UnSelectItemState());
  }

  saveSelectStory(FileType type) async {
    if (type == FileType.photos) {
      await Directory(saveFolder).create(recursive: true);
      for (int i in selectedPhotosID) {
        await photos[i]!.file.copy('$saveFolder/${photos[i]!
            .file.path
            .split('/')
            .last}');
      }
    } else {
      for (int i in selectedVideosID) {
        await videos[i]!.file.copy('$saveFolder/${videos[i]!
            .file.path
            .split('/')
            .last}');
      }
    }
    toastShow(text: 'Saved Successfully');
    disableSelectMode();
  }

  saveCurrentStory(File file) async {
    await Directory(saveFolder).create(recursive: true);
    String newFile = '$saveFolder/${file.path
        .split('/')
        .last}';
    file.copy(newFile).then((value) {
      toastShow(text: 'Story Saved Successfully', state: ToastStates.SUCCESS);
      emit(AppSaveSuccessState());
    }).catchError((e) {
      emit(AppSaveErrorState());
    });
  }

  late bool isWhatsappInstalled;
  late bool isWhatsapp4BInstalled;

  Future checkInstalledWhatsApp() async {
    await AppCheck.checkAvailability('com.whatsapp').then((app) {
      isWhatsappInstalled = true;
    }).catchError((e) {
      isWhatsappInstalled = false;
    });
    await AppCheck.checkAvailability('com.whatsapp.w4b').then((app) {
      isWhatsapp4BInstalled = true;
    }).catchError((e) {
      isWhatsapp4BInstalled = false;
    });
    // print('isWhatsappInstalled' + isWhatsappInstalled.toString());
    // print('isWhatsappInstalled1111' + isBusinessWhatsappInstalled.toString());
  }

  Future shareOneFile({
    String? path,
    required bool toWhatsapp,
    WhatsappType? whatsappType,
    context,
  }) async {
    if (!toWhatsapp) {
      await Share.shareFiles([path!]);
      return;
    }
    if (whatsappType != null) {
      await WhatsappShare.shareFile(
        package: whatsappType == WhatsappType.whatsapp
            ? Package.whatsapp
            : Package.businessWhatsapp,
        phone: '+',
        filePath: [path!],
      ).then((value) {
        whatsappType = null;
      });
      return;
    }
    await checkInstalledWhatsApp();
    if (isWhatsappInstalled && isWhatsapp4BInstalled) {
      askDialogRepost(
        path: path!,
        type: FileType.photos,
        context: context,
        shareOneFile: true,
      );
    } else {
      await WhatsappShare.shareFile(
        package:
        isWhatsappInstalled ? Package.whatsapp : Package.businessWhatsapp,
        phone: '+',
        filePath: [path!],
      );
    }
  }

  List<String> shareFilesPath = [];

  Future<void> shareFiles({
    required FileType type,
    bool shareToWhatsApp = false,
    required BuildContext context,
    WhatsappType? whatsappType,
    List<String>? shareFilesPathLocal,
  }) async {
    shareFilesPathLocal == null
        ? shareFilesPath.clear()
        : shareFilesPath = shareFilesPathLocal;
    // shareFilesPath.clear();
    if (whatsappType != null) {
      await WhatsappShare.shareFile(
        package: whatsappType == WhatsappType.whatsapp
            ? Package.whatsapp
            : Package.businessWhatsapp,
        phone: '+',
        filePath: shareFilesPath,
      ).then((value) {
        whatsappType = null;
        shareFilesPath.clear();
      });
      return;
    }
    if (isShowSavedStatus) {
      if (type == FileType.photos) {
        for (var element in savedSelectedPhotosID) {
          shareFilesPath.add(savedPhotos[element]!.file.path);
        }
      } else if (type == FileType.videos) {
        for (var element in savedSelectedVideosID) {
          shareFilesPath.add(savedVideos[element]!.file.path);
        }
      }
    } else {
      if (type == FileType.photos) {
        for (var element in selectedPhotosID) {
          shareFilesPath.add(photos[element]!.file.path);
        }
      } else if (type == FileType.videos) {
        for (var element in selectedVideosID) {
          shareFilesPath.add(videos[element]!.file.path);
        }
      }
    }

    disableSelectMode();

    if (shareToWhatsApp) {
      await checkInstalledWhatsApp();
      print('$isWhatsappInstalled  $isWhatsapp4BInstalled');
      if (!isWhatsappInstalled && !isWhatsapp4BInstalled) {
        toastShow(
            text: 'Please install WhatsApp first!', state: ToastStates.ERROR);
        return;
      }
      if (isWhatsappInstalled && isWhatsapp4BInstalled) {
        askDialogRepost(
          path: shareFilesPath,
          context: context,
          type: type,
          shareOneFile: false,
        );
      } else {
        await WhatsappShare.shareFile(
          package:
          isWhatsappInstalled ? Package.whatsapp : Package.businessWhatsapp,
          phone: '+',
          filePath: shareFilesPath,
        );
      }
    } else {
      await Share.shareFiles(shareFilesPath).then(
            (value) {
          shareFilesPath.clear();
        },
      );
    }
  }


  static InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

  void getAd() {
    emit(GetAdState());
  }

  getInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // print('Running on ${androidInfo.toString()}');
  }
}

