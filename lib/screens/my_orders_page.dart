import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

const String defaultProductImage =
    'https://via.placeholder.com/150x150.png?text=No+Image';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in again')),
      );
    }

    final userEmail = user.email!;

    return FutureBuilder<DocumentSnapshot>(
      // Fetch product catalog 
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

          // Bottom navigation
          bottomNavigationBar: _bottomNav(context),

          // AppBar 
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('My Orders'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),

          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userEmail', isEqualTo: userEmail)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final order =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  return _orderCard(
                    total: order['total'],
                    products: order['products'] ?? [],
                    productData: productData,
                    createdAt: order['createdAt'],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ORDER CARD WITH DATE
  Widget _orderCard({
    required int total,
    required List products,
    required Map<String, dynamic> productData,
    required Timestamp? createdAt,
  }) {
    final String orderDate = createdAt == null
        ? 'Date not available'
        : DateFormat('dd MMM yyyy, hh:mm a')
            .format(createdAt.toDate());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Total: Rs $total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ordered on: $orderDate',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          ...products.map((p) {
            final List categoryProducts =
                productData[p['category']] ?? [];

            final String imageUrl =
                (p['index'] < categoryProducts.length)
                    ? categoryProducts[p['index']]['image'] ??
                        defaultProductImage
                    : defaultProductImage;

            return _orderItem(
              name: p['name'],
              qty: p['qty'] ?? 1,
              imageUrl: imageUrl,
            );
          }),
        ],
      ),
    );
  }

  // PRODUCT ROW
  Widget _orderItem({
    required String name,
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
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('x$qty'),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION WITH PAGE SWITCHING
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, 
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF5A73F5),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 1) return; 

        Widget page;
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 2:
            page = const CartPage();
            break;
          case 3:
            page = const ProfilePage();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
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