import 'package:equatable/equatable.dart';

abstract class SymptomsEvent extends Equatable {
  const SymptomsEvent();

  @override
  List<Object> get props => [];
}

class FetchSymptoms extends SymptomsEvent {}

class SubmitSymptoms extends SymptomsEvent {
  final List<String> symptoms;

  const SubmitSymptoms(this.symptoms);

  @override
  List<Object> get props => [symptoms];
}
