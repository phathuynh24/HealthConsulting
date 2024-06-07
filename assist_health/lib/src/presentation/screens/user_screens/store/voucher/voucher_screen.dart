import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({Key? key}) : super(key: key);

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  late String? currentUserId;
  final TextEditingController _voucherCodeController = TextEditingController();
  bool isVoucherApplied = false;
  DocumentSnapshot<Object?>? appliedVoucher;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> applyVoucher(String voucherCode) async {
    bool isVoucherApplied = await checkVoucherApplied(voucherCode);
    if (!isVoucherApplied) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('applied_voucher')
          .where('userId', isEqualTo: currentUserId)
          .get();
      if (querySnapshot.docs.isEmpty) {
        QuerySnapshot voucherSnapshot = await FirebaseFirestore.instance
            .collection('vouchers')
            .where('voucherCode', isEqualTo: voucherCode)
            .get();
        if (voucherSnapshot.docs.isNotEmpty) {
          // Nếu tìm thấy voucher với mã voucherCode
          DocumentSnapshot voucher = voucherSnapshot.docs.first;
          int discount = voucher['discount'];
          double totalAmount =
              100; // Giả sử tổng tiền hiện tại của đơn hàng là 100
          double discountedAmount =
              totalAmount - (totalAmount * discount / 100);

          FirebaseFirestore.instance.collection('applied_voucher').add({
            'voucherCode': voucherCode,
            'discount': discount,
            'userId': currentUserId,
          }).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Áp dụng mã giảm giá thành công'),
              ),
            );
            Navigator.pop(context, appliedVoucher);
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xảy ra lỗi khi áp dụng mã giảm giá.'),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy mã giảm giá này trong hệ thống.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã áp dụng mã giảm giá cho đơn hàng này.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá đã được áp dụng cho đơn hàng này.'),
        ),
      );
    }
  }

  Future<bool> checkVoucherApplied(String voucherCode) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('applied_voucher')
        .where('userId', isEqualTo: currentUserId)
        .where('voucherCode', isEqualTo: voucherCode)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_offer, color: Themes.gradientLightClr),
                    SizedBox(width: 10),
                    Text(
                      'Mã giảm giá',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: _voucherCodeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập mã giảm giá của bạn',
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String voucherCode = _voucherCodeController.text.trim();
                        await applyVoucher(voucherCode);
                      },
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Themes.gradientLightClr,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 10,
            color: Colors.grey[300],
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('vouchers').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              if (snapshot.data == null) {
                return const Text("No data available");
              }

              return Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot voucher = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/coupon.png', // Đường dẫn đến hình ảnh của bạn
                                            width:
                                                60, // Chiều rộng của hình ảnh
                                            height:
                                                60, // Chiều cao của hình ảnh
                                            fit: BoxFit
                                                .cover, // Phương pháp fill của hình ảnh
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                voucher['voucherCode'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Discount: ${voucher['discount']}%',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15)),
                                ),
                                height: 80,
                                child: TextButton(
                                  onPressed: () async {
                                    String voucherCode = voucher['voucherCode'];
                                    await applyVoucher(voucherCode);
                                  },
                                  child: Text(
                                    isVoucherApplied ? 'Đã áp dụng' : 'Áp dụng',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Themes.gradientLightClr,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
