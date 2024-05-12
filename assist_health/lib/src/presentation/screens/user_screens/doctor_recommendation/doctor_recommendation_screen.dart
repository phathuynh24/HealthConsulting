import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc.dart';

class DoctorRecommendationScreen extends StatefulWidget {
  @override
  _DoctorRecommendationScreenState createState() =>
      _DoctorRecommendationScreenState();
}

class _DoctorRecommendationScreenState
    extends State<DoctorRecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorRecommendationBloc(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Themes.gradientDeepClr,
            toolbarHeight: 50,
            title: const Text('Đề xuất bác sĩ từ triệu chứng'),
            titleTextStyle: const TextStyle(fontSize: 16),
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Themes.gradientDeepClr,
                  Themes.gradientDeepClr.withOpacity(0.9),
                  Themes.gradientDeepClr.withOpacity(0.9),
                  Themes.gradientDeepClr.withOpacity(0.9),
                  Themes.gradientDeepClr.withOpacity(0.85),
                  Themes.gradientDeepClr.withOpacity(0.75),
                  Themes.gradientDeepClr.withOpacity(0.65),
                  Color.fromARGB(255, 161, 117, 254),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 350,
                  child: Image.asset(
                    'assets/recommendation_get_started.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Hãy chia sẽ triệu chứng bệnh của bạn!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34.0),
                  child: const Text(
                    'Các mô tả triệu chứng chi tiết của bạn sẽ giúp chúng tôi đưa ra đánh giá và gợi ý bác sĩ phù hợp nhất cho bạn!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
                InkWell(
                  onTap: () {
                    // Navigator.pushNamed(context, '/symptom_description');
                  },
                  child: Container(
                    width: 230,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 3)),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 161, 120, 248),
                          Color.fromARGB(255, 176, 141, 253),
                          Color(0xffbb9bff),
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                            color: Themes.gradientDeepClr.withOpacity(0.7),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Bắt đầu chia sẽ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         Themes.gradientDeepClr.withOpacity(0.8),
                //         Themes.gradientLightClr.withOpacity(0.7)
                //       ],
                //       begin: Alignment.bottomRight,
                //       end: Alignment.topLeft,
                //     ),
                //     borderRadius: BorderRadius.circular(15),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.3),
                //         spreadRadius: 1,
                //       ),
                //     ],
                //   ),
                //   child: Padding(
                //     padding: EdgeInsets.all(8.0),
                //     child: Column(children: [
                //       ClipOval(
                //         child: Container(
                //           height: 120,
                //           width: 120,
                //           child: Image(
                //             image:
                //                 AssetImage('assets/enter_medical_record.jpg'),
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         height: 16.0,
                //       ),
                //       const Text(
                //         'Chia sẽ triệu chứng bệnh của bạn',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.w500,
                //           color: Colors.white,
                //         ),
                //       ),
                //       SizedBox(
                //         height: 8.0,
                //       ),
                //       const Text(
                //         'Các mô tả triệu chứng chi tiết của bạn sẽ giúp chúng tôi đưa ra đánh giá và gợi ý bác sĩ phù hợp nhất cho bạn!',
                //         style: TextStyle(
                //           fontSize: 12,
                //           color: Colors.white,
                //         ),
                //         textAlign: TextAlign.center,
                //       ),
                //       SizedBox(
                //         height: 20.0,
                //       ),
                //       InkWell(
                //         onTap: () {},
                //         child: Container(
                //           width: MediaQuery.of(context).size.width * 0.5,
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 16, vertical: 12),
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           child: Center(
                //             child: Text(
                //               'Nhập triệu chứng',
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w800,
                //                 color: Themes.gradientDeepClr.withOpacity(0.8),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         height: 4.0,
                //       ),
                //     ]),
                //   ),
                // ),
                SizedBox(height: 16.0),
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
          // bottomNavigationBar: Container(
          //   height: 65,
          //   padding: const EdgeInsets.all(8),
          //   decoration: const BoxDecoration(
          //     border: Border(
          //       top: BorderSide(
          //         color: Colors.blueGrey,
          //         width: 0.2,
          //       ),
          //     ),
          //   ),
          //   child: GestureDetector(
          //     onTap: () {
          //       // _onRecommendButtonPressed(context);
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.all(13),
          //       margin: const EdgeInsets.symmetric(horizontal: 5),
          //       decoration: BoxDecoration(
          //         color: Themes.gradientDeepClr,
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       alignment: Alignment.center,
          //       child: const Text(
          //         'Đề xuất bác sĩ',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
