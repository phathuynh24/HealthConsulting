import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'bloc.dart';

class EnterSymptomsBloc extends Bloc<EnterSymptomsEvent, EnterSymptomsState> {
  EnterSymptomsBloc() : super(EnterSymptomsInitial()) {
    on<GetSymptoms>((event, emit) async {
      emit(EnterSymptomsLoading());

      try {
        // Lấy thông tin triệu chứng từ sự kiện
        final symptom = await event.symptom.translate(to: 'en');

        // Gửi yêu cầu HTTP đến API Flask để dự đoán
        final response = await http.post(
          Uri.parse('http://192.168.130.93:5000/predict_1'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'text': symptom.toString(),
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          emit(EnterSymptomsLoaded(data));
        } else {
          throw Exception('Failed to load recommendation');
        }
      } catch (e) {
        emit(EnterSymptomsError());
      }
    });
  }
}
