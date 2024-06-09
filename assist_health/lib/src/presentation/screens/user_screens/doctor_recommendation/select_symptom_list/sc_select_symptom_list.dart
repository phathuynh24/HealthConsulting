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
  Map<String, List<String>> symptomsList = {
    'symptoms_Vi': [],
    'symptoms_En': [],
  };
  Map<String, List<String>> symptomsSelected = {
    'symptoms_Vi': [],
    'symptoms_En': [],
  };
  String textSymtoms = "";
  bool isSymptomsList = true;
  dynamic diagnosis = {};
  bool isDiagnosed = false;
  String query = "";

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
      body: SingleChildScrollView(
        child: BlocBuilder<SelectSymptomListBloc, SelectSymptomListState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  height: 320,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 260,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/recommendation/bg_gradient1.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 26),
                              Container(
                                height: 90,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isSymptomsList = true;
                                            _symptomsBloc.add(FetchSymptoms());
                                          });
                                        },
                                        child: Center(
                                          child: Container(
                                            height: 70,
                                            width: 170,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isSymptomsList
                                                  ? Colors.pinkAccent
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: EdgeInsets.all(14),
                                            child: Text(
                                              'Danh sách',
                                              style: TextStyle(
                                                color: isSymptomsList
                                                    ? Colors.white
                                                    : Colors.blueGrey.shade400,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          print(symptomsSelected);
                                          setState(() {
                                            isSymptomsList = false;
                                            _symptomsBloc.add(
                                                GetSelectedSymptom(
                                                    symptomsSelected));
                                          });
                                        },
                                        child: Center(
                                          child: Container(
                                            height: 70,
                                            width: 170,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: !isSymptomsList
                                                  ? Colors.pinkAccent
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: EdgeInsets.all(14),
                                            child: Text(
                                              'Đã chọn',
                                              style: TextStyle(
                                                color: !isSymptomsList
                                                    ? Colors.white
                                                    : Colors.blueGrey.shade400,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // _symptomsBloc.add(
                                        //     QueryChanged(query.toLowerCase()));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 5,
                                        ),
                                        child: Icon(Icons.search,
                                            color: Colors.blueAccent.shade700),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
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
                                            setState(() {
                                              query = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      onPressed: () {
                                        _selectedSymptoms_Vi.clear();
                                        _selectedSymptoms_En.clear();
                                        symptomsSelected['symptoms_Vi']
                                            ?.clear();
                                        symptomsSelected['symptoms_En']
                                            ?.clear();
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.refresh),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Lưu ý: Chọn từ 5 đến 17 biểu hiện bệnh để đảm bảo kết quả chính xác nhất.',
                                  style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<SelectSymptomListBloc,
                      SelectSymptomListState>(
                    builder: (context, state) {
                      if (state is SelectSymptomListLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is SelectSymptomListLoaded) {
                        if (state.symptoms['symptoms_Vi']?.length == 0) {
                          return Center(
                            child: Text('No symptoms found'),
                          );
                        }
                        print(state.symptoms['symptoms_Vi']?.length ?? 0);
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.symptoms['symptoms_Vi']?.length ?? 0,
                          itemBuilder: (context, index) {
                            final symptom_Vi =
                                state.symptoms['symptoms_Vi']?[index] ?? "";
                            final symptom_En =
                                state.symptoms['symptoms_En']?[index] ?? "";
                            bool isSelected =
                                _selectedSymptoms_Vi.contains(symptom_Vi);
                            return CheckboxListTile(
                              title: Text('${index + 1}. ${symptom_Vi}'),
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (_selectedSymptoms_Vi.length == 17) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Không thể chọn quá 17 biểu hiện bệnh.',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                      action: SnackBarAction(
                                        label: 'Đóng',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                      ),
                                    ),
                                  );
                                }
                                setState(() {
                                  if (value == true) {
                                    if (_selectedSymptoms_Vi.length < 17) {
                                      _selectedSymptoms_Vi.add(symptom_Vi);
                                      _selectedSymptoms_En.add(symptom_En);
                                      symptomsSelected['symptoms_Vi']
                                          ?.add(symptom_Vi);
                                      symptomsSelected['symptoms_En']
                                          ?.add(symptom_En);
                                    }
                                  } else {
                                    _selectedSymptoms_Vi.remove(symptom_Vi);
                                    _selectedSymptoms_En.remove(symptom_En);
                                    symptomsSelected['symptoms_Vi']
                                        ?.remove(symptom_Vi);
                                    symptomsSelected['symptoms_En']
                                        ?.remove(symptom_En);
                                  }
                                });
                              },
                            );
                          },
                        );
                      } else if (state is SelectSymptomListDiagnosed) {
                        Future.delayed(Duration(milliseconds: 500), () {
                          setState(() {
                            isDiagnosed = true;
                          });
                        });
                        diagnosis = jsonDecode(state.diagnosis);
                        return Center(
                          child: Text('Diagnosed Successfully'),
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
                ),
              ],
            );
          },
        ),
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
            if (_selectedSymptoms_Vi.length < 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Vui lòng chọn ít nhất 5 biểu hiện bệnh.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red.shade400,
                ),
              );
              return;
            }
            _symptomsBloc.add(
                SubmitSymptoms(textSymtoms, _selectedSymptoms_En.toList()));

            if (isDiagnosed) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DiseaseResultsScreen(
                    diagnosis: diagnosis,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isDiagnosed ? Colors.green : Themes.gradientDeepClr,
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
