import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class VideoScreen extends StatefulWidget {
  final File file;
  final int id;

  const VideoScreen({Key? key, required this.file, required this.id})
      : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState(id: id, file: file);
}

class _VideoScreenState extends State<VideoScreen> {
  File file;
  int id;
  bool canPlay = true;
  bool isPlaying = true;
  late VideoPlayerController controller;

  _VideoScreenState({required this.file, required this.id});

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    controller = VideoPlayerController.file(file);
    controller.addListener(() {});
    controller.setLooping(false);
    controller.initialize().then((_) => setState(() {}));
    controller.play();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int len = StoryCubit.get(context).videos.length;
    bool back = id - 1 >= 0;
    bool next = id + 1 < len;
    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        return WillPopScope(
          onWillPop: () async {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: InkWell(
              onTap: () {
                cubit.switchShowOptions();
              },
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: InkWell(
                        onTap: () {
                          cubit.switchShowOptions();
                        },
                        child: VideoPlayer(controller),
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: !cubit.showOptions
                        ? null
                        : InkWell(
                            onTap: () {
                              cubit.switchShowOptions();
                            },
                            highlightColor: Colors.transparent,
                          ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: !cubit.showOptions
                        ? null
                        : InkWell(
                            onTap: () {
                              cubit.switchShowOptions();
                            },
                            child: Column(
                              children: [
                                const Spacer(),
                                Transform.translate(
                                  offset: const Offset(0, 5),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.grey.withOpacity(.5),
                                    ),
                                    // color: Colors.white24,
                                    // color: Colors.grey.withOpacity(.5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            splashColor: Colors.transparent,
                                            splashRadius: 20,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              if (back) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        VideoScreen(
                                                            file: cubit
                                                                .videos[id - 1]!
                                                                .file,
                                                            id: id - 1),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              } else {
                                                print('no more video!!');
                                              }
                                            },
                                            iconSize: 25,
                                            icon: Icon(
                                              CupertinoIcons.backward_end,
                                              color: back
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            splashColor: Colors.transparent,
                                            splashRadius: 35,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              if (controller.value.isPlaying) {
                                                controller.pause();
                                              } else {
                                                controller.play();
                                              }
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              controller.value.isPlaying
                                                  ? CupertinoIcons.pause
                                                  : CupertinoIcons.play,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (next) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        VideoScreen(
                                                            file: cubit
                                                                .videos[id + 1]!
                                                                .file,
                                                            id: id + 1),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              } else {
                                                print('no more video!!');
                                              }
                                            },
                                            iconSize: 25,
                                            icon: Icon(
                                              CupertinoIcons.forward_end,
                                              color: next
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            splashColor: Colors.transparent,
                                            splashRadius: 20,
                                            padding: EdgeInsets.zero,
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            splashColor: Colors.transparent,
                                            splashRadius: 20,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              StoryCubit.get(context)
                                                  .saveCurrentStory(file);
                                            },
                                            icon: const Icon(CupertinoIcons
                                                .square_arrow_down_on_square),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: !cubit.showOptions
                        ? null
                        : Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                customIconButton(
                                  CupertinoIcons.back,
                                  () async {
                                    await SystemChrome.setEnabledSystemUIMode(
                                        SystemUiMode.manual,
                                        overlays: SystemUiOverlay.values);

                                    Navigator.pop(context);
                                  },
                                ),
                                const Spacer(),
                                customIconButton(
                                  CupertinoIcons.reply,
                                  () async {
                                    cubit.shareOneFile(
                                        path: file.path,
                                        toWhatsapp: true,
                                        context: context);
                                  },
                                ),
                                const SizedBox(width: 10),
                                customIconButton(
                                  CupertinoIcons.share,
                                  () {
                                    cubit.shareOneFile(
                                        path: file.path, toWhatsapp: false);
                                  },
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget customIconButton(IconData icon, onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: IconButton(
        color: Colors.white,
        padding: EdgeInsets.zero,
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        splashColor: Colors.transparent,
        splashRadius: 20,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
