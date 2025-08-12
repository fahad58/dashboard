
import 'package:flutter/material.dart';
class MenuModel {
  final IconData icon;
  final String title;

  const MenuModel({required this.icon, required this.title});
}
class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.document_scanner, title: 'Mietvetrag'),
    MenuModel(icon: Icons.assignment, title: 'Mietbescheinigung'),
    MenuModel(icon: Icons.warning, title: 'Mahnung'),
    MenuModel(icon: Icons.cancel, title: 'Kündigung'),
    MenuModel(icon: Icons.payment, title: 'Mieterhöhung'),
    MenuModel(icon: Icons.arrow_upward, title: 'Jahresabrechnugn'),

  ];
}

