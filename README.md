# ISNavBar - Infinitely Scrollable Navigation Bar Widget For Flutter

![Pub Version](https://img.shields.io/pub/v/isnavbar?&logo=dart&color=violet)
![GitHub License](https://img.shields.io/github/license/Tejaromalius/ISNavBar?color=red)


ISNavBar is a customizable Flutter widget that provides an infinitely scrollable navigation bar experience for your Flutter applications.

<p align="center">
<img src="https://github.com/Tejaromalius/ISNavBar/raw/main/assets/demo.gif" alt="Widget demo"  height=500/>
</p>



## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Contributions](#contributions)

## Features

- **Infinitely Scrollable**: ISNavBar provides an infinitely scrollable navigation bar experience, allowing navigation without any limits.
- **Customizable**: Easily customize the appearance and behavior of the navigation bar to match your app's design.
- **Interactive**: Supports tap and drag gestures for navigation between destinations.
- **Flexible**: Can accommodate 3 to 5 navigation destinations with smooth animations.

## Installation

To use ISNavBar in your Flutter project, follow these steps:

1. Add the `isnavbar` package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     isnavbar: <latest_version>
   ```

2. Run `flutter pub get` in your terminal to install the package.

3. Import the package in your Dart code:

   ```dart
   import 'package:isnavbar/isnavbar.dart';
   ```

## Usage

Here's a basic example of how to use ISNavBar in your Flutter application:

```dart
import 'package:isnavbar/isnavbar.dart';
import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        title: 'ISNavBar Example',
        home: HomePage(),
      ),
    );

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    Center(child: Text('Home')),
    Center(child: Text('Search')),
    Center(child: Text('Add')),
    Center(child: Text('Profile')),
  ];

  final List<ISNavBarDestination> destinations = [
    ISNavBarDestination(
      icon: Icons.home,
      label: 'Home',
      indicatorColor: Colors.green,
      overlayColor: Colors.green[200]!,
    ),
    ISNavBarDestination(
      icon: Icons.search,
      label: 'Search',
      indicatorColor: Colors.red,
      overlayColor: Colors.red[200]!,
    ),
    ISNavBarDestination(
      icon: Icons.add,
      label: 'Add',
      indicatorColor: Colors.blue,
      overlayColor: Colors.blue[200]!,
    ),
    ISNavBarDestination(
      icon: Icons.person,
      label: 'Profile',
      indicatorColor: Colors.purple,
      overlayColor: Colors.purple[200]!,
    ),
  ];

  void _onIndexChanged(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Swipe left or right on the Nav Bar!"),
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: ISNavBar(
        initialIndex: selectedIndex,
        destinations: destinations,
        onDestinationSelected: _onIndexChanged,
        options: ISNavBarOptions(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.grey[200]!,
          height: 80,
          iconSize: 24,
        ),
      ),
    );
  }
}
```

## Documentation

### ISNavBar

A customizable infinitely scrollable navigation bar widget.

#### Constructor

```dart
ISNavBar(
  {
  required int initialIndex,
  required List<ISNavBarDestination> destinations
  Key? key,
  ISNavBarOptions? options,
  Function(int)? onDestinationSelected,
})
```

- `initialIndex`: The initial index of the selected destination.
- `destinations`: A list of `ISNavBarDestination` objects representing the navigation destinations.
- `options`: Custom options for the navigation bar (optional).
- `onDestinationSelected`: Callback function invoked when a destination is selected (optional).

### ISNavBarDestination

Represents a navigation destination item.

#### Constructor

```dart
ISNavBarDestination({
  required IconData icon,
  required String label,
  Color? overlayColor,
  Color? indicatorColor,
})
```

- `icon`: The icon data for the destination.
- `label`: The label text for the destination.
- `overlayColor`: The overlay color when the destination is selected (optional).
- `indicatorColor`: The indicator color for the destination (optional).

### ISNavBarOptions

Custom options for ISNavBar.

#### Constructor

```dart
ISNavBarOptions({
  double? height,
  double? iconSize,
  Color? backgroundColor,
  Duration? animationDuration,
})
```

- `height`: The height of the navigation bar (optional).
- `iconSize`: The size of icons in the navigation bar (optional).
- `backgroundColor`: The background color of the navigation bar (optional).
- `animationDuration`: The duration for animation transitions (optional).

## Contributions

Contributions to ISNavBar are welcome! If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request on [GitHub](https://github.com/Tejaromalius/ISNavBar).