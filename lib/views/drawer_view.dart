import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moolmantra/services/audio_services.dart';
import 'package:moolmantra/views/audio_settings_view.dart';
import 'package:provider/provider.dart';

import '../resources/constants.dart';

class DrawerView extends StatefulWidget {
  final AudioService audioService;

  const DrawerView({super.key, required this.audioService});

  @override
  State<DrawerView> createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  final List<String> voices = [Constants.voice1, Constants.voice2];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AudioService>(
        builder: (context, audioProvider, _) {
          return Column(
            children: [
              // Drawer Header
              SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.brown),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.mic, size: 40, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Select Voice & Settings",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

              // Voice Tiles
              ...voices.asMap().entries.map((entry) {
                int index = entry.key; // Get the index
                String voice = entry.value; // Get the voice name
                return ListTile(
                  leading: Icon(Icons.record_voice_over),
                  title: Text("voice ${index + 1}"),
                  selected: audioProvider.selectedVoice == voice,
                  selectedColor: Colors.white,
                  selectedTileColor: Colors.brown.shade300,
                  onTap: () {
                    widget.audioService.playAudio(
                      voice: voice,
                    ); // Play the selected voice
                  },
                );
              }),

              Divider(),

              // Settings Tile
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Audio Settings"),
                onTap: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context)=>AudioSettingsView()));
                },
              ),


            ],
          );
        },
      ),
    );
  }
}
