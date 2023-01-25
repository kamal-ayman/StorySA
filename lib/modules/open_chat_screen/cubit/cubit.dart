
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/network/local/cache_helper.dart';
import 'states.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(AppInitialState());

  static ChatCubit get(context) => BlocProvider.of(context);

  defaultCountry({String? defaultCountryCode}) {
    if (defaultCountryCode != null) {
      CacheHelper.saveData(key: 'CountryCode', value: defaultCountryCode);
    } else {
      return CacheHelper.getData(key: 'CountryCode');
    }
  }

  String? phoneNumber;
  String? message;

  Future<void> openChat(context) async {
    if (phoneNumber != null) {
      var whatsappUrl =
          "whatsapp://send?phone=$phoneNumber&text=${message ?? ''}";
      launch(whatsappUrl).then((value) {}).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('there is no whatsapp installed yet on your device'),
          ),
        );
      });
    }
  }
}
