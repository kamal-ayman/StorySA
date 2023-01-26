import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_store/open_store.dart';
import 'package:whatsapp_story/shared/components/components.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../ad_helper.dart';
import '../modules/open_chat_screen/open_chat_screen.dart';
import '../modules/settings/settings.dart';
import '../shared/components/constants.dart';
import '../shared/cubit/cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GetAdClass _getAdClass = GetAdClass();
  final GetAdClass _getAdClass0 = GetAdClass();

  @override
  void initState() {
    super.initState();
    _getAdClass.getAd(context);
    _getAdClass0.getAd(context);
    _tabController = TabController(
        vsync: this,
        length: 2,
        animationDuration: const Duration(milliseconds: 100));
    _tabController.addListener(() {
      StoryCubit.get(context).changeIndex(_tabController.index);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _getAdClass.bannerAd!.dispose();
    _getAdClass0.bannerAd!.dispose();
    _getAdClass.interstitialAd!.dispose();
    _getAdClass0.interstitialAd!.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
            },
          );
          setState(() {
            StoryCubit.get(context).interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        if (cubit.interstitialAd == null) {
          _loadInterstitialAd();
        }
        return WillPopScope(
          onWillPop: () async {
            if (cubit.selectMode) {
              cubit.disableSelectMode();
              return false;
            } else if (cubit.index != 0) {
              _tabController.animateTo(0);
              return false;
            }
            return true;
          },
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor:
                  isDark ? const Color(0xff1e2d31) : const Color(0xff008066),
              key: _scaffoldKey,
              drawerEdgeDragWidth: 40,
              body: NestedScrollView(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      elevation: 0,
                      pinned: true,
                      snap: true,
                      floating: true,
                      title: const Text('Story SA'),
                      leading: leadingIcon(cubit, _scaffoldKey),
                      actions: [
                        if (!cubit.selectMode)
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const OpenChatScreen()),
                                );
                              },
                              icon: const Icon(CupertinoIcons.chat_bubble_text),
                              splashRadius: 20,
                              tooltip: 'open chat'),
                        if (cubit.selectMode)
                          Center(
                              child: Text(
                                  '${_tabController.index == 0 ? cubit.selectedPhotosID.length : cubit.selectedVideosID.length}',
                                  style:
                                      Theme.of(context).textTheme.titleLarge!.copyWith(
                                        color: Colors.white
                                      ))),
                        if (cubit.selectMode)
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                splashRadius: 20,
                                splashColor: Colors.transparent,
                                onPressed: () {
                                  cubit.isSelectAll
                                      ? cubit.unSelectAll()
                                      : cubit.selectAll();
                                },
                                tooltip: cubit.isSelectAll
                                    ? 'deselect all'
                                    : 'select all',
                                icon: Icon(
                                  cubit.isSelectAll
                                      ? CupertinoIcons.square_stack_3d_up_fill
                                      : CupertinoIcons.square_stack_3d_up,
                                ),
                                color: isDark
                                    ? const Color(0xff83979d)
                                    : Colors.white,
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        const SizedBox(width: 10),
                      ],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(65),
                        child: TabBar(
                          indicatorWeight: 3,
                          indicatorColor: Colors.white,
                          indicator: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadiusDirectional.circular(70),
                          ),
                          padding: const EdgeInsets.all(8),
                          overlayColor:
                              MaterialStateProperty.all(Colors.white10),
                          splashBorderRadius: BorderRadius.circular(70),
                          splashFactory: NoSplash.splashFactory,
                          unselectedLabelColor: Colors.white54,
                          controller: _tabController,
                          tabs: const [
                            Tab(icon: Icon(CupertinoIcons.photo_on_rectangle)),
                            Tab(icon: Icon(Icons.video_library_rounded)),
                            // Tab(icon: Icon(CupertinoIcons.square_arrow_down)),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: Container(
                  color: isDark ? const Color(0xff0f1c1e) : Colors.white,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: cubit.screens.map((e) {
                          return RefreshIndicator(
                            color: isDark
                                ? const Color(0xff1e2d31)
                                : const Color(0xff008066),
                            onRefresh: () async {
                              if (_tabController.animation!.value % 1 == 0) {
                                await cubit.statusPath();
                              }
                            },
                            child: CustomScrollView(
                              slivers: [
                                e,
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      fabShareButton(
                        bottom: _getAdClass.bannerAd != null
                            ? _getAdClass.bannerAd!.size.height.toDouble()
                            : 0.0,
                        cubit: cubit,
                        visible: cubit.selectedPhotosID.isNotEmpty ||
                            cubit.selectedVideosID.isNotEmpty,
                        replyFun: () {
                          cubit.shareFiles(
                            context: context,
                            type: _tabController.index == 0
                                ? FileType.Photos
                                : FileType.Videos,
                            shareToWhatsApp: true,
                          );
                        },
                        shareFun: () {
                          share(
                              isToWhatsApp: false,
                              cubit: cubit,
                              index: _tabController.index,
                              context: context);
                        },
                        downloadFun: () {
                          cubit.index == 0
                              ? cubit.saveSelectStory(FileType.Photos)
                              : cubit.saveSelectStory(FileType.Videos);
                        },
                      ),
                      if (_getAdClass.bannerAd != null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: _getAdClass.bannerAd!.size.width.toDouble(),
                            height:
                                _getAdClass.bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _getAdClass.bannerAd!),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              drawer: Drawer(
                backgroundColor:
                    isDark ? const Color(0xff1e2d31) : Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff1e2d31)
                              : const Color(0xff008066),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          verticalDirection: VerticalDirection.up,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Story Saver App',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xff83979d)
                                        : Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/icon/icon.png',
                                  width: 50,
                                  height: 50,
                                  filterQuality: FilterQuality.low,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      customListTile(
                        selected: primaryWhatsApp,
                        leading: Icons.whatsapp,
                        onTap: () {
                          Navigator.pop(context);
                          if (!primaryWhatsApp) {
                            if (cubit.isWhatsapp4BInstalled) {
                              cubit.chanePathStatuses(
                                  isNormal: !primaryWhatsApp);
                            } else {
                              customSnackBar(true);
                            }
                          }
                        },
                        title: 'WhatsApp',
                      ),
                      customListTile(
                        selected: !primaryWhatsApp,
                        leading: Icons.whatsapp,
                        onTap: () async {
                          Navigator.pop(context);
                          if (primaryWhatsApp) {
                            if (cubit.isWhatsapp4BInstalled) {
                              cubit.chanePathStatuses(
                                  isNormal: !primaryWhatsApp);
                            } else {
                              customSnackBar(false);
                            }
                          }
                        },
                        title: 'WhatsApp Business',
                      ),
                      customListTile(
                        leading: CupertinoIcons.settings,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        title: 'Settings',
                      ),
                      customListTile(
                        leading: CupertinoIcons.info,
                        onTap: () {
                          Navigator.pop(context);
                          aboutUsDialog(context: context);
                        },
                        title: 'About Us',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  customSnackBar(bool isWhatsapp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isWhatsapp
                    ? const Text('Whatsapp Not found!')
                    : const Text('Whatsapp4B Not found!'),
              ],
            ),
            InkWell(
              onTap: () {
                OpenStore.instance.open(
                  androidAppBundleId: isWhatsapp
                      ? 'com.whatsapp'
                      : 'com.whatsapp.w4b', // Android app bundle package name
                );
              },
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadiusDirectional.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Go To Google Play'),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
