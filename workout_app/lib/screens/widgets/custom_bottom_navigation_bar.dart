import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentScreen;
  final Function(int) onTap;
  const CustomBottomNavigationBar({
    super.key,
    required this.currentScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIcon(FontAwesomeIcons.solidHouse, 0),
            _buildIcon(FontAwesomeIcons.calendar, 1),
            _buildIcon(FontAwesomeIcons.bowlFood, 2),
            _buildIcon(Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: currentScreen == index
              ? Color.fromARGB(255, 255, 254, 251)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: currentScreen == index ? 25 : 20,
            color: currentScreen == index
                ? const Color.fromARGB(255, 88, 134, 90)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
