import "package:assist_health/src/presentation/screens/user_screens/meals/core/events/calo_update_event.dart";
import "package:assist_health/src/presentation/screens/user_screens/meals/core/events/event_bus.dart";
import "package:assist_health/src/presentation/screens/user_screens/meals/core/theme/app_colors.dart";
import "package:assist_health/src/presentation/screens/user_screens/meals/views/food_recognition/food_scan_screen.dart";
import "package:assist_health/src/presentation/screens/user_screens/meals/views/home/home_screen.dart";
import "package:assist_health/src/presentation/screens/user_screens/meals/views/setting/setting_screen.dart";
import "package:assist_health/src/widgets/user_navbar.dart";
import "package:flutter/material.dart";
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _navigateToFoodScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodScanScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  List<PersistentTabConfig> _tabs() => [
        // Home Screen
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: "Trang chủ",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        // Scan Screen
        PersistentTabConfig(
          screen: const SizedBox(),
          item: ItemConfig(
            icon: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    _navigateToFoodScan(context);
                  },
                  child: _buildCenterButton(),
                );
              },
            ),
            title: "Scan",
            activeForegroundColor: Colors.transparent,
            inactiveForegroundColor: Colors.transparent,
          ),
        ),
        // Setting Screen
        PersistentTabConfig(
          screen: const SettingScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.settings),
            title: "Cài đặt",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
      ];

  static Widget _buildCenterButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.activeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back button
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserNavBar()),
            (route) => false,
          );
        }
      },
      child: PersistentTabView(
        backgroundColor: Colors.white,
        tabs: _tabs(),
        navBarBuilder: (navBarConfig) => Style13BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: const NavBarDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
        ),
        navBarOverlap: const NavBarOverlap.full(),
        onTabChanged: (index) {
          eventBus.fire(CaloUpdateEvent(2000));
        },
      ),
    );
  }
}
