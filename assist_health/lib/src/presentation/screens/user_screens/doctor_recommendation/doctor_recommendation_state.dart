abstract class DoctorRecommendationState {}

class DoctorRecommendationInitial extends DoctorRecommendationState {}

class DoctorRecommendationLoading extends DoctorRecommendationState {}

class DoctorRecommendationLoaded extends DoctorRecommendationState {
  final String recommendation;

  DoctorRecommendationLoaded(this.recommendation);
}

class DoctorRecommendationError extends DoctorRecommendationState {}