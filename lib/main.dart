import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:whatsapp_story/shared/bloc_observer.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import 'package:whatsapp_story/shared/network/local/cache_helper.dart';
import 'package:whatsapp_story/shared/styles/styles.dart';

import 'modules/splash_screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  isDark = await CacheHelper.getData(key: 'isDark') ?? isDark;
  primaryWhatsApp = await CacheHelper.getData(key: 'normalWhatsApp') ?? primaryWhatsApp;
  saveFolder = await CacheHelper.getData(key: 'saveFolder') ?? saveFolder;
  runApp(const StoryApp());
}

class StoryApp extends StatelessWidget {
  const StoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StoryCubit()
        ..getStoragePermission(context)
        ..checkInstalledWhatsApp()..getInfo(),
      child: BlocConsumer<StoryCubit, StoryStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'StorySA',
            home: const SplashScreen(),
            scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
