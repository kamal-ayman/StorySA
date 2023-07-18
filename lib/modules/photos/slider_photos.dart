import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../shared/components/components.dart';


class PhotosSlider extends StatefulWidget {

  final int id;

  const PhotosSlider({Key? key, required this.id})
      : super(key: key);

  @override
  State<PhotosSlider> createState() => _PhotosSliderState(id);
}

class _PhotosSliderState extends State<PhotosSlider> {
  PhotoViewControllerBase? photoViewControllerBase;

  int id;
  final PageController pageController;


  _PhotosSliderState(this.id) : pageController = PageController(initialPage: id);

  final GetAdClass _getAdClass = GetAdClass();

  @override
  void initState() {
    pageController.addListener(() {
      if (id != pageController.page!.round()) {
        id = pageController.page!.round();
      }
      print(id);
    });
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _getAdClass.getAd(context);
  }

  @override
  void dispose() {

    super.dispose();
    _getAdClass.bannerAd!.dispose();
    StoryCubit.get(context).bannerAd?.dispose();
    _getAdClass.bannerAd!.dispose();
    StoryCubit.interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {


    // _getAdClass.getAd(context);

    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        return WillPopScope(
          onWillPop: () async{
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
            return true;
          },
          child: Scaffold(
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                PhotoViewGallery.builder(
                  pageController: pageController,
                  enableRotation: true,
                  itemCount: cubit.isShowSavedStatus ? cubit.savedPhotos.length:cubit.photos.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(cubit.isShowSavedStatus ? cubit.savedPhotos[index]!.file:cubit.photos[index]!.file),
                      minScale: PhotoViewComputedScale.contained * .8,
                      maxScale: PhotoViewComputedScale.contained * 2,
                    );
                  },
                ),
                fabShareButton(
                  bottom: _getAdClass.bannerAd != null?_getAdClass.bannerAd!.size.height.toDouble():0.0,
                  cubit: cubit,
                  visible: true,
                  replyFun: () {
                    cubit.shareOneFile(
                        path: cubit.isShowSavedStatus ? cubit.savedPhotos[id]!.file.path:cubit.photos[id]!.file.path,
                        toWhatsapp: true,
                        context: context);
                  },
                  shareFun: () {
                    cubit.shareOneFile(
                        path: cubit.isShowSavedStatus ? cubit.savedPhotos[id]!.file.path:cubit.photos[id]!.file.path, toWhatsapp: false);
                  },
                  downloadFun: () {
                    cubit.saveCurrentStory(cubit.isShowSavedStatus ? cubit.savedPhotos[id]!.file:cubit.photos[id]!.file);
                  },
                ),
                if (_getAdClass.bannerAd != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: _getAdClass.bannerAd!.size.width.toDouble(),
                      height: _getAdClass.bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _getAdClass.bannerAd!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
