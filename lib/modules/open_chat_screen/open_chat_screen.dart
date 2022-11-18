import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:whatsapp_story/shared/cubit/cubit.dart';
import 'package:whatsapp_story/shared/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class OpenChatScreen extends StatefulWidget {
  OpenChatScreen({Key? key}) : super(key: key);

  @override
  State<OpenChatScreen> createState() => _OpenChatScreenState();
}

class _OpenChatScreenState extends State<OpenChatScreen> {
  var textColor = isDark ? Colors.white : Colors.black;

  final GetAdClass _getAdClass = GetAdClass();
  final GetAdClass _getAdClass0 = GetAdClass();

  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAdClass.getAd(context);
    _getAdClass0.getAd(context);
  }

  @override
  void dispose() {
    super.dispose();
    _getAdClass.bannerAd!.dispose();
    _getAdClass0.bannerAd!.dispose();
    _getAdClass0.interstitialAd!.dispose();
    _getAdClass.interstitialAd!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryCubit, StoryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = StoryCubit.get(context);
        textController.text = cubit.message ?? '';
        return Scaffold(
          backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
          appBar: CustomAppBar(context, 'Open Chat'),
          body: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_getAdClass0.bannerAd != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: _getAdClass0.bannerAd!.size.width.toDouble(),
                          height: _getAdClass0.bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _getAdClass0.bannerAd!),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Now you can open chats without saved any contact in your phone.${cubit.defaultCountry()!=null?'\nDon\'t type 0':''}',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    IntlPhoneField(
                      dropdownTextStyle: TextStyle(color: textColor),
                      cursorColor: Colors.green,
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.white.withOpacity(.09),
                        labelStyle: TextStyle(
                          color: textColor,
                        ),
                        counterStyle: TextStyle(color: textColor),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                      ),
                      initialCountryCode: cubit.defaultCountry() ?? 'US',
                      onChanged: (phone) {
                        cubit.phoneNumber = phone.completeNumber;
                      },
                      onCountryChanged: (Country country) {
                        cubit.defaultCountry(defaultCountryCode: country.code);
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: textController,
                      textInputAction: TextInputAction.go,
                      textAlign: TextAlign.center,
                      cursorColor: Colors.green,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Type a message (optional)',
                        filled: true,
                        fillColor: Colors.white.withOpacity(.09),
                        labelStyle: TextStyle(
                          color: textColor,
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        disabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                      ),
                      onChanged: (String? text) {
                        cubit.message = text;
                      },
                      onFieldSubmitted: (String? text) {
                        cubit.openChat(context);
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            height: 45,
                            onPressed: () {
                              cubit.openChat(context);
                            },
                            color: Colors.green,
                            child: const Text(
                              'Open',
                              style: TextStyle(fontSize: 20),
                            ),
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
