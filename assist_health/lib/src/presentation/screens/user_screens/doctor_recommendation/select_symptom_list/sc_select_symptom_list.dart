import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';

class SelectSymptomListScreen extends StatefulWidget {
  @override
  _SelectSymptomListScreenState createState() =>
      _SelectSymptomListScreenState();
}

class _SelectSymptomListScreenState extends State<SelectSymptomListScreen> {
  late SelectSymptomListBloc _symptomsBloc;
  final _selectedSymptoms_Vi = <String>{};
  final _selectedSymptoms_En = <String>{};

  @override
  void initState() {
    super.initState();
    _symptomsBloc = context.read<SelectSymptomListBloc>();
    _symptomsBloc.add(FetchSymptoms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Symptoms'),
      ),
      body: BlocBuilder<SelectSymptomListBloc, SelectSymptomListState>(
        builder: (context, state) {
          if (state is SelectSymptomListLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SelectSymptomListLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.symptoms['symptoms_Vi']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final symptom =
                          state.symptoms['symptoms_Vi']?[index] ?? "";
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
                ElevatedButton(
                  onPressed: () {
                    _symptomsBloc
                        .add(SubmitSymptoms(_selectedSymptoms_En.toList()));
                    print(_selectedSymptoms_En.toList());
                    print(_selectedSymptoms_Vi.toList());
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          } else if (state is SelectSymptomListDiagnosed) {
            final diagnosis = jsonDecode(state.diagnosis);
            return ListView.builder(
              itemCount: diagnosis['disease'].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${diagnosis['disease'][index]['Disease_Vi']} - ${diagnosis['disease'][index]['Score'].toStringAsFixed(2)}'),
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
    );
  }
}
