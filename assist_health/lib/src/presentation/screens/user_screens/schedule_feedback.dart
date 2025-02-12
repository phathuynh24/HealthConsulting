// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/other/feedback_doctor.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/custom_snackbar.dart';
import 'package:assist_health/src/widgets/my_separator.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class ScheduleFeedbackScreen extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;
  bool isFromCall;
  ScheduleFeedbackScreen(
      {required this.appointmentSchedule, required this.isFromCall, super.key});

  @override
  State<ScheduleFeedbackScreen> createState() => _ScheduleFeedbackScreenState();
}

class _ScheduleFeedbackScreenState extends State<ScheduleFeedbackScreen> {
  TextEditingController? _feedbackController;
  AppointmentSchedule? _appointmentSchedule;
  FeedbackDoctor? _feedback;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _appointmentSchedule = widget.appointmentSchedule;
    _feedbackController = TextEditingController();
    _feedback = FeedbackDoctor();
    _feedback!.rating = 5;
  }

  @override
  void dispose() {
    _feedbackController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromCall) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserNavBar()),
            (route) => false,
          );
        }

        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Themes.backgroundClr,
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text('Đánh giá bác sĩ'),
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: !widget.isFromCall,
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Thông tin bác sĩ
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                right: 15,
                              ),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: ClipOval(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Themes.gradientDeepClr,
                                              Themes.gradientLightClr
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        child: (_appointmentSchedule!
                                                    .doctorInfo!.imageURL !=
                                                '')
                                            ? Image.network(
                                                _appointmentSchedule!
                                                    .doctorInfo!.imageURL,
                                                fit: BoxFit.cover, errorBuilder:
                                                    (BuildContext context,
                                                        Object exception,
                                                        StackTrace?
                                                            stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    FontAwesomeIcons.userDoctor,
                                                    size: 60,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              })
                                            : Center(
                                                child: Text(
                                                  getAbbreviatedName(
                                                      _appointmentSchedule!
                                                          .doctorInfo!.name),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.greenAccent.shade700,
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 255,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _appointmentSchedule!
                                        .doctorInfo!.careerTitiles,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _appointmentSchedule!.doctorInfo!.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Text(
                                  //   '${DateTime.now().year - _appointmentSchedule!.doctorInfo!.graduationYear} năm kinh nghiệm',
                                  //   style: const TextStyle(
                                  //     color: Colors.black,
                                  //     fontSize: 15,
                                  //     height: 1.5,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Chuyên khoa: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(
                                height: 35,
                                width: 265,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _appointmentSchedule!
                                      .doctorInfo!.specialty.length,
                                  itemBuilder: (context, index) {
                                    final specialty = _appointmentSchedule!
                                        .doctorInfo!.specialty[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.blueGrey.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          specialty,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 5,
                      child: MySeparator(
                        color: Colors.grey,
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber.shade100.withOpacity(0.7),
                    ),
                    child: Column(children: [
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Vui lòng đánh giá chất lượng dịch vụ',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RatingBar.builder(
                        initialRating: 5,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 50,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 3.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          _feedback!.rating = rating;
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 5,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey.shade100.withOpacity(0.7),
                              hintText:
                                  'Chia sẻ về trải nghiệm khám của bạn (quá trình khám, sự tận tình của bác sĩ,...)'),
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            _feedback!.content = value;
                          },
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút "Lưu để đánh giá sau"
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.isFromCall) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserNavBar()),
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 20, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.blue), // Thêm viền để khác biệt
                        color: Colors.white, // Nền trắng để nhẹ nhàng hơn
                      ),
                      child: const Center(
                        child: Text(
                          'Đánh giá sau',
                          style: TextStyle(
                            color:
                                Colors.blue, // Chữ màu xanh để đồng bộ với viền
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Nút "Xác nhận & Gửi đánh giá"
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isSaving = true;
                      });
                      await saveFeedback();
                      setState(() {
                        _isSaving = false;
                      });
                      if (widget.isFromCall) {
                        _appointmentSchedule!.idFeedback =
                            _feedback!.idDoc.toString();
                        _appointmentSchedule!.updateAppointmentFeedback(
                            _appointmentSchedule!.idFeedback!);
                        CustomSnackbar.show(context, 'Đánh giá đã được gửi',
                            isSuccess: true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserNavBar()),
                        );
                      } else {
                        Navigator.of(context).pop(_feedback!.idDoc);
                      }
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      margin: const EdgeInsets.only(
                          bottom: 20, left: 10, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Themes
                            .gradientDeepClr, // Màu nổi bật để thu hút sự chú ý
                      ),
                      child: const Center(
                        child: Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const Opacity(
              opacity: 0.5, // Độ mờ của lớp phủ
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> saveFeedback() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_appointmentSchedule!.idDocUser)
          .get();
      if (userSnapshot.exists) {
        _feedback!.username = userSnapshot.get('name');
      }

      DocumentReference feedbackRef =
          FirebaseFirestore.instance.collection('feedback').doc();

      _feedback!.idDoc = feedbackRef.id;

      await feedbackRef.set({
        'username': _feedback!.username ?? '',
        'rating': _feedback!.rating,
        'content': _feedback!.content,
        'rateDate': DateTime.now(),
        'idDoctor': _appointmentSchedule!.doctorInfo!.uid,
        'idUser': _appointmentSchedule!.idDocUser!,
        'idDoc': _feedback!.idDoc,
      });

      print('Feedback saved successfully!');
    } catch (e) {
      print('Error saving feedback: $e');
    }
  }
}
