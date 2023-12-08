import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../shared/components/constants.dart';

class IsActiveScreen extends StatelessWidget {
  const IsActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            height: 250,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Story App is deactivated',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'you can download Story App from Google Play...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    child: const Text(
                      'Go to Google Play!',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      launchUrl(Uri(
                        scheme: googlePlayScheme,
                        host: googlePlayHost,
                        path: googlePlayPath,
                        queryParameters: googlePlayQueryParameters,
                      ));
                    },
                  ),
                  const LinearProgressIndicator(color: Colors.green,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
