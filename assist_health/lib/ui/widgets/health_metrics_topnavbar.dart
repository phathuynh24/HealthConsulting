import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/health_bmi.dart';
import 'package:assist_health/ui/user_screens/health_height.dart';
import 'package:assist_health/ui/user_screens/health_temperature.dart';
import 'package:assist_health/ui/user_screens/health_weight.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HealthMetricsTopNavBar extends StatefulWidget {
  UserProfile userProfile;

  HealthMetricsTopNavBar({super.key, required this.userProfile});

  @override
  State<HealthMetricsTopNavBar> createState() => _HealthMetricsTopNavBarState();
}

class _HealthMetricsTopNavBarState extends State<HealthMetricsTopNavBar> {
  int _selectedIndex = 0;
  final List<String> _tabLabels = [
    'Chiều cao',
    'Cân nặng',
    'Chỉ số BMI',
    'Nhiệt độ'
  ];
  final PageController _pageController = PageController();
  bool _isSelectingTab = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (!_isSelectingTab) {
      setState(() {
        _selectedIndex = _pageController.page!.round();
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _isSelectingTab = true;
      _selectedIndex = index;
    });
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((value) => setState(() {
              _isSelectingTab = false;
            }));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dỏi chỉ số sức khỏe'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.leftClr, Themes.rightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabLabels.length,
              itemBuilder: (context, index) {
                return _buildTabButton(index);
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                HealthHeightScreen(userProfile: widget.userProfile),
                HealthWeightScreen(userProfile: widget.userProfile),
                HealthBMIScreen(userProfile: widget.userProfile),
                HealthTemperatureScreen(userProfile: widget.userProfile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index) {
    bool isSelected = index == _selectedIndex;
    String label = _tabLabels[index];
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onTabSelected(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: isSelected ? Colors.transparent : Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.purple : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15),
              ),
              const SizedBox(height: 5),
              isSelected
                  ? Container(
                      height: 2,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.purple,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
