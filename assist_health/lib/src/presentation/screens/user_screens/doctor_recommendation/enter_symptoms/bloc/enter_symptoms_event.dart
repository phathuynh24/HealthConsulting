abstract class EnterSymptomsEvent {}

class GetSymptoms extends EnterSymptomsEvent {
  final String symptom;

  GetSymptoms(this.symptom);
}
