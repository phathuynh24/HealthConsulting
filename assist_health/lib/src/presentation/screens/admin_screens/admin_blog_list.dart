import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/blog_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AdminBlog extends StatefulWidget {
  @override
  _AdminBlogState createState() => _AdminBlogState();
}

class _AdminBlogState extends State<AdminBlog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> selectedFilterCategories = [];
  final List<String> categories = [
    "Ăn uống và dinh dưỡng",
    "Vấn đề sức khỏe tâm lý",
    "Mẹ và bé",
    "Hỏi đáp về sức khỏe",
  ];

  // Define a map to associate each category with a color
  final Map<String, Color> categoryColors = {
    "Ăn uống và dinh dưỡng": Colors.blue,
    "Vấn đề sức khỏe tâm lý": Colors.green,
    "Mẹ và bé": Colors.orange,
    "Hỏi đáp về sức khỏe": Colors.purple,
  };

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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showCategoryFilterDialog(context).then((selectedCategories) {
                if (selectedCategories != null) {
                  setState(() {
                    selectedFilterCategories = selectedCategories;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: _buildBlogList(),
    );
  }

  Widget _buildBlogList() {
    Query<Map<String, dynamic>> query = _firestore.collection('blog');

    if (selectedFilterCategories.isNotEmpty) {
      query = query.where('type', whereIn: selectedFilterCategories);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
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
              final blogId = blogPosts[index].id; // Lấy ID của blog
              final imageTitle = blogData['imageTitle'] ?? '';
              final title = blogData['title'] ?? 'No title';
              final verifiedDay = blogData['verifiedDay'] != null
                  ? DateFormat.yMd().format(blogData['verifiedDay'].toDate())
                  : 'Unknown date';
              final category = blogData['category'] ?? 'Uncategorized';
              final status = blogData['status'] ?? false;

              // Get the color for the category
              final categoryColor = categoryColors[category] ?? Colors.grey;

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
                            style: TextStyle(
                              color: categoryColor,
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
                                    : const Color.fromARGB(255, 234, 235, 235),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: status
                                      ? const Color.fromARGB(255, 45, 180, 112)
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
                                      ? const Color.fromARGB(255, 45, 180, 112)
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
                      builder: (context) => BlogPage(blogData: blogData),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text(
                              'Bạn có chắc chắn muốn xóa bài viết này không?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await _firestore.collection('blog').doc(blogId).delete();
                    }
                  },
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
    );
  }

  Future<List<String>?> _showCategoryFilterDialog(BuildContext context) async {
    List<String> selectedCategoriesCopy = List.from(selectedFilterCategories);

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chọn chủ đề',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 250,
            width: 400,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categories.map((category) {
                      final isSelected =
                          selectedCategoriesCopy.contains(category);
                      return CheckboxListTile(
                        title: Row(
                          children: [
                            Text(
                              category,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedCategoriesCopy.add(category);
                              } else {
                                selectedCategoriesCopy.remove(category);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  icon: Icon(Icons.cancel, color: Colors.red),
                  label: Text("Hủy", style: TextStyle(color: Colors.red)),
                ),
                TextButton.icon(
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(selectedCategoriesCopy);
                  },
                  style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(130, 30)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  label:
                      Text("Xác nhận", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
