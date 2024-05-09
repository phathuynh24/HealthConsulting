import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'bloc.dart';

class SymptomsBloc extends Bloc<SymptomsEvent, SymptomsState> {
  static const String baseUrl = 'http://172.16.2.134:5000';

  SymptomsBloc() : super(SymptomsInitial()) {
    on<FetchSymptoms>(_onFetchSymptoms);
    on<SubmitSymptoms>(_onSubmitSymptoms);
  }

  void _onFetchSymptoms(
      FetchSymptoms event, Emitter<SymptomsState> emit) async {
    emit(SymptomsLoading());
    try {
      final symptoms = await getSymptoms();
      emit(SymptomsLoaded(symptoms));
    } catch (_) {
      emit(SymptomsError());
    }
  }

  void _onSubmitSymptoms(
      SubmitSymptoms event, Emitter<SymptomsState> emit) async {
    emit(SymptomsLoading());
    try {
      final diagnosis = await diagnoseSymptoms(event.symptoms);
      emit(SymptomsDiagnosed(diagnosis));
    } catch (_) {
      emit(SymptomsError());
    }
  }

  Future<Map<String, List<String>>> getSymptoms() async {
    final response = await http.get(Uri.parse('$baseUrl/get_symptoms'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<String> symptomsVi = List<String>.from(data['symptoms_Vi']);
      List<String> symptomsEn = List<String>.from(data['symptoms_En']);
      return {'symptoms_Vi': symptomsVi, 'symptoms_En': symptomsEn};
    } else {
      throw Exception('Failed to load symptoms');
    }
  }

  Future<String> diagnoseSymptoms(List<String> symptoms) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict_2'),
      body: jsonEncode({'symptoms': symptoms}),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to diagnose symptoms');
    }
  }
}
