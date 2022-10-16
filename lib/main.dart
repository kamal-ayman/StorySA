import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:whatsapp_story/layout/layout.dart';
import 'package:whatsapp_story/shared/bloc_observer.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/network/local/cache_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  isDark = await CacheHelper.getData(key: 'isDark') ?? isDark;
  normalWhatsApp =
      await CacheHelper.getData(key: 'normalWhatsApp') ?? normalWhatsApp;
  saveFolder = await CacheHelper.getData(key: 'saveFolder') ?? saveFolder;

  // CacheHelper.clearData(key: 'isDark');
  // print(isDark);
  runApp(StoryApp());
}

class StoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StoryCubit()..getStoragePermission()..checkInstalledWhatsApp(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StorySA',
        home: const SplashScreen(),
        // home: HomeScreen(),
        // themeMode: isDark?ThemeMode.dark:ThemeMode.light,
        theme: ThemeData(
          // scaffoldBackgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
          splashColor: Colors.transparent,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white.withOpacity(0),
              statusBarIconBrightness: Brightness.light,
            ),
          ),
        ),
        //     // elevation: 0.0,
        //     // titleTextStyle: TextStyle(
        //     //   color: Colors.black,
        //     //   fontWeight: FontWeight.bold,
        //     //   fontSize: 20,
        //     // ),
        //     // actionsIconTheme: IconThemeData(color: Colors.black),
        //   ),
        // ),
        // darkTheme: ThemeData(
        //   appBarTheme: AppBarTheme(
        //     backgroundColor: Color(0xff1e2d31),
        //     foregroundColor: Colors.white,
        //     systemOverlayStyle: SystemUiOverlayStyle(
        //       statusBarColor: Colors.white.withOpacity(0),
        //       statusBarIconBrightness: Brightness.light,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(milliseconds: 500),
      () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      },
    );

    imageSize() {
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;
      double size = height < width ? height : width;
      size /= 4;
      return size;
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              'assets/icon/icon.png',
              filterQuality: FilterQuality.low,
              width: imageSize(),
              height: imageSize(),
            ),
            const SizedBox(
              height: 40,
            ),
            const Spacer(),
            Text(
              'from',
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: const Color(0xff626a6d),
                    fontSize: 14,
                  ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Oliver',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontSize: 20, color: const Color(0xff04cc6a)),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
