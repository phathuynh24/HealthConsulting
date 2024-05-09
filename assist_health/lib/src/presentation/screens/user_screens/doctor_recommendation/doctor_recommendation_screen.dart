import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc.dart';

class DoctorRecommendationScreen extends StatefulWidget {
  @override
  _DoctorRecommendationScreenState createState() =>
      _DoctorRecommendationScreenState();
}

class _DoctorRecommendationScreenState
    extends State<DoctorRecommendationScreen> {
  final _symptomController = TextEditingController();

  void _onRecommendButtonPressed(BuildContext context) {
    context
        .read<DoctorRecommendationBloc>()
        .add(GetDoctorRecommendation(_symptomController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorRecommendationBloc(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Themes.backgroundClr,
          appBar: AppBar(
            foregroundColor: Colors.white,
            toolbarHeight: 50,
            title: const Text('Đề xuất bác sĩ từ triệu chứng'),
            titleTextStyle: const TextStyle(fontSize: 16),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _symptomController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Enter symptoms',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _onRecommendButtonPressed(context),
                  child: Text('Recommend'),
                ),
                SizedBox(height: 16.0),
                BlocBuilder<DoctorRecommendationBloc,
                    DoctorRecommendationState>(
                  builder: (context, state) {
                    if (state is DoctorRecommendationLoading)
                      return CircularProgressIndicator();
                    else if (state is DoctorRecommendationLoaded)
                      return Text('Disease: ${state.recommendation}');
                    else if (state is DoctorRecommendationError)
                      return Text('Error occurred');
                    else
                      return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
