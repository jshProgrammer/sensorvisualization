import 'package:flutter/material.dart';
import 'package:sensorvisualization/data/settingsModels/LexikonEntry.dart';
import 'package:url_launcher/url_launcher.dart';

class LexikonDialog extends StatelessWidget {
  final List<LexikonEntry> entries;

  LexikonDialog({required this.entries});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Lexikon"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(entry.description),
                      if (entry.url.isNotEmpty) ...[
                        SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Öffne den Link im Browser
                            launchUrl(Uri.parse(entry.url));
                          },
                          child: Text(
                            entry.url,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Schließen"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }
}
