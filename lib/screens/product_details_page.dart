import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_page.dart';

const String defaultProductImage =
    'https://via.placeholder.com/500x700.png?text=No+Image';

class ProductDetailsPage extends StatelessWidget {
  final String category;
  final int index;

  const ProductDetailsPage({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc('items')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List products = data[category] ?? [];

        if (products.isEmpty || index >= products.length) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }

        final product = products[index];

        final relatedItems = products
            .where((item) => item != product)
            .take(4)
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,

          // BODY
          body: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: Image.network(
                      product['image'] ?? defaultProductImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 1 ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 1
                          ? const Color(0xFF5A73F5)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            'Rs ${product['price']}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(Icons.share),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        product['description'],
                        style: const TextStyle(color: Colors.grey, height: 1.4),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Related Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: relatedItems.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _relatedItemCard(relatedItems[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM BAR
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.favorite_border),
                  ),
                  const SizedBox(width: 12),

                  // ADD TO CART
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final userEmail =
                            FirebaseAuth.instance.currentUser!.email!;

                        await FirebaseFirestore.instance
                            .collection('cart')
                            .doc(userEmail)
                            .set({
                              'products': FieldValue.arrayUnion([
                                {
                                  'category': category,
                                  'index': index,
                                  'name': product['name'],
                                  'price': product['price'],
                                  'description': product['description'],
                                  'qty': 1,
                                },
                              ]),
                            }, SetOptions(merge: true));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Added to cart')),
                        );

                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Add to cart',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // BUY NOW
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final buyNowProduct = {
                          'category': category,
                          'index': index,
                          'name': product['name'],
                          'price': product['price'],
                          'description': product['description'],
                          'qty': 1,
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              products: [buyNowProduct],
                              total: product['price'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A73F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Buy now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _relatedItemCard(Map<String, dynamic> item) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                item['image'] ?? defaultProductImage,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item['price']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
