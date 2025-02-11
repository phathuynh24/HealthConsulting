import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/doctor_info_account_screen.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/doctor_profile_add.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorProfileList extends StatefulWidget {
  const DoctorProfileList({Key? key}) : super(key: key);

  @override
  State<DoctorProfileList> createState() => _DoctorProfileListState();
}

class _DoctorProfileListState extends State<DoctorProfileList> {
  String _searchQuery = '';
  String _sortOption = 'name_asc';
  String _filterSpecialty = 'Tất cả';
  final List<String> _specialtyOptions = [
    'Tất cả',
    "Bệnh lý học",
    "Bệnh truyền nhiễm",
    "Bệnh nhiệt đới",
    "Chấn thương chỉnh hình",
    "Chỉnh hình nhi",
    "Chẩn đoán hình ảnh",
    "Da liễu",
    "Dinh dưỡng",
    "Dị ứng - Miễn dịch",
    "Gây mê hồi sức",
    "Hô hấp",
    "Huyết học",
    "Mắt",
    "Nam khoa",
    "Nha khoa",
    "Nhi khoa",
    "Nội thần kinh",
    "Nội tiết",
    "Nội tiết Nhi",
    "Ngoại tổng quát",
    "Phục hồi chức năng",
    "Sản phụ khoa",
    "Tay mũi họng",
    "Tai Mũi Họng Nhi",
    "Thần kinh",
    "Thần kinh ngoại biên",
    "Thận - Tiết niệu",
    "Thẩm mỹ",
    "Tim mạch",
    "Tiêu hóa",
    "Ung bướu",
    "Y học cổ truyền",
    "Y học thể thao",
  ];

  final Map<String, bool> _selectedDoctors = {};
  List<Map<String, dynamic>> _localDoctors = [];
  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 242, 249),
      appBar: AppBar(
        title: const Text('Danh sách bác sĩ', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        foregroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchAndFilter(),
            _buildDoctorList(),
            const SizedBox(height: 160),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: _selectedDoctors.values.contains(true)
                  ? _markDoctorsAsDeleted
                  : null,
              backgroundColor: _selectedDoctors.values.contains(true)
                  ? Colors.redAccent
                  : Colors.grey,
              tooltip: 'Xóa các bác sĩ đã chọn',
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddDoctorScreen()),
                ).then((_) {
                  _refreshDoctorList(); // Tải lại danh sách sau khi thêm
                });
              },
              backgroundColor: Themes.gradientDeepClr,
              tooltip: 'Thêm bác sĩ',
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên bác sĩ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Lọc theo chuyên khoa',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _filterSpecialty,
                  isExpanded: true, // Giúp dropdown mở rộng hết chiều rộng
                  items: _specialtyOptions.map((specialty) {
                    return DropdownMenuItem<String>(
                      value: specialty,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 200, // Giới hạn chiều rộng tối đa của item
                        ),
                        child: Text(
                          specialty,
                          overflow:
                              TextOverflow.ellipsis, // Thêm dấu "…" nếu quá dài
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterSpecialty = value ?? 'Tất cả';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortOption,
                items: const [
                  DropdownMenuItem(value: 'name_asc', child: Text('Tên A-Z')),
                  DropdownMenuItem(value: 'name_desc', child: Text('Tên Z-A')),
                  DropdownMenuItem(value: 'date_new', child: Text('Mới nhất')),
                  DropdownMenuItem(value: 'date_old', child: Text('Cũ nhất')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortOption = value ?? 'name_asc';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList() {
    if (!_isDataLoaded) {
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải dữ liệu.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Chưa có bác sĩ nào trong danh sách.'));
          }

          // Populate the local data on initial fetch
          _localDoctors = snapshot.data!.docs.map((doc) {
            return {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            };
          }).toList();
          _isDataLoaded = true;

          return _buildDoctorListView();
        },
      );
    }

    return _buildDoctorListView();
  }

  Widget _buildDoctorListView() {
    // Filter and sort locally
    var filteredDoctors = _localDoctors.where((doc) {
      if (doc['isDeleted'] == true) return false; // Bỏ qua bác sĩ đã xóa
      final name = doc['name'] as String? ?? '';
      if (_searchQuery.isNotEmpty &&
          !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterSpecialty != 'Tất cả' &&
          !(doc['specialty'] as List<dynamic>?)!.contains(_filterSpecialty)) {
        return false;
      }
      return true;
    }).toList();

    // Sort locally
    if (_sortOption == 'name_asc') {
      filteredDoctors
          .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } else if (_sortOption == 'name_desc') {
      filteredDoctors
          .sort((a, b) => (b['name'] as String).compareTo(a['name'] as String));
    } else if (_sortOption == 'date_new') {
      filteredDoctors.sort((a, b) =>
          (b['createdAt'] as String).compareTo(a['createdAt'] as String));
    } else if (_sortOption == 'date_old') {
      filteredDoctors.sort((a, b) =>
          (a['createdAt'] as String).compareTo(b['createdAt'] as String));
    }

    if (filteredDoctors.isEmpty) {
      return const Center(child: Text('Không tìm thấy bác sĩ nào.'));
    }

    // Build the list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        return _buildDoctorItem(context, doctor);
      },
    );
  }

  Widget _buildDoctorItem(BuildContext context, Map<String, dynamic> doctor) {
    final id = doctor['id'] as String;
    final name = doctor['name'] as String? ?? '';
    final specialties = List<String>.from(doctor['specialty'] ?? []);
    final isSelected = _selectedDoctors[id] ?? false;
    final imageUrl = doctor['imageURL'] as String? ?? '';
    final isFirstLogin =
        doctor['isFirstLogin'] as bool? ?? false; // Kiểm tra đăng nhập lần đầu

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorInfoAccountScreen(doctorId: id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: isFirstLogin
              ? Border.all(
                  color: Colors.green,
                  width: 2) // Đường viền xanh cho bác sĩ mới
              : null,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        padding: const EdgeInsets.all(10),
        child: ListTile(
          leading: Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueGrey,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                radius: 25,
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
              if (isFirstLogin)
                const Icon(
                  Icons.fiber_new, // Biểu tượng "mới"
                  color: Colors.red,
                  size: 18,
                ),
            ],
          ),
          title: Row(
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 6),
              if (isFirstLogin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Mới',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            specialties.join(', '),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          trailing: Checkbox(
            value: isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedDoctors[id] = true;
                } else {
                  _selectedDoctors.remove(id);
                }
              });
            },
          ),
        ),
      ),
    );
  }

  void _markDoctorsAsDeleted() async {
    List<String> idsToDelete = _selectedDoctors.keys
        .where((id) => _selectedDoctors[id] == true)
        .toList();

    // Xóa dữ liệu trên Firestore
    for (var id in idsToDelete) {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
      });
    }

    // Xóa khỏi danh sách cục bộ
    setState(() {
      _localDoctors.removeWhere((doc) => idsToDelete.contains(doc['id']));
      _selectedDoctors.clear();
    });
  }

  void _refreshDoctorList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('isDeleted', isEqualTo: false) // Chỉ lấy bác sĩ chưa bị xóa
          .get();

      setState(() {
        _localDoctors = snapshot.docs.map((doc) {
          return {
            ...doc.data(),
            'id': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error refreshing doctor list: $e');
    }
  }
}
