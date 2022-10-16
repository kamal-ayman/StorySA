import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../ad_helper.dart';
import '../../shared/components/components.dart';


class PhotosSlider extends StatefulWidget {
  final List photos;
  final int id;

  PhotosSlider({Key? key, required this.photos, required this.id})
      : super(key: key);

  @override
  State<PhotosSlider> createState() => _PhotosSliderState(id);
}

class _PhotosSliderState extends State<PhotosSlider> {
  PhotoViewControllerBase? photoViewControllerBase;

  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  CarouselController? carouselController;
  int id;
  final PageController pageController;

  _PhotosSliderState(this.id)
      : pageController = PageController(initialPage: id);

  final GetAdClass _getAdClass = GetAdClass();


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _getAdClass.getAd(context);
  }

  @override
  void dispose() {

    super.dispose();
    _getAdClass.bannerAd!.dispose();
    // StoryCubit.get(context).bannerAd?.dispose();
    _getAdClass.bannerAd!.dispose();
    // StoryCubit.get(context).interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {


    _getAdClass.getAd(context);

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
                  itemCount: cubit.photos.length,
                  builder: (context, index) {
                    id = index;
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(cubit.photos[index]),
                      minScale: PhotoViewComputedScale.contained * .8,
                      maxScale: PhotoViewComputedScale.contained * 2,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                  child: FabShareButton(
                    cubit: cubit,
                    visible: true,
                    replyFun: () {
                      cubit.shareOneFile(
                          path: widget.photos[id].path, toWhatsapp: true, context: context);
                    },
                    shareFun: () {
                      cubit.shareOneFile(
                          path: widget.photos[id].path, toWhatsapp: false);
                    },
                    downloadFun: () {
                      cubit.saveStory(widget.photos[id]);
                    },
                  ),
                ),
                if (_getAdClass.bannerAd != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
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
