import 'package:flutter/material.dart';

class RecommendedResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Results'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  // Image section
                  height: 400,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Image Section',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Subtitle',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              height: 0,
            ),
            Container(
              // Body section
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Introduction row
                  Row(
                    children: [
                      Text(
                        'Danh sách bác sĩ khuyến nghị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // ListView
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 10, // Replace with your actual item count
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Item $index'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
