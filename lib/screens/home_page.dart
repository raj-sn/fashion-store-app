import 'package:flutter/material.dart';
import 'product_listing_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'my_orders_page.dart';

// IMAGE URLs

// Banner
const String bannerImageUrl =
    'https://www.themanual.com/tachyon/sites/9/2019/11/man-wearing-leather-jacket.jpg?resize=800,532';

// Category images
const String clothingImageUrl =
    'https://burst.shopifycdn.com/photos/clothes-on-a-rack-in-a-clothing-store.jpg?width=1000&format=pjpg&exif=0&iptc=0';
const String shoesImageUrl =
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2hvZXN8ZW58MHx8MHx8fDA%3D';
const String bagsImageUrl =
    'https://cdn.pixabay.com/photo/2016/11/23/18/12/bag-1854148_1280.jpg';
const String babyDressImageUrl =
    'https://babiesfrock.in/cdn/shop/products/image_8dd9ef4d-4d7a-4479-8fe7-3118c7c9621e.jpg?v=1675062220&width=1445';
const String watchImageUrl =
    'https://i5.walmartimages.com/seo/POEDAGAR-Fashion-Date-Quartz-Men-Watches-Top-Brand-Luxury-Waterproof-Luminous-Man-Clock-Military-Leather-Sport-Mens-Wrist-Watch_20c71273-e2e2-4e56-a05c-83037540df9e.ae83db4f779f472bd102d60fa6170914.jpeg';
const String hoodieImageUrl =
    'https://static.vecteezy.com/system/resources/thumbnails/047/249/322/small/sweater-shirt-hoodie-isolated-png.png';

// Product images
const String productImage1 =
    'https://img.freepik.com/free-photo/dreaming-handsome-man-looking-away_171337-16509.jpg?semt=ais_hybrid&w=740&q=80';
const String productImage2 =
    'https://m.media-amazon.com/images/I/41i+OM70KjL._AC_SR70_.jpg';
const String productImage3 =
    'https://thepatchee.lk/cdn/shop/files/O1CN01XthXDX2LoW66N0TWH__2209967679739-0-cib.jpg?v=1752109300&width=800';

// HOME PAGE

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Search', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.camera_alt_outlined),
                ],
              ),

              const SizedBox(height: 20),

              // Banner
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2C94C),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Big Sale',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Up to 50%',
                          style: TextStyle(color: Colors.white),
                        ),
                        Spacer(),
                        Text(
                          'Happening\nNow',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        bannerImageUrl,
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionHeader('Categories'),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  _categoryNav(
                    context,
                    'Clothing',
                    'clothing',
                    '109',
                    clothingImageUrl,
                  ),
                  _categoryNav(context, 'Shoes', 'shoes', '530', shoesImageUrl),
                  _categoryNav(context, 'Bags', 'bags', '87', bagsImageUrl),
                  _categoryNav(
                    context,
                    'Baby Dress',
                    'baby_dress',
                    '218',
                    babyDressImageUrl,
                  ),
                  _categoryNav(
                    context,
                    'Watch',
                    'watches',
                    '218',
                    watchImageUrl,
                  ),
                  _categoryNav(
                    context,
                    'Hoodies',
                    'hoodies',
                    '218',
                    hoodieImageUrl,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _sectionHeader('New Items'),
              const SizedBox(height: 12),

              SizedBox(
                height: 230,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _productCard('Summer Dress', '3200', productImage1),
                    const SizedBox(width: 12),
                    _productCard('Casual Hoodie', '2800', productImage2),
                    const SizedBox(width: 12),
                    _productCard('Leather Bag', '4500', productImage3),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryNav(
    BuildContext context,
    String title,
    String category,
    String count,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingPage(category: category)),
        );
      },
      child: _CategoryCard(title: title, count: count, imageUrl: imageUrl),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Text('See All', style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 6),
        const CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFF5A73F5),
          child: Icon(Icons.arrow_forward, size: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _productCard(String name, String price, String imageUrl) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
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
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs $price',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: const Color(0xFF5A73F5),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == 0) return; 

        Widget page;
        switch (index) {
          case 1:
            page = const MyOrdersPage();
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

// CATEGORY CARD

class _CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  final String imageUrl;

  const _CategoryCard({
    required this.title,
    required this.count,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
