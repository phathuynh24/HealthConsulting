import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/add_product.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Stream<QuerySnapshot> _productStream;
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Hỗ trợ hô hấp',
    'Dinh dưỡng',
    'Hỗ trợ làm đẹp',
    'Hỗ trợ tiêu hóa',
    'Phát triển trẻ nhỏ',
    'Vitamin - khoáng chất'
  ];

  @override
  void initState() {
    super.initState();
    _productStream =
        FirebaseFirestore.instance.collection('products').snapshots();
  }

  // Hàm để lọc danh sách sản phẩm theo loại sản phẩm được chọn
  List<Product> filterProductsByCategory(List<Product> products) {
    if (_selectedCategory == 'Tất cả') {
      return products; // Trả về danh sách sản phẩm gốc nếu loại sản phẩm được chọn là 'Tất cả'
    } else {
      return products
          .where((product) => product.category == _selectedCategory)
          .toList(); // Lọc danh sách sản phẩm theo loại sản phẩm được chọn
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      print('Xóa sản phẩm thành công');
    } catch (e) {
      print('Đã xảy ra lỗi khi xóa sản phẩm: $e');
    }
  }

  Future<void> showDeleteConfirmationDialog(String productId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                await deleteProduct(productId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Danh sách sản phẩm',
          style: TextStyle(fontSize: 20),
        ),
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
          // Thêm nút PopupMenuButton để chọn loại sản phẩm
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white, // Màu của biểu tượng
            ),
            onSelected: (String value) {
              setState(() {
                _selectedCategory = value; // Cập nhật loại sản phẩm được chọn
              });
            },
            itemBuilder: (BuildContext context) {
              return _categories.map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.black, // Màu của chữ
                    ),
                  ),
                );
              }).toList();
            },
            color: Colors.white,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final List<Product> products = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Product(
                id: doc.id,
                name: data['name'],
                price: data['price'],
                oldPrice: data['old_price'],
                quantity: data['quantity'],
                imageUrls: List<String>.from(data['imageUrls']),
                category: data['category']);
          }).toList();

          final List<Product> filteredProducts = filterProductsByCategory(
              products); // Lọc danh sách sản phẩm theo loại sản phẩm được chọn

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (BuildContext context, int index) {
              final Product product = filteredProducts[index];
              final bool isEven = index % 2 == 0;
              final Color? tileColor = isEven ? Colors.white : Colors.grey[200];

              return Card(
                color: tileColor, // Màu nền của Card
                elevation: 4, // Độ nâng của Card
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Bo tròn góc của Card
                ),
                child: InkWell(
                  onTap: () {
                    // Xử lý khi người dùng nhấn vào ListTile
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8), // Đệm bao quanh nội dung của ListTile
                    child: Row(
                      children: [
                        // Leading (Ảnh)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8), // Bo tròn góc của ảnh
                          child: Image.network(
                            product.imageUrls.isNotEmpty
                                ? product.imageUrls[0]
                                : '', // Lấy URL ảnh đầu tiên từ danh sách, hoặc trả về chuỗi rỗng nếu danh sách trống
                            width: 80, // Chiều rộng của ảnh
                            height: 80, // Chiều cao của ảnh
                            fit: BoxFit
                                .cover, // Thay đổi kích thước ảnh để nó phù hợp với không gian được cung cấp
                          ),
                        ),
                        const SizedBox(
                            width: 16), // Khoảng cách giữa ảnh và nội dung

                        // Title và Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      4), // Khoảng cách giữa title và subtitle
                              Text(
                                'Giá: ${product.price}, Số lượng: ${product.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        // Trailing (IconButton)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              showDeleteConfirmationDialog(product.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: Themes.gradientLightClr,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
