import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'bloc.dart';

class DoctorRecommendationBloc
    extends Bloc<DoctorRecommendationEvent, DoctorRecommendationState> {
  DoctorRecommendationBloc() : super(DoctorRecommendationInitial()) {
    on<GetDoctorRecommendation>((event, emit) async {
      emit(DoctorRecommendationLoading());

      try {
        // Lấy thông tin triệu chứng từ sự kiện
        final symptom = await event.symptom.translate(to: 'en');

        // Gửi yêu cầu HTTP đến API Flask để dự đoán
        final response = await http.post(
          Uri.parse('http://172.16.2.134:5000/predict_1'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'text': symptom.toString(),
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          emit(DoctorRecommendationLoaded(data));
        } else {
          throw Exception('Failed to load recommendation');
        }
      } catch (e) {
        emit(DoctorRecommendationError());
      }
    });
  }
}
