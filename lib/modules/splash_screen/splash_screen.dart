import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_story/modules/is_active_screen/is_active_screen.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';

import '../../layout/layout.dart';
import '../../shared/components/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
      const Duration(milliseconds: 500),
          () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double imageSize() {
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;
      double size = height < width ? height : width;
      return size / 4;
    }


    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // color: Colors.white,
        color: isDark ? const Color(0xff1e2d31) : Colors.white,
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
                    color: isDark ? Colors.white : const Color(0xff626a6d),
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
