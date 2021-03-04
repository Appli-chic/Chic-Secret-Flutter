import 'package:chic_secret/ui/component/common/split_view.dart';
import 'package:chic_secret/ui/screen/vaults_screen.dart';
import 'package:flutter/material.dart';

class MainDesktopScreen extends StatefulWidget {
  @override
  _MainDesktopScreenState createState() => _MainDesktopScreenState();
}

class _MainDesktopScreenState extends State<MainDesktopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplitView(
        view1: VaultsScreen(),
        view2: SplitView(
          view1: Center(child: Text("hello 2")),
          view2: Center(child: Text("hello 3")),
          initialWeight: 0.4,
          onWeightChanged: (double value) {},
        ),
        onWeightChanged: (double value) {},
      ),
    );
  }
}
