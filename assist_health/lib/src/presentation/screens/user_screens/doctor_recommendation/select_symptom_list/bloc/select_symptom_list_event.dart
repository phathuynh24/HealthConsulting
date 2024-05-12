import 'package:equatable/equatable.dart';

abstract class SelectSymptomListEvent extends Equatable {
  const SelectSymptomListEvent();

  @override
  List<Object> get props => [];
}

class FetchSymptoms extends SelectSymptomListEvent {}

class SubmitSymptoms extends SelectSymptomListEvent {
  final List<String> symptoms;

  const SubmitSymptoms(this.symptoms);

  @override
  List<Object> get props => [symptoms];
}
