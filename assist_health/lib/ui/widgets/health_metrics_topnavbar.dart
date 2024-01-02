import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/health_bmi.dart';
import 'package:assist_health/ui/user_screens/health_height.dart';
import 'package:assist_health/ui/user_screens/health_temperature.dart';
import 'package:assist_health/ui/user_screens/health_weight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HealthMetricsTopNavBar extends StatefulWidget {
  const HealthMetricsTopNavBar({super.key});

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
  bool isLoading = false;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    getUserData();
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

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_profiles')
        .doc('main_profile')
        .get();

    if (snapshot.exists) {
      setState(() {
        _userProfile =
            UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Theo dỏi chỉ số sức khỏe',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
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
                        HealthHeightScreen(userProfile: _userProfile!),
                        HealthWeightScreen(userProfile: _userProfile!),
                        HealthBMIScreen(userProfile: _userProfile!),
                        HealthTemperatureScreen(userProfile: _userProfile!),
                      ],
                    ),
                  ),
                ],
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                    color: Colors.blue, width: (isSelected) ? 1.5 : 0),
              )),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
