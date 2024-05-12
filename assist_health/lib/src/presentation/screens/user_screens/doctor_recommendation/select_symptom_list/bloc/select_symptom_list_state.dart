import 'package:equatable/equatable.dart';

abstract class SelectSymptomListState extends Equatable {
  const SelectSymptomListState();

  @override
  List<Object> get props => [];
}

class SelectSymptomListInitial extends SelectSymptomListState {}

class SelectSymptomListLoading extends SelectSymptomListState {}

class SelectSymptomListLoaded extends SelectSymptomListState {
  final Map<String, List<String>> symptoms;

  const SelectSymptomListLoaded(this.symptoms);

  @override
  List<Object> get props => [symptoms];
}

class SelectSymptomListError extends SelectSymptomListState {}

class SelectSymptomListDiagnosed extends SelectSymptomListState {
  final String diagnosis;

  const SelectSymptomListDiagnosed(this.diagnosis);

  @override
  List<Object> get props => [diagnosis];
}
