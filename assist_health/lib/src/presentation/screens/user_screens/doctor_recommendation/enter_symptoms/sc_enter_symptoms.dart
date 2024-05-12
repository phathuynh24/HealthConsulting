import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../select_symptom_list/bloc/bloc.dart';
import '../select_symptom_list/sc_select_symptom_list.dart';
import 'bloc/bloc.dart';

class EnterSymptoms extends StatefulWidget {
  @override
  _EnterSymptomsState createState() => _EnterSymptomsState();
}

class _EnterSymptomsState extends State<EnterSymptoms> {
  TextEditingController _symptomsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnterSymptomsBloc(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Themes.gradientDeepClr,
            toolbarHeight: 50,
            title: const Text('Nhập triệu chứng bệnh của bạn'),
            titleTextStyle: const TextStyle(fontSize: 16),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Container(
                width: double.infinity,
                height: 45,
                color: Colors.white,
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  color: Colors.blueAccent.withOpacity(0.1),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.shade700,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Nhập triệu chứng',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 30,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Text(
                            '2',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Chọn biểu hiện bệnh',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_right_alt_outlined,
                              size: 30,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueGrey,
                              ),
                              child: const Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Đề xuất bác sĩ phù hợp',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Themes.gradientDeepClr.withOpacity(0.9),
                        Themes.gradientLightClr.withOpacity(0.7)
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [
                      Container(
                        height: 300,
                        child: Image.asset(
                          'assets/recommendation/medical_record.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      const Text(
                        'Chia sẽ triệu chứng bệnh của bạn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'Ví dụ: Tôi thấy đau ở vùng ngực, khó thở, mệt mỏi, đau đầu, chóng mặt về đêm. Tôi đã thử dùng thuốc giảm đau nhưng không hiệu quả.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 34,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _symptomsController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Nhập chi tiết triệu chứng bệnh của bạn',
                            hintStyle: TextStyle(
                              color: Colors.blue.shade200,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                    ]),
                  ),
                ),
                // BlocBuilder<DoctorRecommendationBloc,
                //     DoctorRecommendationState>(
                //   builder: (context, state) {
                //     if (state is DoctorRecommendationLoading)
                //       return CircularProgressIndicator();
                //     else if (state is DoctorRecommendationLoaded)
                //       return Text('Disease: ${state.recommendation}');
                //     else if (state is DoctorRecommendationError)
                //       return Text('Error occurred');
                //     else
                //       return Container();
                //   },
                // ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: 65,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.blueGrey,
                  width: 0.2,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<SelectSymptomListBloc>(
                      create: (context) => SelectSymptomListBloc(),
                      child: SelectSymptomListScreen(textSymtoms: _symptomsController.text),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(13),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Themes.gradientDeepClr,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
