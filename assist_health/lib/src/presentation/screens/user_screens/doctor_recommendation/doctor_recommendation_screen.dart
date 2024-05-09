// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'doctor_recommendation_bloc.dart';
// import 'doctor_recommendation_event.dart';
// import 'doctor_recommendation_state.dart';

// class DoctorRecommendationScreen extends StatefulWidget {
//   @override
//   _DoctorRecommendationScreenState createState() =>
//       _DoctorRecommendationScreenState();
// }

// class _DoctorRecommendationScreenState
//     extends State<DoctorRecommendationScreen> {
//   TextEditingController _symptomController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DoctorRecommendationBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Doctor Recommendation'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: BlocBuilder<DoctorRecommendationBloc,
//               DoctorRecommendationState>(
//             builder: (context, state) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   TextField(
//                     controller: _symptomController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter symptoms',
//                     ),
//                   ),
//                   SizedBox(height: 16.0),
//                   ElevatedButton(
//                     onPressed: () {
//                       _onRecommendButtonPressed();
//                     },
//                     child: Text('Recommend'),
//                   ),
//                   SizedBox(height: 16.0),
//                   if (state is DoctorRecommendationLoading)
//                     CircularProgressIndicator()
//                   else if (state is DoctorRecommendationLoaded)
//                     Text('Doctor Recommendation: ${state.recommendation}')
//                   else if (state is DoctorRecommendationError)
//                     Text('Error occurred'),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _onRecommendButtonPressed() {
//     final symptom = _symptomController.text;
//     if (symptom.isNotEmpty) {
//       BlocProvider.of<DoctorRecommendationBloc>(context)
//           .add(GetDoctorRecommendation(symptom));
//     }
//   }
// }