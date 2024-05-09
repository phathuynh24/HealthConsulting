import 'package:equatable/equatable.dart';

abstract class SymptomsState extends Equatable {
  const SymptomsState();

  @override
  List<Object> get props => [];
}

class SymptomsInitial extends SymptomsState {}

class SymptomsLoading extends SymptomsState {}

class SymptomsLoaded extends SymptomsState {
  final Map<String, List<String>> symptoms;

  const SymptomsLoaded(this.symptoms);

  @override
  List<Object> get props => [symptoms];
}

class SymptomsError extends SymptomsState {}

class SymptomsDiagnosed extends SymptomsState {
  final String diagnosis;

  const SymptomsDiagnosed(this.diagnosis);

  @override
  List<Object> get props => [diagnosis];
}