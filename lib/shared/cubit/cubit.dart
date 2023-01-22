import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import 'package:whatsapp_story/shared/components/components.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../modules/photos/photos_screen.dart';
import '../../modules/saved_screen/saved_screen.dart';
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
      this.index = index;
      disableSelectMode();
      emit(ChangeIndexState());
    }
  }

  List<Widget> widgets = const [
    PhotosScreen(),
    VideosScreen(),
    // SavedScreen(),
  ];

  Future getStoragePermission() async {
    permissionStatus = await Permission.storage.request().then((value) {
      if (value.isGranted) {
        localPath();
      } else {
        emit(PermissionDeniedState());
      }
      return value;
    });
  }

  disableSelectMode() {
    selectMode = false;
    select_all = false;
    unSelectAll();
  }

  List<File> photos = [];
  List<Map<int, File>> photosThumbs = [];
  List<File> videos = [];
  List<Map<int, File>> videoThumbs = [];
  int photoId = 0;
  int videoId = 0;
  Map<int, bool> selectedPhotos = {};
  Map<int, bool> selectedPhotosNow = {};
  Map<int, bool> selectedVideos = {};
  Map<int, bool> selectedVideosNow = {};

  bool selectMode = false;

  chanePathStatuses({required bool isNormal}) {
    normalWhatsApp = isNormal;
    CacheHelper.saveData(key: 'normalWhatsApp', value: normalWhatsApp);
    localPath();
    emit(ChangePathStatusesState());
  }


  Future checkPermissions(context) async {

    var status = await Permission.manageExternalStorage.status;
    print("loading status");
    if (status.isGranted) {
      await Directory(saveFolder).create(recursive: true);
      print("status is Granted");
    }
    else if (status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    }
    else if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    }
    else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please add permission for app to manage external storage'),
        ),
      );
    }
  }

  localPath() async {
    emit(AppLoadingState());
    // clear all data.
    photos.clear();
    videos.clear();
    videoThumbs.clear();
    photosThumbs.clear();
    photoId = 0;
    videoId = 0;
    selectedPhotos.clear();
    selectedPhotosNow.clear();
    selectedVideos.clear();
    selectedVideosNow.clear();
    selectMode = false;
    // set default whatsAppStatusesPath WhatsApp
    String whatsAppStatusesPath =
        '/storage/emulated/0/WhatsApp/Media/.Statuses';
    String whatsAppBusinessStatusesPath =
        '/storage/emulated/0/WhatsApp Business/Media/.Statuses';
    // get unsorted data

    await Directory(normalWhatsApp
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
    await Directory(normalWhatsApp
            ? whatsAppStatusesPath
            : whatsAppBusinessStatusesPath)
        .list()
        .toList()
        .then((value) {
      for (int i = 0; i < value.length; i++) {
        var element = value[i];
        String type = element.path.split('.').last;
        if (type == 'jpg') {
          photos.add(element as File);
          selectedPhotos.addAll({photoId: false});
          photoId++;
        } else if (type == 'mp4') {
          videos.add(element as File);
          selectedVideos.addAll({videoId: false});
          videoId++;
        }
      }
    }).catchError((e) {
      print(e.toString());
    });
    // emit(UpdateThumbnailState());
    // sort images by date
    File file;
    for (int i = 0; i < photos.length; i++) {
      for (int j = i + 1; j < photos.length; j++) {
        if (FileStat.statSync(photos[i].path)
            .modified
            .isBefore(FileStat.statSync(photos[j].path).modified)) {
          file = photos[i];
          photos[i] = photos[j];
          photos[j] = file;
        }
      }
      photosThumbs.add({i: photos[i]});
    }

    // sort videos by date
    var pathThump =
        '/storage/emulated/0/StorySA/.thumbs${normalWhatsApp ? 'WhatsApp' : 'WhatsApp Business'}';
    await Directory(pathThump).create(recursive: true);
    for (int i = 0; i < videos.length; i++) {
      for (int j = i + 1; j < videos.length; j++) {
        if (FileStat.statSync(videos[i].path)
            .modified
            .isBefore(FileStat.statSync(videos[j].path).modified)) {
          file = videos[i];
          videos[i] = videos[j];
          videos[j] = file;
        }
      }
    }
    for (int ii = 0; ii < videos.length; ii++) {
      videoThumbs.add({ii: File('')});
    }
    getVideoThumbnail();
    emit(AppSuccessState());
  }

  getVideoThumbnail() async{
    var pathThump =
        '/storage/emulated/0/StorySA/.thumbs${normalWhatsApp ? 'WhatsApp' : 'WhatsApp Business'}';
    for (int i = 0; i < videos.length; i++) {
      String testPath = pathThump +
          '/' +
          videos[i].path.split('/').last.split('.').first +
          '.jpg';
      if (File(testPath).existsSync()) {
        // videoThumbs.replaceRange(i, i+1,[
        //   {i: File(testPath)}
        // ]);
        print('founded');
        videoThumbs[i] = {i: File(testPath)};
        emit(UpdateThumbnailState());
      } else {
        print('start');
        try {
          await VideoThumbnail.thumbnailFile(
            imageFormat: ImageFormat.JPEG,
            video: videos[i].path,
            thumbnailPath: pathThump,
            maxHeight: 256,
            quality: 100,
          ).then((value) {
            print('value:');
            print(value);
            videoThumbs[i] = {i: File(testPath)};
            emit(UpdateThumbnailState());
          }).catchError((e) {
            print('erorr0: $e');
          });
        } catch (e) {
          print('error');
          print(e.toString());
        }
      }
    }

  }

  selectedPhoto(int id) {
    selectedPhotos[id] = !selectedPhotos[id]!;
    if (selectedPhotos[id]!) {
      selectedPhotosNow.addAll({id: true});
      if (selectedPhotosNow.length == photos.length) {
        select_all = true;
      }
    } else {
      selectedPhotosNow.remove(id);
      select_all = false;
    }
    if (selectedPhotosNow.isEmpty) {
      selectMode = false;
    } else {
      selectMode = true;
    }
    emit(SelectPhotoState());
  }

  selectedVideo(int id) {
    selectedVideos[id] = !selectedVideos[id]!;
    if (selectedVideos[id]!) {
      selectedVideosNow.addAll({id: true});
      if (selectedVideosNow.length == videos.length) {
        select_all = true;
      }
    } else {
      selectedVideosNow.remove(id);
      select_all = false;
    }
    if (selectedVideosNow.isEmpty) {
      selectMode = false;
    } else {
      selectMode = true;
    }
    emit(SelectVideoState());
  }

  bool select_all = false;

  selectAll({required bool s}) {
    select_all = s;
    if (index == 0) {
      if (select_all) {
        for (int i = 0; i < selectedPhotos.length; i++) {
          selectedPhotos[i] = true;
          selectedPhotosNow.addAll({i: true});
        }
      } else {
        for (int i = 0; i < selectedPhotos.length; i++) {
          selectedPhotos[i] = false;
          selectedPhotosNow.remove(i);
        }
      }
    } else {
      if (select_all) {
        for (int i = 0; i < selectedVideos.length; i++) {
          selectedVideos[i] = true;
          selectedVideosNow.addAll({i: true});
        }
      } else {
        for (int i = 0; i < selectedVideos.length; i++) {
          selectedVideos[i] = false;
          selectedVideosNow.remove(i);
        }
      }
    }
    emit(SelectAllState());
  }

  unSelectAll() {
    if (index == 0) {
      selectedPhotos.forEach((key, value) {
        selectedPhotos[key] = false;
      });
      selectedPhotosNow.clear();
      emit(UnSelectPhotoState());
    } else {
      selectedVideosNow.forEach((key, value) {
        selectedVideos[key] = false;
      });
      selectedVideosNow.clear();
      emit(UnSelectVideoState());
    }
  }

  saveSelectPhotoStory() async {
    await Directory(saveFolder).create(recursive: true);
    selectedPhotosNow.forEach((key, value) {
      photos[key].copy(saveFolder + '/' + photos[key].path.split('/').last);
    });
    disableSelectMode();
    toastShow(
      text: 'Saved Successfully',
      state: ToastStates.SUCCESS,
    );
  }

  saveSelectVideoStory() async {
    await Directory(saveFolder).create(recursive: true);
    selectedVideosNow.forEach((key, value) {
      videos[key].copy(saveFolder + '/' + videos[key].path.split('/').last);
    });
    disableSelectMode();
    toastShow(
      text: 'Saved Successfully',
      state: ToastStates.SUCCESS,
    );
  }

  saveStory(File file) async {
    await Directory(saveFolder).create(recursive: true);
    String newFile = saveFolder + '/' + file.path.split('/').last;
    file.copy(newFile).then((value) {
      toastShow(text: 'Story Saved Successfully', state: ToastStates.SUCCESS);
      emit(AppSaveSuccessState());
    }).catchError((e){
      emit(AppSaveErrorState());
    });
  }

  late bool isWhatsappInstalled;
  late bool isBusinessWhatsappInstalled;

  Future checkInstalledWhatsApp() async {
    await WhatsappShare.isInstalled(package: Package.whatsapp).then((value) {
      isWhatsappInstalled = value!;
    }).catchError((e) {
      isWhatsappInstalled = false;
    });
    await WhatsappShare.isInstalled(package: Package.businessWhatsapp)
        .then((value) {
      isBusinessWhatsappInstalled = value!;
    }).catchError((e) {
      isBusinessWhatsappInstalled = false;
    });
    // print('isWhatsappInstalled' + isWhatsappInstalled.toString());
    // print('isWhatsappInstalled1111' + isBusinessWhatsappInstalled.toString());
  }


  Future shareOneFile(
      {String? path,
      required bool toWhatsapp,
      WhatsappType? whatsappType,
      context}) async {
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
    if (isWhatsappInstalled && isBusinessWhatsappInstalled) {
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
    shareFilesPathLocal == null?shareFilesPath.clear(): shareFilesPath = shareFilesPathLocal;
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
      selectedPhotosNow.keys.forEach((element) {
        shareFilesPath.add(photos[element].path);
      });
    } else if (type == FileType.Videos) {
      selectedVideosNow.keys.forEach((element) {
        shareFilesPath.add(videos[element].path);
      });
    }
    disableSelectMode();

    if (shareToWhatsApp) {
      await checkInstalledWhatsApp();
      print('$isWhatsappInstalled  $isBusinessWhatsappInstalled');
      if (!isWhatsappInstalled && !isBusinessWhatsappInstalled) {
        toastShow(
            text: 'Please install WhatsApp first!', state: ToastStates.ERROR);
        return;
      }
      if (isWhatsappInstalled && isBusinessWhatsappInstalled) {
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

  defaultCountry({String? defaultCountryCode}) {
    if (defaultCountryCode != null) {
      CacheHelper.saveData(key: 'CountryCode', value: defaultCountryCode);
    } else {
      return CacheHelper.getData(key: 'CountryCode');
    }
  }

  String? phoneNumber;
  String? message;

  Future<void> openChat(context) async {
    if (phoneNumber != null) {
      var whatsappUrl =
          "whatsapp://send?phone=$phoneNumber&text=${message ?? ''}";
      launch(whatsappUrl).then((value) {}).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('there is no whatsapp installed yet on your device'),
          ),
        );
      });
      // message = null;
    }
  }

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
    print('Running on ${androidInfo.toMap()}');
  }
}

enum FileType { Photos, Videos }

enum WhatsappType { Whatsapp, BusinessWhatsapp }
