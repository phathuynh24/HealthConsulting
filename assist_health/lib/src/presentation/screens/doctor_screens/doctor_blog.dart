import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_blog_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Doctor_Blog extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Bài viết'),
        centerTitle: true,
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('blog').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final blogPosts = snapshot.data!.docs;
            return ListView.separated(
              itemCount: blogPosts.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                final blogData = blogPosts[index].data();
                final imageTitle = blogData['imageTitle'] ?? '';
                final title = blogData['title'] ?? 'No title';
                final verifiedDay = blogData['verifiedDay'] != null
                    ? DateFormat.yMd().format(blogData['verifiedDay'].toDate())
                    : 'Unknown date';
                final category = blogData['category'] ?? 'Uncategorized';
                final status = blogData['status'] ?? false;

                return ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageTitle.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: imageTitle,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 120,
                          ),
                        ),
                      const SizedBox(width: 10), // Add some spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                color: Themes.gradientDeepClr,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 4.0),
                            //   child: Text(
                            //     'Ngày đăng: $verifiedDay',
                            //     style: TextStyle(
                            //         fontSize: 14, fontWeight: FontWeight.w300),
                            //   ),
                            // ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 120,
                              height: 40,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: status
                                      ? const Color.fromARGB(255, 157, 231, 194)
                                      : const Color.fromARGB(
                                          255, 234, 235, 235),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: status
                                        ? const Color.fromARGB(
                                            255, 45, 180, 112)
                                        : const Color.fromARGB(
                                            255, 192, 196, 196),
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Icons.circle,
                                    size: 20,
                                    color: status
                                        ? const Color.fromARGB(
                                            255, 45, 180, 112)
                                        : const Color.fromARGB(
                                            255, 192, 196, 196),
                                  ),
                                  Container(width: 5),
                                  Text(
                                    status ? 'Đã duyệt' : 'Chờ duyệt',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DoctorBlogPage(blogData: blogData),
                      ),
                    );
                  },
                  trailing: Container(
                    width: 8,
                    height: 8,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
