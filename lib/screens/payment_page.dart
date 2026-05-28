import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_fashion/screens/my_orders_page.dart';

const String defaultProductImage =
    'https://via.placeholder.com/150x150.png?text=No+Image';

class PaymentPage extends StatefulWidget {
  final List products;
  final int total;

  const PaymentPage({super.key, required this.products, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in again')));
    }

    final userEmail = user.email!;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc('items')
          .get(),
      builder: (context, productSnapshot) {
        if (!productSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final productData =
            productSnapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _inputCard(
                          title: 'Shipping Address',
                          controller: addressController,
                          hint: 'Enter your delivery address',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _inputCard(
                          title: 'Contact Information',
                          controller: contactController,
                          hint: 'Phone number or email',
                          maxLines: 1,
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFEFF2FF),
                              child: Text(
                                widget.products.length.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5A73F5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ...widget.products.map((p) {
                          final List categoryProducts =
                              productData[p['category']] ?? [];

                          final String imageUrl =
                              (p['index'] < categoryProducts.length)
                              ? categoryProducts[p['index']]['image'] ??
                                    defaultProductImage
                              : defaultProductImage;

                          return _itemRow(
                            name: p['name'],
                            price: (p['price'] as num).toInt(),
                            qty: p['qty'] ?? 1,
                            imageUrl: imageUrl,
                          );
                        }),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),

                // Bottom total + Pay button 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('Total ', style: TextStyle(fontSize: 16)),
                      Text(
                        'Rs ${widget.total}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        height: 48,
                        child: GestureDetector(
                          onTap: loading
                              ? null
                              : () async {
                                  if (addressController.text.isEmpty ||
                                      contactController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill address and contact',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => loading = true);

                                  // Save order
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .add({
                                        'userEmail': userEmail,
                                        'address': addressController.text
                                            .trim(),
                                        'contact': contactController.text
                                            .trim(),
                                        'products': widget.products,
                                        'total': widget.total,
                                        'status': 'paid',
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });

                                  // REMOVE ONLY PAID ITEMS FROM CART
                                  final cartRef = FirebaseFirestore.instance
                                      .collection('cart')
                                      .doc(userEmail);

                                  for (var product in widget.products) {
                                    await cartRef.update({
                                      'products': FieldValue.arrayRemove([
                                        product,
                                      ]),
                                    });
                                  }

                                  setState(() => loading = false);

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyOrdersPage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Pay',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputCard({
    required String title,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow({
    required String name,
    required int price,
    required int qty,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.network(
                defaultProductImage,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text('x$qty'),
          const SizedBox(width: 12),
          Text(
            'Rs ${price * qty}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
