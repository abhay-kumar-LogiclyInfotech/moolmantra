import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moolmantra/views/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((callback)async {
      /// Navigate to the home screen
     await Future.delayed(Duration(seconds: 1),()async{ Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>HomeView()));});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUi(context));
  }

  Widget _buildUi(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/splash/splash_image.jpg"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
