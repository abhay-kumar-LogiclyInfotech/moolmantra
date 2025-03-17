import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../resources/constants.dart';
import '../services/audio_services.dart';
import '../services/shared_pref_services.dart';

class AudioSettingsView extends StatefulWidget {
  const AudioSettingsView({super.key});

  @override
  State<AudioSettingsView> createState() => _AudioSettingsViewState();
}

class _AudioSettingsViewState extends State<AudioSettingsView> {
  TextEditingController repeatController = TextEditingController();

  @override
  void initState() {
    repeatController.text =
        context.read<AudioService>().repeatCount?.toString() ?? '0';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Settings")),
      body: Consumer<AudioService>(
        builder: (context, audioProvider, _) {
          return Column(
            children: [
              SwitchListTile(
                title: Text("Repeat Audio"),
                secondary: Icon(Icons.loop, color: Colors.brown),
                value: audioProvider.repeatCount == null,
                // A boolean state variable
                activeColor: Colors.brown,
                onChanged: (bool value) async {
                  audioProvider.pauseAudio();

                  if (value) {
                    // 🔁 Infinite loop mode
                    audioProvider.repeatCount = null;
                    await SharedPrefService.saveRepeatCount(0);

                  } else {
                    // 🔢 Set default repeat count
                    repeatController.text = Constants.defaultRepeatCount.toString();
                    audioProvider.repeatCount = Constants.defaultRepeatCount;
                    await SharedPrefService.saveRepeatCount(Constants.defaultRepeatCount,);
                  }
                  setState(() {});
                },
              ),

              // 🔢 TEXT FIELD FOR REPEAT COUNT (Only if not infinite)
              if (audioProvider.repeatCount != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Repeat Count (Max: ${Constants.maxRepeatCount})",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: repeatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter number",
                        ),
                        maxLength: 3,
                        onChanged: (value) async {
                          audioProvider.pauseAudio();
                          int? repeatTimes = int.tryParse(value);
                          if (repeatTimes != null &&
                              repeatTimes > 0 &&
                              repeatTimes <= Constants.maxRepeatCount) {
                            audioProvider.repeatCount = repeatTimes;
                            await SharedPrefService.saveRepeatCount(repeatTimes,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
