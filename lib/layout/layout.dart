import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:whatsapp_story/shared/components/components.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../ad_helper.dart';
import '../modules/open_chat_screen/open_chat_screen.dart';
import '../modules/settings/settings.dart';
import '../shared/components/constants.dart';
import '../shared/cubit/cubit.dart';
import '../shared/network/local/cache_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

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

    _tabController = TabController(vsync: this, length: 2);
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

  bool status = false;

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
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
            key: _scaffoldKey,
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                RefreshIndicator(
                  color: isDark
                      ? const Color(0xff1e2d31)
                      : const Color(0xff008066),
                  edgeOffset: 125,
                  onRefresh: () async {
                    await cubit.localPath();
                  },
                  child: DefaultTabController(
                    animationDuration: const Duration(milliseconds: 100),
                    length: 2,
                    child: CustomScrollView(
                      // physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          snap: true,
                          floating: true,
                          scrolledUnderElevation: 0,
                          title: const Text('Story SA'),
                          foregroundColor:
                              isDark ? const Color(0xff83979d) : Colors.white,
                          backgroundColor: isDark
                              ? const Color(0xff1e2d31)
                              : const Color(0xff008066),
                          leading: leadingIcon(cubit, _scaffoldKey),
                          actions: [
                            if (!cubit.selectMode)
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OpenChatScreen()),
                                    );
                                  },
                                  icon: const Icon(
                                      CupertinoIcons.chat_bubble_text),
                                  splashRadius: 20,
                                  tooltip: 'open chat'),
                            if (cubit.selectMode)
                              Center(
                                  child: Text(
                                '${_tabController.index == 0 ? cubit.selectedPhotosNow.length : cubit.selectedVideosNow.length}',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? const Color(0xff83979d)
                                        : Colors.white),
                              )),
                            if (cubit.selectMode)
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 20,
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      cubit.selectAll(s: !cubit.select_all);
                                    },
                                    tooltip: cubit.select_all
                                        ? 'deselect all'
                                        : 'select all',
                                    icon: Icon(
                                      cubit.select_all
                                          ? CupertinoIcons
                                              .square_stack_3d_up_fill
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
                          bottom: TabBar(
                            controller: _tabController,
                            indicatorWeight: 2,
                            indicatorColor: Colors.white,
                            tabs: [
                              Tab(
                                icon: Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color: isDark
                                      ? const Color(0xff83979d)
                                      : Colors.white,
                                ),
                                key: const Key('photos'),
                              ),
                              Tab(
                                icon: Icon(
                                  Icons.video_library_rounded,
                                  color: isDark
                                      ? const Color(0xff83979d)
                                      : Colors.white,
                                ),
                                key: const Key('videos'),
                              ),
                            ],
                          ),
                        ),
                        cubit.widgets[_tabController.index],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: FabShareButton(
                    bottom: _getAdClass.bannerAd != null?_getAdClass.bannerAd!.size.height.toDouble():0.0,                    cubit: cubit,
                    visible: cubit.selectedPhotosNow.isNotEmpty ||
                        cubit.selectedVideosNow.isNotEmpty,
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
                          ? cubit.saveSelectPhotoStory()
                          : cubit.saveSelectVideoStory();
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
            drawer: Drawer(
              backgroundColor: isDark ? const Color(0xff1e2d31) : Colors.white,
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
                    CustomListTile(
                      selected: normalWhatsApp,
                      leading: Icons.whatsapp,
                      onTap: () {
                        Navigator.pop(context);
                        if (!normalWhatsApp) {
                          cubit.chanePathStatuses(isNormal: !normalWhatsApp);
                        }
                      },
                      title: 'WhatsApp',
                    ),
                    CustomListTile(
                      selected: !normalWhatsApp,
                      leading: Icons.whatsapp,
                      onTap: () async {
                        Navigator.pop(context);
                        if (normalWhatsApp) {
                          cubit.chanePathStatuses(isNormal: !normalWhatsApp);
                        }
                      },
                      title: 'WhatsApp Business',
                    ),
                    CustomListTile(
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
                    CustomListTile(
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
        );
      },
    );
  }
}
