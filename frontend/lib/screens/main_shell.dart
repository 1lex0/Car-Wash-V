import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _openSearch() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSearchTap: _openSearch,
      ),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(
                child: Container(
                  width: 330,
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4EE),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        selected: _selectedIndex == 0,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                      ),
                      _NavItem(
                        icon: Icons.search_rounded,
                        selectedIcon: Icons.search_rounded,
                        selected: _selectedIndex == 1,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        selectedIcon: Icons.person_rounded,
                        selected: _selectedIndex == 2,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Center(
          child: Icon(
            selected ? selectedIcon : icon,
            size: 26,
            color: selected
                ? const Color(0xFF18372F)
                : const Color(0xFF6F7D78),
          ),
        ),
      ),
    );
  }
}