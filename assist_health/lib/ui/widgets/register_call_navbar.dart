import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/register_call_step1.dart';
import 'package:assist_health/ui/user_screens/register_call_step2.dart';
import 'package:assist_health/ui/user_screens/register_call_step3.dart';
import 'package:assist_health/ui/user_screens/register_call_step4.dart';
import 'package:assist_health/ui/widgets/time_line.dart';
import 'package:flutter/material.dart';

class RegisterCallNavBar extends StatefulWidget {
  final String uid;
  const RegisterCallNavBar(this.uid, {super.key});

  @override
  State<RegisterCallNavBar> createState() => _RegisterCallNavBar();
}

class _RegisterCallNavBar extends State<RegisterCallNavBar> {
  int _index = 0;
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // Step 1
      RegisterCallStep1(widget.uid),
      // Step 2
      RegisterCallStep2(widget.uid),
      // Step 3
      RegisterCallStep3(widget.uid),
      // Step 4
      RegisterCallStep4(widget.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 120,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:
                        TimeLine(isFirst: true, isLast: false, isPast: false),
                  ),
                  Expanded(
                      child: TimeLine(
                          isFirst: false, isLast: false, isPast: true)),
                  Expanded(
                      child: TimeLine(
                          isFirst: false, isLast: false, isPast: true)),
                  Expanded(
                      child: TimeLine(
                          isFirst: false, isLast: false, isPast: true)),
                  Expanded(
                      child: TimeLine(
                          isFirst: false, isLast: true, isPast: false)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Themes.buttonClr),
                    onPressed: () {
                      _index = (--_index > 0) ? _index : 0;
                      setState(() {
                        _selectedIndex = _index;
                      });
                    },
                    child: const Text('Quay lại'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Themes.buttonClr),
                    onPressed: () {
                      _index = (++_index < _screens.length)
                          ? _index
                          : _screens.length - 1;
                      setState(() {
                        _selectedIndex = _index;
                      });
                    },
                    child: const Text('Tiếp tục'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
