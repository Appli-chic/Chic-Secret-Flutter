import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  final Widget view1;
  final Widget view2;
  final double gripSize;
  final double initialWeight;
  final Color gripColor;
  final double positionLimit;
  final ValueChanged<double> onWeightChanged;

  SplitView({
    required this.view1,
    required this.view2,
    this.gripSize = 1.0,
    this.initialWeight = 0.2,
    this.gripColor = Colors.black12,
    this.positionLimit = 150.0,
    required this.onWeightChanged,
  });

  @override
  _SplitViewState createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double defaultWeight;
  late ValueNotifier<double> weight;
  late double _prevWeight;

  @override
  void initState() {
    super.initState();
    defaultWeight = widget.initialWeight;
  }

  @override
  Widget build(BuildContext context) {
    weight = ValueNotifier(defaultWeight);
    _prevWeight = defaultWeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<double>(
          valueListenable: weight,
          builder: (_, w, __) {
            if (_prevWeight != w) {
              _prevWeight = w;
              widget.onWeightChanged(w);
            }

            return _buildHorizontalView(context, constraints, w);
          },
        );
      },
    );
  }

  Widget _buildHorizontalView(
      BuildContext context, BoxConstraints constraints, double w) {
    final double left = constraints.maxWidth * w;
    final double right = constraints.maxWidth * (1.0 - w);
    final double halfGripSize = widget.gripSize / 2.0;

    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: right + halfGripSize,
          bottom: 0,
          child: widget.view1,
        ),
        Positioned(
          top: 0,
          left: left + halfGripSize,
          right: 0,
          bottom: 0,
          child: widget.view2,
        ),
        Positioned(
          top: 0,
          left: left - halfGripSize - 6,
          right: right - halfGripSize - 6,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (detail) {
                final RenderBox container =
                    context.findRenderObject() as RenderBox;
                final pos = container.globalToLocal(detail.globalPosition);
                if (pos.dx > widget.positionLimit &&
                    pos.dx < (container.size.width - widget.positionLimit)) {
                  weight.value = pos.dx / container.size.width;
                }
              },
              child: Center(
                child: Container(
                  color: widget.gripColor,
                  width: widget.gripSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
