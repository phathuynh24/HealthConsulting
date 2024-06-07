import 'dart:convert';

import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_recommendation/disease_results/sc_disease_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';

class SelectSymptomListScreen extends StatefulWidget {
  final String textSymtoms;
  const SelectSymptomListScreen({Key? key, required this.textSymtoms})
      : super(key: key);

  @override
  _SelectSymptomListScreenState createState() =>
      _SelectSymptomListScreenState();
}

class _SelectSymptomListScreenState extends State<SelectSymptomListScreen> {
  late SelectSymptomListBloc _symptomsBloc;
  final _selectedSymptoms_Vi = <String>{};
  final _selectedSymptoms_En = <String>{};
  Map<String, List<String>> symptomsTemp = {
    'symptoms_Vi': [],
    'symptoms_En': [],
  };
  String textSymtoms = "";

  @override
  void initState() {
    super.initState();
    textSymtoms = widget.textSymtoms;
    _symptomsBloc = context.read<SelectSymptomListBloc>();
    _symptomsBloc.add(FetchSymptoms());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Themes.gradientDeepClr,
        toolbarHeight: 50,
        title: const Text('Chọn các biểu hiện bệnh'),
        titleTextStyle: const TextStyle(fontSize: 16),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            width: double.infinity,
            height: 45,
            color: Colors.white,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: Colors.blueAccent.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Nhập triệu chứng',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueAccent.shade700,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Chọn biểu hiện bệnh',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 30,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Đề xuất bác sĩ phù hợp',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SelectSymptomListBloc, SelectSymptomListState>(
        builder: (context, state) {
          if (state is SelectSymptomListLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SelectSymptomListLoaded) {
            symptomsTemp = state.symptoms;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.blueAccent.withOpacity(0.1),
                        child: Text(
                          'Danh sách triệu chứng',
                          style: TextStyle(
                            color: Colors.blueAccent.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.blueAccent.withOpacity(0.1),
                        child: Text(
                          'Triệu chứng của bạn',
                          style: TextStyle(
                            color: Colors.blueAccent.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blueAccent.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 5,
                        ),
                        child: Icon(Icons.search,
                            color: Colors.blueAccent.shade700),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.blueAccent.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm triệu chứng...',
                              hintStyle: TextStyle(
                                color: Colors.blueAccent.shade700,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: Colors.blueAccent.shade700,
                              fontSize: 14,
                            ),
                            onChanged: (value) {
                              // _searchSymptoms(state.symptoms, value);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () {
                          _selectedSymptoms_Vi.clear();
                          _selectedSymptoms_En.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.greenAccent.withOpacity(0.2),
                  child: Text(
                    'Lưu ý: Chọn từ 5 đến 17 biểu hiện bệnh để đảm bảo kết quả chính xác nhất.',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: symptomsTemp['symptoms_Vi']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final symptom = symptomsTemp['symptoms_Vi']?[index] ?? "";
                      return CheckboxListTile(
                        title: Text('${index + 1}. $symptom'),
                        value: _selectedSymptoms_Vi.contains(symptom),
                        onChanged: (bool? value) {
                          String symptom_En =
                              state.symptoms['symptoms_En']?[index] ?? "";
                          setState(() {
                            if (value == true) {
                              if (_selectedSymptoms_Vi.length < 17) {
                                _selectedSymptoms_Vi.add(symptom);
                                _selectedSymptoms_En.add(symptom_En);
                              }
                            } else {
                              _selectedSymptoms_Vi.remove(symptom);
                              _selectedSymptoms_En.remove(symptom_En);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is SelectSymptomListDiagnosed) {
            final diagnosis = jsonDecode(state.diagnosis);
            return ListView.builder(
              itemCount: diagnosis['disease'].length,
              itemBuilder: (context, index) {
                final disease = diagnosis['disease'][index][0];
                final vietnamese = diagnosis['disease'][index][1];
                final percentage = diagnosis['disease'][index][2];

                // Determine the background color based on whether the index is even or odd
                final color = index % 2 == 0 ? Colors.white : Colors.grey[200];

                return Container(
                  color: color,
                  child: ListTile(
                    title: Text(
                      '$disease - $vietnamese - $percentage',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              },
            );
          } else if (state is SelectSymptomListError) {
            return Center(
              child: Text('Failed to load symptoms'),
            );
          } else {
            return Center(
              child: Text('Unknown state'),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey,
              width: 0.2,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            // _symptomsBloc.add(
            //     SubmitSymptoms(textSymtoms, _selectedSymptoms_En.toList()));
            Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => DiseaseResultsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Themes.gradientDeepClr,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
