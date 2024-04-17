import 'package:flutter/material.dart';

class ISNavBarOptions {
  late final Color backgroundColor;
  late final double height;
  late final double iconSize;
  late Duration passiveAnimationDuration;
  late Duration animationDuration;

  ISNavBarOptions({
    double? height,
    double? iconSize,
    Color? backgroundColor,
    Duration? animationDuration,
  }) {
    this.height = height ?? 80;
    this.iconSize = iconSize ?? 24;
    this.backgroundColor = backgroundColor ?? Colors.transparent;
    this.animationDuration = animationDuration ?? Duration(milliseconds: 200);
  }

  void slowDownAnimation({double velocity = 1.25}) {
    passiveAnimationDuration = animationDuration;
    animationDuration = Duration(
      milliseconds: (animationDuration.inMilliseconds * velocity).toInt(),
    );
  }

  void resetAnimationDuration() {
    animationDuration = passiveAnimationDuration;
  }
}

class ISNavBarDestination {
  late final Color overlayColor;
  late final Color indicatorColor;
  late final IconData icon;
  late final String label;

  ISNavBarDestination({
    required this.icon,
    required this.label,
    Color? overlayColor,
    Color? indicatorColor,
  }) {
    this.overlayColor = overlayColor ?? Colors.blue[200]!;
    this.indicatorColor = indicatorColor ?? Colors.blue;
  }
}

class ISNavBar extends StatefulWidget {
  final int initialIndex;
  final List<ISNavBarDestination> destinations;

  late final ISNavBarOptions options;
  late final Function(int) onDestinationSelected;

  ISNavBar({
    required this.initialIndex,
    required this.destinations,
    super.key,
    ISNavBarOptions? options,
    Function(int)? onDestinationSelected,
  }) {
    assert(destinations.length >= 3 && destinations.length <= 5);
    this.options = options ?? ISNavBarOptions();
    this.onDestinationSelected = onDestinationSelected ?? (_) {};
  }

  @override
  State<ISNavBar> createState() => _ISNavBarState();
}

class _ISNavBarState extends State<ISNavBar> {
  late final Function(int) onDestinationSelected;
  late final ISNavBarOptions options;
  late final List<ISNavBarDestination> destinations;
  late double widgetGap;
  late double maxAllowedItemWidgetPosition;
  late int destinationCount;
  late int currentWidgetIndex;
  late List<_ISNavBarWidget> destinationWidgets;

  bool get currentIndexWidgetIsCentered =>
      destinationWidgets[currentWidgetIndex].position.abs() <=
      widgetGap / (destinationCount % 2 == 0 ? 2 : 4);

  @override
  void initState() {
    super.initState();

    options = widget.options;
    onDestinationSelected = widget.onDestinationSelected;
    destinations = widget.destinations;
    destinationCount = widget.destinations.length;
    currentWidgetIndex = widget.initialIndex;
    widgetGap = (2 / destinationCount);
    maxAllowedItemWidgetPosition =
        widgetGap * destinationCount - widgetGap / destinationCount;

    createWidgets();
    centerInitialIndexWidget();
    generateWidgetChildren();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: tapHandler,
      onHorizontalDragEnd: horizontalDragHandler,
      child: Container(
        color: options.backgroundColor,
        height: options.height,
        width: double.infinity,
        child: Stack(
          children: [for (var element in destinationWidgets) element.child],
        ),
      ),
    );
  }

  void createWidgets() {
    destinationWidgets = List<_ISNavBarWidget>.generate(
      destinationCount * 2,
      (ix) => _ISNavBarWidget(
        index: ix,
        destinationCount: destinationCount,
        gap: widgetGap,
        maxAllowedPosition: maxAllowedItemWidgetPosition,
        startingPosition: widgetGap / 2 - 1,
      ),
    );
  }

  void generateWidgetChildren() {
    for (var widget in destinationWidgets)
      widget.generateChild(
        currentWidgetIndex: currentWidgetIndex,
        destinations: destinations,
        options: options,
      );
  }

  void centerInitialIndexWidget() {
    while (!currentIndexWidgetIsCentered) updateWidgetPositions(1);
  }

  void centerCurrentIndexWidget({required double direction}) {
    updateWidgetOpacities();
    if (!currentIndexWidgetIsCentered) updateWidgetPositions(direction);
    setState(generateWidgetChildren);
  }

  void updateWidgetPositions(double velocity) {
    for (var widget in destinationWidgets) widget.updatePosition(velocity);
  }

  void updateWidgetOpacities() {
    for (var widget in destinationWidgets) widget.updateOpacity();
  }

  void horizontalDragHandler(DragEndDetails gestureDetails) {
    // Find the velocity of the drag.
    double velocity = gestureDetails.primaryVelocity!;
    if (velocity == 0) return;

    // Update the itemPositions, itemOpacities & selected index.
    currentWidgetIndex =
        (velocity > 0 ? currentWidgetIndex - 1 : currentWidgetIndex + 1) %
            (destinationCount * 2);

    centerCurrentIndexWidget(direction: velocity.sign);
    onDestinationSelected(currentWidgetIndex % destinationCount);
  }

  void tapHandler(TapUpDetails gestureDetails) async {
    // Find the selected index based on tap position.
    double selectedAlignment =
        (gestureDetails.localPosition.dx / context.size!.width * 2 - 1);

    int selectedWidgetIndex = destinationWidgets.indexWhere(
      (widget) =>
          (selectedAlignment - widget.position).abs() <= 0.2 &&
          widget.opacity == 1,
    );

    // If no index is found, do nothing.
    if (selectedWidgetIndex.isNegative) return;

    double velocity =
        selectedAlignment - destinationWidgets[currentWidgetIndex].position;
    currentWidgetIndex = selectedWidgetIndex;

    bool isLargeJump = destinationCount % 2 == 1 &&
        destinationWidgets[selectedWidgetIndex].position.abs() >=
            widgetGap * 1.5;

    // If the selected index is 2 indexes or more away from the current index and there are odd number of widgets visible, slow down the transition.
    if (isLargeJump) {
      setState(generateWidgetChildren);
      options.slowDownAnimation();
      while (!currentIndexWidgetIsCentered)
        centerCurrentIndexWidget(direction: -velocity.sign);
      options.resetAnimationDuration();
    } else {
      do {
        centerCurrentIndexWidget(direction: -velocity.sign);
      } while (!currentIndexWidgetIsCentered);
    }

    onDestinationSelected(currentWidgetIndex % destinationCount);
  }
}

class _ISNavBarWidget {
  final int destinationCount;
  final int index;

  late final double gap;
  late final double maxAllowedPosition;
  late double opacity;
  late double position;
  late Widget child;

  _ISNavBarWidget({
    required this.index,
    required this.destinationCount,
    required this.gap,
    required this.maxAllowedPosition,
    required double startingPosition,
  }) {
    opacity = 1;
    position = index >= (3 * destinationCount) ~/ 2
        ? startingPosition - gap * (destinationCount * 2 - index)
        : startingPosition + (gap * index);
  }

  void updatePosition(double direction) {
    position = position * direction.sign >= maxAllowedPosition
        ? -position + gap * direction.sign * (destinationCount % 2 == 0 ? 2 : 1)
        : position + (gap * direction.sign);
  }

  void updateOpacity() {
    opacity =
        position.abs() + (destinationCount <= 4 ? 0 : gap) >= maxAllowedPosition
            ? 0
            : 1;
  }

  void generateChild({
    required int currentWidgetIndex,
    required ISNavBarOptions options,
    required List<ISNavBarDestination> destinations,
  }) {
    bool widgetInPosition =
        position.abs() <= gap / (destinationCount % 2 == 0 ? 2 : 4) &&
            index == currentWidgetIndex;
    ISNavBarDestination destination = destinations[index % destinationCount];

    child = Opacity(
      opacity: opacity,
      child: AnimatedAlign(
        alignment: Alignment(position, 0),
        duration: options.animationDuration,
        child: Stack(
          alignment: Alignment(position, 0),
          children: [
            AnimatedAlign(
              duration: options.animationDuration,
              alignment: widgetInPosition
                  ? Alignment(position, -0.5)
                  : Alignment(position, 0),
              child: AnimatedContainer(
                duration: options.animationDuration,
                alignment: Alignment.center,
                width: gap * 100,
                height: 35,
                decoration: BoxDecoration(
                  color: widgetInPosition
                      ? destination.overlayColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedScale(
                  child: AnimatedCrossFade(
                    duration: options.animationDuration,
                    crossFadeState: widgetInPosition
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Icon(
                      destination.icon,
                      color: destination.indicatorColor,
                      size: options.iconSize,
                    ),
                    secondChild: Icon(
                      destination.icon,
                      color: Colors.black,
                      size: options.iconSize,
                    ),
                  ),
                  scale: widgetInPosition ? 1.25 : 1,
                  duration: options.animationDuration,
                ),
              ),
            ),
            AnimatedAlign(
              duration: options.animationDuration,
              alignment: widgetInPosition
                  ? Alignment(position, 0.75)
                  : Alignment(position, 2),
              child: Text(
                destination.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
