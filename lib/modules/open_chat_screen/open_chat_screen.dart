import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class OpenChatScreen extends StatefulWidget {
  const OpenChatScreen({Key? key}) : super(key: key);

  @override
  State<OpenChatScreen> createState() => _OpenChatScreenState();
}

class _OpenChatScreenState extends State<OpenChatScreen> {
  // var textColor = isDark ? Colors.white : Colors.black;

  final GetAdClass _getAdClass = GetAdClass();
  final GetAdClass _getAdClass0 = GetAdClass();

  var phoneController = TextEditingController();
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
    return Scaffold(
      // backgroundColor: isDark ? const Color(0xff0f1c1e) : Colors.white,
      appBar: customAppBar(context, 'Open Chat'),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Now you can open chats without saved any contact in your phone.',
                    style: Theme.of(context).textTheme.titleSmall
                  ),
                ),
                defaultTextFormField(
                    'Phone Number', CupertinoIcons.plus, phoneController, true),
                const SizedBox(height: 15),
                defaultTextFormField('Type a message (optional)',
                    CupertinoIcons.chat_bubble_text, textController, false),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        height: 45,
                        onPressed: () {
                          openChat(context, phoneController.text,
                              textController.text);
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
                const SizedBox(height: 10),
                if (_getAdClass0.bannerAd != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: _getAdClass0.bannerAd!.size.width.toDouble(),
                      height: _getAdClass0.bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _getAdClass0.bannerAd!),
                    ),
                  ),
                if (_getAdClass.bannerAd != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
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
  }

  defaultTextFormField(text, icon, controller, bool isPhone) {
    return TextFormField(
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      controller: controller,
      style: Theme.of(context).textTheme.titleLarge,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
      cursorColor: isDark?Colors.white:Colors.green,
      decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: Icon(icon),
      ),
    );
  }

  openChat(BuildContext context, String phone, String text) {
    if (phone != '') {
      if (phone.startsWith('0')) phone = '2' + phone;
      if (phone[0] != '+') phone = '+' + phone;
      var whatsappUrl = "whatsapp://send?phone=$phone&text=$text";
      launch(whatsappUrl);
    }
  }
}
