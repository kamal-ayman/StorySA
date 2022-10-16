import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';


class VideoScreen extends StatefulWidget {
  late File file;
  late int id;

  VideoScreen({Key? key, required this.file, required this.id})
      : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState(file: file, id: id);
}

class _VideoScreenState extends State<VideoScreen> {
  late File file;
  late int id;
  late VideoPlayerController controller;

  _VideoScreenState({required this.file, required this.id});

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    super.initState();
    controller = VideoPlayerController.file(file);
    controller.addListener(() {
      setState(() {});
    });
    controller.setLooping(false);
    controller.initialize().then((_) => setState(() {}));
    controller.play();
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
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
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
                  duration: const Duration(milliseconds: 0),
                  reverseDuration: const Duration(milliseconds: 0),
                  child: !cubit.showOptions
                      ? InkWell(
                          onTap: () {
                            cubit.switchShowOptions();
                          },
                          highlightColor: Colors.transparent,
                        )
                      : Transform.translate(
                          offset: const Offset(0, 5),
                          child: Column(
                            children: [
                              const Spacer(),
                              VideoProgressIndicator(
                                controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.white,
                                ),
                              ),
                              Container(
                                color: Colors.grey.withOpacity(.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        splashColor: Colors.transparent,
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          if (back) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoScreen(
                                                        file: StoryCubit.get(
                                                                context)
                                                            .videos[id - 1],
                                                        id: id - 1),
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
                                        visualDensity: VisualDensity.compact,
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
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VideoScreen(
                                                        file: StoryCubit.get(
                                                                context)
                                                            .videos[id + 1],
                                                        id: id + 1);
                                                },
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
                                        visualDensity: VisualDensity.compact,
                                        splashColor: Colors.transparent,
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        splashColor: Colors.transparent,
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          StoryCubit.get(context)
                                              .saveStory(file);
                                        },
                                        icon: const Icon(CupertinoIcons
                                            .square_arrow_down_on_square),
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: !cubit.showOptions
                      ? null
                      : Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.5),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      visualDensity: VisualDensity.compact,
                                      splashColor: Colors.transparent,
                                      splashRadius: 20,
                                      onPressed: () async {
                                        await SystemChrome
                                            .setEnabledSystemUIMode(
                                                SystemUiMode.manual, overlays: SystemUiOverlay.values);

                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        CupertinoIcons.back,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.5),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: IconButton(
                                      tooltip: 'forward',
                                      color: Colors.white,
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      visualDensity: VisualDensity.compact,
                                      splashColor: Colors.transparent,
                                      splashRadius: 20,
                                      onPressed: () async {
                                        cubit.shareOneFile(
                                            path: file.path, toWhatsapp: true, context: context);
                                      },
                                      icon: const Icon(
                                        CupertinoIcons.reply,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.5),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: IconButton(
                                      color: Colors.white,
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      visualDensity: VisualDensity.compact,
                                      splashColor: Colors.transparent,
                                      splashRadius: 20,
                                      onPressed: () {
                                        cubit.shareOneFile(
                                            path: file.path, toWhatsapp: false);
                                      },
                                      icon: const Icon(
                                        CupertinoIcons.share,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
