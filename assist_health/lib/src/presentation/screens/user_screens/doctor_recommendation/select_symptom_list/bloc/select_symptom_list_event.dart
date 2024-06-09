import 'package:equatable/equatable.dart';

abstract class SelectSymptomListEvent extends Equatable {
  const SelectSymptomListEvent();

  @override
  List<Object> get props => [];
}

class FetchSymptoms extends SelectSymptomListEvent {}

class SubmitSymptoms extends SelectSymptomListEvent {
  final String text;
  final List<String> symptoms;

  const SubmitSymptoms(this.text, this.symptoms);

  @override
  List<Object> get props => [symptoms];
}

class QueryChanged extends SelectSymptomListEvent {
  final String query;

  QueryChanged(this.query);
}

class GetSelectedSymptom extends SelectSymptomListEvent {
  final Map<String, List<String>> symptoms;

  const GetSelectedSymptom(this.symptoms);

  @override
  List<Object> get props => [symptoms];
}
