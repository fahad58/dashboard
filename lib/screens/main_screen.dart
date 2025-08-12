import 'package:dashboard_ui/const/constant.dart';
import 'package:dashboard_ui/data/side_menu_data.dart';
import 'package:dashboard_ui/screens/add_property_screen.dart';
import 'package:dashboard_ui/util/responsive.dart';
import 'package:dashboard_ui/widgets/dashboard_widget.dart';
import 'package:dashboard_ui/widgets/side_menu_widget.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = -1;
  bool isSignOutPressed = false;
  bool isCreater = false;

  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final data = SideMenuData();

    return Scaffold(
      backgroundColor: icolor.blue,
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 2,
              child: SizedBox(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                color: icolor.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Property Manager
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Property Manager',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Vertical spacing between title and button
                    const SizedBox(height: 20),

                    // Add Object button that extends from left to right edges
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0), // No horizontal padding
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isCreater = true;
                          });
                          print(isCreater);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity, // Extends full width
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Add Object',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Vertical spacing between button and menu
                    const SizedBox(height: 20),

                    // Menu subtitle
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // 6 separate buttons with individual onPressed handlers
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: ListView(
                          children: [
                            // Button 1: Mietvetrag
                            _buildCustomButton(
                              icon: data.menu[0].icon,
                              title: data.menu[0].title,
                              isSelected: selectedIndex == 0,
                              onPressed: () {},
                            ),

                            // Button 2: Mietbescheinigung
                            _buildCustomButton(
                              icon: data.menu[1].icon,
                              title: data.menu[1].title,
                              isSelected: selectedIndex == 1,
                              onPressed: () {},
                            ),

                            // Button 3: Mahnung
                            _buildCustomButton(
                              icon: data.menu[2].icon,
                              title: data.menu[2].title,
                              isSelected: selectedIndex == 2,
                              onPressed: () {},
                            ),

                            // Button 4: Kündigung
                            _buildCustomButton(
                              icon: data.menu[3].icon,
                              title: data.menu[3].title,
                              isSelected: selectedIndex == 3,
                              onPressed: () {},
                            ),

                            // Button 5: Mieterhöhung
                            _buildCustomButton(
                              icon: data.menu[4].icon,
                              title: data.menu[4].title,
                              isSelected: selectedIndex == 4,
                              onPressed: () {},
                            ),

                            // Button 6: Jahresabrechnugn
                            _buildCustomButton(
                              icon: data.menu[5].icon,
                              title: data.menu[5].title,
                              isSelected: selectedIndex == 5,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Settings and Sign Out buttons at the bottom wrapped in InkWell
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Settings',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: isSignOutPressed
                                  ? Colors.red
                                  : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: isSignOutPressed
                                    ? Colors.red
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )),
            ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 5),
              child: Container(
                child: isCreater ? AddPropertyScreen() : DashboardWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.tealAccent : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
