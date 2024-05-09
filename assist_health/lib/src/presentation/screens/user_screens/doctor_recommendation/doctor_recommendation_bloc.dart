// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'doctor_recommendation_event.dart';
// import 'doctor_recommendation_state.dart';
// import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// class DoctorRecommendationBloc
//     extends Bloc<DoctorRecommendationEvent, DoctorRecommendationState> {
//   var modelPath = 'assets/bert_model/model.tflite';
//   var vocabPath = 'assets/bert_model/vocab.txt';
//   var numClasses = 24;

//   DoctorRecommendationBloc() : super(DoctorRecommendationInitial());

//   Stream<DoctorRecommendationState> mapEventToState(
//       DoctorRecommendationEvent event) async* {
//     if (event is GetDoctorRecommendation) {
//       yield DoctorRecommendationLoading();

//       try {
//         // Lấy thông tin triệu chứng từ sự kiện
//         final symptom = event.symptom;

//         // Chuẩn bị dữ liệu cho mô hình (chuyển đổi các token thành đầu vào mô hình)
//         var input = await prepareModelInput(symptom);

//         // Tải mô hình TensorFlow Lite
//         var interpreter = await tfl.Interpreter.fromAsset(modelPath);

//         // Dự đoán bệnh từ đầu vào
//         var output = List<double>.filled(numClasses, 0.0);
//         interpreter.run(input, output);

//         // Xử lý kết quả dự đoán
//         String recommendation = await processModelOutput(output);

//         yield DoctorRecommendationLoaded(recommendation);
//       } catch (e) {
//         yield DoctorRecommendationError();
//       }
//     }
//   }

//   Future<List<List<int>>> prepareModelInput(String text) async {
//     final tokenizer = BertTokenizer.fromFile(vocabPath);
//     final encodedInput = tokenizer.encodeBatch([text]);
//     final inputIds = encodedInput[0].inputIds;
//     final attentionMask = encodedInput[0].attentionMask;

//     // Tạo đầu vào cho mô hình
//     final modelInput = [
//       inputIds,
//       attentionMask,
//     ];

//     return modelInput;
//   }

//   Future<String> processModelOutput(List<double> modelOutput) async {
//     // Xử lý kết quả đầu ra từ mô hình
//     // Ví dụ: Giải mã các mã thông báo thành văn bản
//     final tokenizer = BertTokenizer.fromFile(vocabPath);
//     final decodedOutput = tokenizer.decodeBatch([modelOutput]);

//     // Trả về văn bản đã được xử lý từ kết quả đầu ra
//     return decodedOutput[0];
//   }
// }
