import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/blog_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BlogListPage extends StatefulWidget {
  @override
  _BlogListPageState createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  List<String> _savedPosts = [];
  User? _user;
  List<String> selectedFilterCategories = [];
  final List<String> categories = [
    "Ăn uống và dinh dưỡng",
    "Vấn đề sức khỏe tâm lý",
    "Mẹ và bé",
    "Hỏi đáp về sức khỏe",
  ];
  final Map<String, Color> categoryColors = {
    "Ăn uống và dinh dưỡng": Colors.blue,
    "Vấn đề sức khỏe tâm lý": Colors.green,
    "Mẹ và bé": Colors.orange,
    "Hỏi đáp về sức khỏe": Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
        if (_user != null) {
          _loadSavedPosts();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSavedPosts() async {
    if (_user == null) return;
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    setState(() {
      _savedPosts = List<String>.from(doc.data()?['savedPosts'] ?? []);
    });
  }

  void _savePostsToFirestore() async {
    if (_user == null) return;
    await _firestore.collection('users').doc(_user!.uid).set({
      'savedPosts': _savedPosts,
    }, SetOptions(merge: true));
  }

  void _toggleSavePost(String postId) {
    setState(() {
      if (_savedPosts.contains(postId)) {
        _savedPosts.remove(postId);
      } else {
        _savedPosts.add(postId);
      }
    });
    _savePostsToFirestore();
  }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Themes.gradientLightClr,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              // indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Bài viết',
                ),
                Tab(
                  icon: Icon(Icons.archive),
                  text: 'Lưu trữ',
                ),
              ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBlogList(),
          _buildSavedBlogList(),
        ],
      ),
    );
  }

  Widget _buildBlogList() {
    Query<Map<String, dynamic>> query =
        _firestore.collection('blog').where('status', isEqualTo: true);
    // if (selectedFilterCategories.isNotEmpty) {
    //   if (selectedFilterCategories.contains('Khác')) {
    //     List<String> otherCategories =
    //         categories.where((category) => category != 'Khác').toList();
    //     query = query.where('type', whereNotIn: otherCategories);
    //   } else {
    //     query = query.where('type', whereIn: selectedFilterCategories);
    //   }
    // }

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
              final blogId = blogPosts[index].id;
              final imageTitle = blogData['imageTitle'] ?? '';
              final title = blogData['title'] ?? 'No title';
              final verifiedDay = blogData['verifiedDay'] != null
                  ? DateFormat.yMd().format(blogData['verifiedDay'].toDate())
                  : 'Unknown date';
              final category = blogData['category'] ?? 'Uncategorized';

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
                          width: 80,
                          height: 95,
                        ),
                      ),
                    const SizedBox(width: 10),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Ngày đăng: $verifiedDay',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w300),
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
                trailing: SizedBox(
                  width: 20, // Adjust the width to make it smaller
                  child: IconButton(
                    icon: Icon(
                      _savedPosts.contains(blogId)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: _savedPosts.contains(blogId)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleSavePost(blogId);
                    },
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
    );
  }

  Widget _buildSavedBlogList() {
    if (_savedPosts.isEmpty) {
      return const Center(child: Text('No saved posts'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('blog')
          .where(FieldPath.documentId, whereIn: _savedPosts)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final savedBlogPosts = snapshot.data!.docs;
          return ListView.separated(
            itemCount: savedBlogPosts.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
            itemBuilder: (context, index) {
              final blogData = savedBlogPosts[index].data();
              final blogId = savedBlogPosts[index].id;
              final imageTitle = blogData['imageTitle'] ?? '';
              final title = blogData['title'] ?? 'No title';
              final verifiedDay = blogData['verifiedDay'] != null
                  ? DateFormat.yMd().format(blogData['verifiedDay'].toDate())
                  : 'Unknown date';
              final category = blogData['category'] ?? 'Uncategorized';

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
                          width: 80,
                          height: 90,
                        ),
                      ),
                    const SizedBox(width: 10),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Ngày đăng: $verifiedDay',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w300),
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
                  icon: Icon(
                    _savedPosts.contains(blogId)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: _savedPosts.contains(blogId)
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onPressed: () {
                    _toggleSavePost(blogId);
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
                              style: TextStyle(
                                fontSize: 15,
                              ),
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
                  icon: Icon(Icons.cancel, color: Colors.red),
                  style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(130, 30)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
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
