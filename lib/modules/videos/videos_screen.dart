import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_story/shared/components/constants.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../shared/components/components.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2;
    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {
        if (state is PermissionDeniedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission Denied'),
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        if (cubit.permissionStatus.isDenied) {
          return permissionDeniedView(cubit);
        }
        return Conditional.single(
          context: context,
          conditionBuilder: (context) => state is! AppLoadingState,
          fallbackBuilder: (context) => SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: isDark?Colors.white.withOpacity(.4): Color(0xff008066),
              ),
            ),
          ),
          widgetBuilder: (context) {
            if (cubit.videos.isEmpty) {
              return noStoryShow();
            }
            return buildAllItems(width,context,cubit, ItemState.Video);
          },
        );
      },
    );
  }
}
