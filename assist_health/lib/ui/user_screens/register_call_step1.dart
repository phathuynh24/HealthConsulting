import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/doctor/doctor_service.dart';
import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';

class RegisterCallStep1 extends StatefulWidget {
  final String uid;

  const RegisterCallStep1(this.uid, {super.key});

  @override
  State<RegisterCallStep1> createState() => _RegisterCallStep1();
}

class _RegisterCallStep1 extends State<RegisterCallStep1> {
  int selectedCard = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Đăng ký dịch vụ'),
        centerTitle: true,
        backgroundColor: Themes.hearderClr,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<DoctorService>>(
          future: getDoctorServices(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SizedBox(
                  height: 290,
                  width: double.infinity,
                  child: Center(
                    child: Text('Something went wrong'),
                  ));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 290,
                  width: double.infinity,
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    '1. Chọn hình thức khám',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedCard = 1;
                    });
                  },
                  child: buildCard(
                    index: 1,
                    isSelected: selectedCard == 1,
                    text: snapshot.data![0].name,
                    price: snapshot.data![0].price,
                    time: snapshot.data![0].time,
                    icon: Icons.phone,
                  ),
                ),

                // Card 2
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedCard = 2;
                    });
                  },
                  child: buildCard(
                    index: 2,
                    isSelected: selectedCard == 2,
                    text: snapshot.data![1].name,
                    price: snapshot.data![1].price,
                    time: snapshot.data![1].time,
                    icon: Icons.video_call_sharp,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildCard({
    required int index,
    required bool isSelected,
    required String text,
    required IconData icon,
    required int price,
    required int time,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected ? Themes.selectedClr : Colors.grey,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width / 1.25,
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCard = index;
                        });
                      },
                    ),
                    Text(text),
                  ],
                ),
              ),
              Icon(icon, color: isSelected ? Themes.selectedClr : null),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          Text(
            '$price VNĐ / $time phút',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
