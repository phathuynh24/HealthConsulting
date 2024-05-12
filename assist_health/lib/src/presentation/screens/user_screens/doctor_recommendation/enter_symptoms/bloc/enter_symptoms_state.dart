abstract class EnterSymptomsState {}

class EnterSymptomsInitial extends EnterSymptomsState {}

class EnterSymptomsLoading extends EnterSymptomsState {}

class EnterSymptomsLoaded extends EnterSymptomsState {
  final String symptoms;

  EnterSymptomsLoaded(this.symptoms);
}

class EnterSymptomsError extends EnterSymptomsState {}
