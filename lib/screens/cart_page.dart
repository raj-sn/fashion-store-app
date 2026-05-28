import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_page.dart';
import 'home_page.dart';
import 'my_orders_page.dart';
import 'profile_page.dart';

const String defaultProductImage =
    'https://via.placeholder.com/150x150.png?text=No+Image';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in again')));
    }

    final userEmail = user.email!;

    return Scaffold(
      backgroundColor: Colors.white,

      // Bottom nav OUTSIDE FutureBuilder
      bottomNavigationBar: _bottomNav(context),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc('items')
            .get(),
        builder: (context, productSnapshot) {
          if (!productSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productData =
              productSnapshot.data!.data() as Map<String, dynamic>;

          return SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cart')
                        .doc(userEmail)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('Cart is empty'));
                      }

                      final cartData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final List cartProducts = cartData['products'] ?? [];

                      if (cartProducts.isEmpty) {
                        return const Center(child: Text('Cart is empty'));
                      }

                      int total = 0;
                      for (var p in cartProducts) {
                        total +=
                            ((p['price'] as num?)?.toInt() ?? 0) *
                            ((p['qty'] as int?) ?? 1);
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${cartProducts.length} item(s)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: cartProducts.length,
                              itemBuilder: (context, index) {
                                final item = cartProducts[index];
                                return _cartItem(
                                  context,
                                  userEmail,
                                  item,
                                  productData,
                                );
                              },
                            ),
                          ),

                          _checkoutBar(context, cartProducts, total),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // CART ITEM
  Widget _cartItem(
    BuildContext context,
    String userEmail,
    Map<String, dynamic> item,
    Map<String, dynamic> productData,
  ) {
    final List categoryProducts = productData[item['category']] ?? [];

    final imageUrl = (item['index'] < categoryProducts.length)
        ? categoryProducts[item['index']]['image'] ?? defaultProductImage
        : defaultProductImage;

    final int qty = item['qty'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // IMAGE 
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  item['description'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 6),

                Text(
                  'Rs ${item['price']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // QUANTITY CONTROLS
                Row(
                  children: [
                    _qtyIcon(
                      context,
                      icon: Icons.remove,
                      onTap: qty > 1
                          ? () => _updateQty(userEmail, item, qty - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        qty.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _qtyIcon(
                      context,
                      icon: Icons.add,
                      onTap: () => _updateQty(userEmail, item, qty + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // DELETE 
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('cart')
                  .doc(userEmail)
                  .update({
                    'products': FieldValue.arrayRemove([item]),
                  });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateQty(
    String userEmail,
    Map<String, dynamic> item,
    int newQty,
  ) async {
    final updatedItem = Map<String, dynamic>.from(item)..['qty'] = newQty;

    await FirebaseFirestore.instance.collection('cart').doc(userEmail).update({
      'products': FieldValue.arrayRemove([item]),
    });

    await FirebaseFirestore.instance.collection('cart').doc(userEmail).update({
      'products': FieldValue.arrayUnion([updatedItem]),
    });
  }

  Widget _qtyIcon(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF5A73F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  // BOTTOM TOTAL BAR
  Widget _checkoutBar(BuildContext context, List products, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Rs $total',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A73F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PaymentPage(products: products, total: total),
                  ),
                );
              },
              child: const Text(
                'Checkout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5A73F5),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 2) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Widget page = switch (index) {
            0 => const HomePage(),
            1 => const MyOrdersPage(),
            3 => const ProfilePage(),
            _ => const CartPage(),
          };

          Navigator.of(
            context,
            rootNavigator: true,
          ).pushReplacement(MaterialPageRoute(builder: (_) => page));
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}
