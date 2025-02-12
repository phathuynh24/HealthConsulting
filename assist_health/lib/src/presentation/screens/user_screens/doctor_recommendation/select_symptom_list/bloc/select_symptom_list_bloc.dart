import 'dart:convert';

import 'package:assist_health/src/presentation/screens/user_screens/meals/core/network/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../utils/config.dart';
import 'bloc.dart';

class SelectSymptomListBloc
    extends Bloc<SelectSymptomListEvent, SelectSymptomListState> {
  SelectSymptomListBloc() : super(SelectSymptomListInitial()) {
    on<FetchSymptoms>(_onFetchSymptoms);
    on<SubmitSymptoms>(_onSubmitSymptoms);
    on<QueryChanged>(_onQueryChanged);
    on<GetSelectedSymptom>(_onGetSelectedSymptom);
  }

  void _onFetchSymptoms(
      FetchSymptoms event, Emitter<SelectSymptomListState> emit) async {
    emit(SelectSymptomListLoading());
    try {
      final symptoms = await getSymptoms();
      emit(SelectSymptomListLoaded(symptoms));
    } catch (_) {
      emit(SelectSymptomListError());
    }
  }

  void _onSubmitSymptoms(
      SubmitSymptoms event, Emitter<SelectSymptomListState> emit) async {
    emit(SelectSymptomListLoading());
    try {
      final diagnosis = await diagnoseSymptoms(event.text, event.symptoms);
      emit(SelectSymptomListDiagnosed(diagnosis));
    } catch (_) {
      emit(SelectSymptomListError());
    }
  }

  void _onQueryChanged(
      QueryChanged event, Emitter<SelectSymptomListState> emit) async {
    emit(SelectSymptomListLoading());
    try {
      final symptoms = await getSymptoms();
      final symptomsFilter = symptoms.map((key, value) => MapEntry(
          key,
          value
              .where((element) => element.toLowerCase().contains(event.query))
              .toList()));
      emit(SelectSymptomListLoaded(symptomsFilter));
    } catch (_) {
      emit(SelectSymptomListError());
    }
  }

  void _onGetSelectedSymptom(
      GetSelectedSymptom event, Emitter<SelectSymptomListState> emit) async {
    emit(SelectSymptomListLoaded(event.symptoms));
  }

  Future<Map<String, List<String>>> getSymptoms() async {
    final response =
        await http.get(Uri.parse('${ApiConstants.baseUrl}/get_symptoms'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<String> symptomsVi = List<String>.from(data['symptoms_Vi']);
      List<String> symptomsEn = List<String>.from(data['symptoms_En']);
      return {'symptoms_Vi': symptomsVi, 'symptoms_En': symptomsEn};
    } else {
      throw Exception('Failed to load symptoms');
    }
  }

  Future<String> diagnoseSymptoms(String text, List<String> symptoms) async {
    symptoms = symptoms.map((e) => e.toLowerCase()).toList();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/predict_disease_weighted_combination'),
      body: jsonEncode({
        'weights': [0.3, 0.7],
        'text': text,
        'symptoms': symptoms
      }),
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

  // Future<String> diagnoseSymptoms(List<String> symptoms) async {
  //   final response = await http.post(
  //     Uri.parse('${ApiConstants.baseUrl}/predict_2'),
  //     body: jsonEncode({
  //       'weights': [0.3, 0.7],
  //       'text': "",
  //       'symptoms': symptoms
  //       }),
  //     headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     return response.body;
  //   } else {
  //     throw Exception('Failed to diagnose symptoms');
  //   }
  // }
}
