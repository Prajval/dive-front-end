import 'package:dive/router/router_keys.dart';
import 'package:flutter/material.dart';

class Destination {
  Destination({this.title, this.icon, this.color, this.screen});

  final String title;
  final IconData icon;
  final MaterialColor color;
  final String screen;
}

List<Destination> allDestinations = <Destination>[
  Destination(
      title: 'Chat list',
      icon: Icons.chat,
      color: Colors.teal,
      screen: RouterKeys.chatListRoute),
  Destination(
      title: 'Explore',
      icon: Icons.explore,
      color: Colors.teal,
      screen: RouterKeys.exploreRoute),
];
