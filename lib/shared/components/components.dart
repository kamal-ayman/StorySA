import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import '../../ad_helper.dart';
import '../../modules/photos/slider_photos.dart';
import '../../modules/videos/open_video_screen.dart';

Future<bool?> toastShow({
  required String text,
  required ToastStates state,
}) =>
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: chooseToastColor(state),
        textColor: Colors.white,
        fontSize: 16.0);

enum ToastStates { SUCCESS, ERROR, WARNING }

chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}

int adcount = 0;

Widget buildItem({
  required context,
  required StoryCubit cubit,
  required double width,
  required Map<int, File> e,
  required ItemState state,
}) {
  bool checkSelectedItem = false;
  if (state == ItemState.Video) {
    checkSelectedItem = cubit.selectedVideos[e.keys.first]!;
  } else {
    checkSelectedItem = cubit.selectedPhotos[e.keys.first]!;
  }

  return InkWell(
    child: Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(checkSelectedItem ? 10 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: checkSelectedItem ? Clip.hardEdge : Clip.none,
            width: width,
            height: width + 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                checkSelectedItem ? 20 : 0,
              ),
            ),
            child: e[e.keys.first]!.path == ''
                ? Container(color: Colors.black)
                : Image.file(e[e.keys.first]!, fit: BoxFit.cover),
          ),
        ),
        AnimatedContainer(
          transform: Matrix4.rotationZ(checkSelectedItem ? 0 : .1),
          padding: EdgeInsets.all(checkSelectedItem ? 8 : 0),
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: checkSelectedItem
                          ? Colors.white
                          : Colors.white.withOpacity(0),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: checkSelectedItem
                          ? isDark
                              ? const Color(0xff00a881)
                              : const Color(0xff23d363)
                          : isDark
                              ? const Color(0xff00a881).withOpacity(0)
                              : const Color(0xff23d363).withOpacity(0),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (state == ItemState.Video)
          Align(
            alignment: Alignment.center,
            child: Container(
              color: checkSelectedItem
                  ? Colors.blue.withOpacity(0.05)
                  : Colors.blue.withOpacity(0),
              child: const Icon(
                CupertinoIcons.play_fill,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
      ],
    ),
    onTap: () {
      if (!cubit.selectMode) {
        adcount++;
        print(adcount);
        if (adcount % 5 == 0) {
          print(adcount);
          cubit.interstitialAd?.show().then((value) {
            cubit.interstitialAd = null;
          });
        }
        cubit.interstitialAd?.show().then((value) {
          cubit.interstitialAd;
        });
      }

      if (state == ItemState.Video) {
        if (cubit.selectMode) {
          cubit.selectedVideo(e.keys.first);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                file: cubit.videos[e.keys.first],
                id: e.keys.first,
              ),
            ),
          );
        }
      } else {
        if (cubit.selectMode) {
          cubit.selectedPhoto(e.keys.first);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PhotosSlider(
                photos: cubit.photos,
                id: e.keys.first,
              ),
            ),
          );
        }
      }
    },
    onLongPress: () {
      if (state == ItemState.Video) {
        cubit.selectedVideo(e.keys.first);
      } else {
        cubit.selectedPhoto(e.keys.first);
      }
    },
    highlightColor: Colors.transparent,
  );
}

enum ItemState { Video, Image, Saved }

Widget buildAllItems(
    double width, BuildContext context, StoryCubit cubit, ItemState state) {
  return SliverGrid.count(
    crossAxisCount: 2,
    mainAxisSpacing: 5.0,
    crossAxisSpacing: 5.0,
    childAspectRatio: 1,
    children: state == ItemState.Video
        ? cubit.videoThumbs.map((e) {
            return buildItem(
                context: context,
                cubit: cubit,
                width: width,
                e: e,
                state: state);
          }).toList()
        : cubit.photosThumbs.map((e) {
            return buildItem(
                context: context,
                cubit: cubit,
                width: width,
                e: e,
                state: state);
          }).toList(),
  );
}

Widget permissionDeniedView(StoryCubit cubit) {
  return SliverFillRemaining(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Permission Denied',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[700],
            ),
          ),
          TextButton(
            child: const Text('Click to get Permission'),
            onPressed: () {
              cubit.getStoragePermission();
            },
          ),
        ],
      ),
    ),
  );
}

void share(
    {required StoryCubit cubit,
    required bool isToWhatsApp,
    required index,
    required context}) {
  if (cubit.index == 0) {
    cubit.shareFiles(
      type: FileType.Photos,
      shareToWhatsApp: isToWhatsApp,
      context: context,
    );
  } else if (cubit.index == 1) {
    cubit.shareFiles(
      type: FileType.Videos,
      shareToWhatsApp: isToWhatsApp,
      context: context,
    );
  }
}

Widget FabShareButton({
  required bool visible,
  required StoryCubit cubit,
  required replyFun,
  required shareFun,
  required downloadFun,
  required double bottom,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: bottom + 10.0, right: 20),
    child: SpeedDial(
      // useRotationAnimation: true,
      overlayOpacity: 0,
      direction: SpeedDialDirection.up,
      icon: Icons.share,
      activeIcon: CupertinoIcons.clear,
      foregroundColor: isDark ? const Color(0xff83979d) : Colors.white,
      backgroundColor:
          isDark ? const Color(0xff0f1c1e) : const Color(0xff00a881),
      visible: visible,
      curve: Curves.linear,
      spacing: 15,
      children: [
        customSpeedDial(
          icon: CupertinoIcons.reply,
          label: 'Repost',
          onTap: replyFun,
        ),
        customSpeedDial(
          icon: CupertinoIcons.share,
          label: 'Share',
          onTap: shareFun,
        ),
        customSpeedDial(
          icon: CupertinoIcons.square_arrow_down_on_square,
          label: 'Save',
          onTap: downloadFun,
        ),
      ],
    ),
  );
}

SpeedDialChild customSpeedDial({
  required String label,
  required onTap,
  required IconData icon,
}) {
  return SpeedDialChild(
      child: Icon(icon, color: isDark ? const Color(0xff83979d) : Colors.white),
      backgroundColor:
          isDark ? const Color(0xff1e2d31) : const Color(0xff22d363),
      onTap: onTap,
      label: label,
      labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xff83979d) : Colors.white,
          fontSize: 16.0),
      labelBackgroundColor:
          isDark ? const Color(0xff1e2d31) : const Color(0xff22d363));
}

AppBar CustomAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    leading: IconButton(
      splashRadius: 20,
      splashColor: Colors.transparent,
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(CupertinoIcons.back),
    ),
    backgroundColor: isDark ? const Color(0xff1e2d31) : const Color(0xff008066),
    foregroundColor: Colors.white,
  );
}

Widget leadingIcon(StoryCubit cubit, scaffoldKey) {
  return IconButton(
    visualDensity: VisualDensity.compact,
    splashColor: Colors.transparent,
    splashRadius: 20,
    tooltip: cubit.selectMode ? 'disable select mode' : 'Menu',
    icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key != const ValueKey('icon1')
                  ? Tween<double>(begin: .50, end: 0).animate(anim)
                  : Tween<double>(begin: 0, end: .50).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
        child: cubit.selectMode
            ? const Icon(
                CupertinoIcons.back,
                key: ValueKey('icon2'),
              )
            : const Icon(
                Icons.menu,
                key: ValueKey('icon1'),
              )),
    onPressed: () {
      if (cubit.selectMode)
        cubit.disableSelectMode();
      else
        scaffoldKey.currentState!.openDrawer();
    },
  );
}

Widget CustomListTile({
  required String title,
  required IconData leading,
  required onTap,
  bool? selected,
}) {
  return ListTile(
    selected: selected ?? false,
    selectedColor: Colors.green,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
        const Icon(Icons.navigate_next_rounded),
      ],
    ),
    leading: Icon(leading, size: 26),
    textColor: isDark ? Colors.white : Colors.grey[700],
    iconColor: isDark ? Colors.white : Colors.grey[700],
    tileColor: isDark ? Colors.black12 : Colors.grey[100],
    onTap: onTap,
  );
}

Future<void> aboutUsDialog({
  required context,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Color? textColor = isDark ? Colors.white : Colors.grey[700];
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Story SA',
              style: TextStyle(
                color: textColor,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Image.asset(
              'assets/icon/icon.png',
              height: 35,
              width: 35,
              filterQuality: FilterQuality.low,
            )
          ],
        ),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Story Saver App, there is more amazing updates will coming soon!\nYou can follow me from links below:\n',
                style: TextStyle(color: textColor),
              ),
              defaultLinkButton(
                  color: Colors.blue,
                  title: 'LinkedIn',
                  link: 'https://www.linkedin.com/in/kamal-ayman/'),
              defaultLinkButton(
                  color: Colors.blue.shade900,
                  title: 'Facebook',
                  link: 'https://www.facebook.com/kamalayman159/'),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> askDialogRepost({
  required context,
  required shareOneFile,
  required type,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context0) {
      return AlertDialog(
        title: Text(
          'Replay to',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[700],
          ),
        ),
        backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              defaultSelectButton(
                context: context,
                title: 'WhatsApp',
                id: 0,
                type: type,
                shareOneFile: shareOneFile,
              ),
              const SizedBox(height: 8),
              defaultSelectButton(
                context: context,
                title: 'Business WhatsApp',
                id: 1,
                type: type,
                shareOneFile: shareOneFile,
              ),
            ],
          ),
        ),
        // actions: [
        //   TextButton(
        //     child: const Text('once'),
        //     onPressed: () {
        //       // cubit.getImage(type: type);
        //       Navigator.of(context).pop();
        //     },
        //   ),
        //   TextButton(
        //     child: const Text('always'),
        //     onPressed: () {
        //       // cubit.setAlways(cubit.last);
        //       // cubit.getImage(type: type);
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      );
    },
  );
}

Widget defaultSelectButton({
  required BuildContext context,
  required String title,
  required int id,
  required type,
  required bool shareOneFile,
}) =>
    MaterialButton(
      color: Colors.green,
      height: 60,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      onPressed: () {
        Navigator.pop(context);
        if (shareOneFile) {
          StoryCubit.get(context).shareOneFile(
            context: context,path: '',
            toWhatsapp: true,
            whatsappType:
                id == 0 ? WhatsappType.Whatsapp : WhatsappType.BusinessWhatsapp,
          );
        } else {
          StoryCubit.get(context).shareFiles(
            type: type,
            context: context,
            shareToWhatsApp: true,
            whatsappType:
                id == 0 ? WhatsappType.Whatsapp : WhatsappType.BusinessWhatsapp,
          );
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.whatsapp, color: Colors.white, size: 30),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );

Widget defaultLinkButton({
  required String title,
  required String link,
  required Color color,
}) {
  return MaterialButton(
    onPressed: () {
      launch(link);
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
    height: 40,
    color: color,
  );
}

Widget noStoryShow() {
  return SliverFillRemaining(
    child: Center(
      child: Text(
        'No Story Yet\nOpen some stories on whatsapp',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color:
              isDark ? Colors.white.withOpacity(.4) : const Color(0xff008066),
        ),
      ),
    ),
  );
}

class GetAdClass {
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

  void getAd(context) {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          StoryCubit.get(context).getAd();
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }
}
