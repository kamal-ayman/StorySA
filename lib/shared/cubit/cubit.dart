import 'dart:io';
import 'package:appcheck/appcheck.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future getStoragePermission() async {
    permissionStatus = await Permission.storage.request().then((value) {
      if (value.isGranted) {
        statusPath();
      } else {
        emit(PermissionDeniedState());
      }
      return value;
    });
  }

  chanePathStatuses({required bool isNormal}) {
    primaryWhatsApp = isNormal;
    CacheHelper.saveData(key: 'normalWhatsApp', value: primaryWhatsApp);
    statusPath();
    emit(ChangePathStatusesState());
  }

  Future checkPermissions(context) async {
    var status = await Permission.manageExternalStorage.status;
    print("loading status");
    if (status.isGranted) {
      await Directory(saveFolder).create(recursive: true);
      print("status is Granted");
    } else if (status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    } else if (status.isDenied) {
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
  List<File> videosThumbs = [];

  statusPath() async {
    disableSelectMode();
    emit(AppStatusLoadingState());
    // clear all data.

    photoID = 0;
    photos.clear();
    selectedPhotosID.clear();
    unselectedPhotosID.clear();

    videoID = 0;
    videos.clear();
    selectedVideosID.clear();
    unselectedVideosID.clear();
    videosThumbs.clear();

    // set default whatsAppStatusesPath WhatsApp
    // String whatsAppStatusesPath =
    //     '/storage/emulated/0/WhatsApp/Media/.Statuses';

    String whatsAppStatusesPath =
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Video/.Statuses';
    String whatsAppBusinessStatusesPath =
        '/storage/emulated/0/WhatsApp Business/Media/.Statuses';

    await Directory(primaryWhatsApp
            ? whatsAppStatusesPath
            : whatsAppBusinessStatusesPath)
        .exists()
        .then((value) {
      if (!value) {
        String newPath = 'Android/media/com.whatsapp/WhatsApp';
        whatsAppStatusesPath = '/storage/emulated/0/$newPath/Media/.Statuses';
        whatsAppBusinessStatusesPath =
            '/storage/emulated/0/$newPath Business/Media/.Statuses';
      }
    });

    // get unsorted data
    await Directory(primaryWhatsApp
            ? whatsAppStatusesPath
            : whatsAppBusinessStatusesPath)
        .list()
        .forEach((file) {
      String type = file.path.split('.').last;
      if (type == 'jpg') {
        photos.addAll({photoID: FileModel(file: file as File)});
        unselectedPhotosID.add(photoID++);
      } else if (type == 'mp4') {
        videos.addAll({videoID: FileModel(file: file as File)});
        unselectedVideosID.add(videoID++);
      }
    });

    File file;

    // sort images by date
    for (int i = 0; i < photos.length; i++) {
      for (int j = i + 1; j < photos.length; j++) {
        if (FileStat.statSync(photos[i]!.file.path)
            .modified
            .isBefore(FileStat.statSync(photos[j]!.file.path).modified)) {
          file = photos[i]!.file;
          photos[i]!.file = photos[j]!.file;
          photos[j]!.file = file;
        }
      }
    }

    // sort videos by date
    for (int i = 0; i < videos.length; i++) {
      for (int j = i + 1; j < videos.length; j++) {
        if (FileStat.statSync(videos[i]!.file.path)
            .modified
            .isBefore(FileStat.statSync(videos[j]!.file.path).modified)) {
          file = videos[i]!.file;
          videos[i]!.file = videos[j]!.file;
          videos[j]!.file = file;
        }
      }
      videosThumbs.add(File(''));
    }

    getVideoThumbnail().then((value) {
      emit(AppStatusSuccessState());
    });

  }

  Future getVideoThumbnail() async {
    Directory pathThump = Directory(
        '${(await getTemporaryDirectory()).path}/.thumbs${primaryWhatsApp ? 'WhatsApp' : 'WhatsApp Business'}');
    pathThump.create(recursive: true);

    // await pathThump.list().forEach((element) {
    //   element.delete();
    //   // print(element);
    // });

    String testPath;
    for (int i = 0; i < videos.length; i++) {
      testPath = pathThump.path +
          '/' +
          videos[i]!.file.path.split('/').last.split('.').first +
          '.jpg';
      if (File(testPath).existsSync()) {
        videosThumbs[i] = File(testPath);
      } else {
        await VideoThumbnail.thumbnailFile(
          imageFormat: ImageFormat.JPEG,
          video: videos[i]!.file.path,
          thumbnailPath: pathThump.path,
          maxHeight: 210,
          quality: 100,
        ).then((value) {
          videosThumbs[i] = File(testPath);
        }).catchError((e) {
          print('erorr0: $e');
        });
      }
      emit(UpdateThumbnailState());
    }
  }

  bool isSelectAll = false;

  selectAll() {
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
    isSelectAll = true;
    emit(SelectAllState());
  }

  bool selectMode = false;

  disableSelectMode() {
    selectMode = false;
    unSelectAll();
  }

  unSelectAll() {
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
    isSelectAll = false;
    emit(UnSelectAllState());
  }

  selectItem(int id) {
    selectMode = true;
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
    emit(SelectItemState());
  }

  unSelectItem(int id) {
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
    isSelectAll = false;
    emit(UnSelectItemState());
  }

  saveSelectStory(FileType type) async {
    if (type == FileType.Photos) {
      await Directory(saveFolder).create(recursive: true);
      for (int i in selectedPhotosID) {
        await photos[i]!
            .file
            .copy(saveFolder + '/' + photos[i]!.file.path.split('/').last)
            .catchError((e) {
          emit(AppSaveErrorState());
        });
      }
    } else {
      for (int i in selectedVideosID) {
        await videos[i]!
            .file
            .copy(saveFolder + '/' + videos[i]!.file.path.split('/').last)
            .catchError((e) {
          emit(AppSaveErrorState());
        });
      }
    }
    toastShow(
      text: 'Saved Successfully',
      state: ToastStates.SUCCESS,
    );
    disableSelectMode();
  }

  saveCurrentStory(File file) async {
    await Directory(saveFolder).create(recursive: true);
    String newFile = saveFolder + '/' + file.path.split('/').last;
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
        package: whatsappType == WhatsappType.Whatsapp
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
        type: FileType.Photos,
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
        package: whatsappType == WhatsappType.Whatsapp
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
    if (type == FileType.Photos) {
      for (var element in selectedPhotosID) {
        shareFilesPath.add(photos[element]!.file.path);
      }
    } else if (type == FileType.Videos) {
      for (var element in selectedVideosID) {
        shareFilesPath.add(videos[element]!.file.path);
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

  void switchShowOptions() {
    showOptions = !showOptions;
    emit(ShowOptionState());
  }

  bool showOptions = false;

  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

  void getAd() {
    emit(GetAdState());
  }

  Map<int, bool> select = {0: true, 1: false};
  int last = 0;

  selectButtonDialog({required int id}) {
    if (last != id) {
      select[id] = true;
      select[last] = false;
      last = id;
      emit(SelectButtonDialogState());
    }
  }

  getInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.toString()}');
  }
}

enum FileType { Photos, Videos }

enum WhatsappType { Whatsapp, BusinessWhatsapp }
