import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // cartItems සඳහා
import 'checkout_screen.dart';
import 'login_screen.dart'; // ඔබේ Login screen එක ඇති ෆයිල් එක

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData})
    : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;

  @override
  Widget build(BuildContext context) {
    var product = widget.productData;

    String productId = product['id'] ?? product['name'] ?? 'unknown_product';
    String name = product['name'] ?? 'Product Name';
    double price = (product['price'] ?? 0.0).toDouble();
    String image = product['image'] ?? '';
    String description =
        product['description'] ?? 'No description available for this product.';
    String seller =
        product['seller'] ?? product['shopName'] ?? 'Official Store';
    double rating = (product['rating'] ?? 4.5).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(name, style: const TextStyle(fontSize: 18))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: colorScheme.surface,
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    )
                  : Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
            ),

            // Product Main Info
            Container(
              color: colorScheme.surface,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '$rating / 5.0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.store, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        'Sold by: ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        seller,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Quantity Selector
            Container(
              color: colorScheme.surface,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Description Section
            Container(
              color: colorScheme.surface,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Reviews & Ratings Section
            Container(
              color: colorScheme.surface,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ratings & Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // Add Review Form
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate this product:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _userRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _userRating = (index + 1).toDouble();
                                  });
                                },
                              );
                            }),
                          ),
                          TextField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                              hintText: 'Write your review here...',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: colorScheme.surface,
                              isDense: true,
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              onPressed: () async {
                                if (_reviewController.text.trim().isEmpty)
                                  return;

                                User? user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please log in to submit a review!',
                                      ),
                                      backgroundColor: Colors.red[700],
                                    ),
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(productId)
                                      .collection('reviews')
                                      .add({
                                        'userName':
                                            user.displayName ??
                                            user.email?.split('@')[0] ??
                                            'User',
                                        'userId': user.uid,
                                        'rating': _userRating,
                                        'comment': _reviewController.text
                                            .trim(),
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                      });

                                  _reviewController.clear();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Review submitted successfully!',
                                      ),
                                      backgroundColor: Colors.green[700],
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to submit review: $e',
                                      ),
                                      backgroundColor: Colors.red[700],
                                    ),
                                  );
                                }
                              },
                              child: Text('Submit Review'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Display Reviews Stream
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .collection('reviews')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      var reviews = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var rev =
                              reviews[index].data() as Map<String, dynamic>;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Text(
                                (rev['userName'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  rev['userName'] ?? 'User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: List.generate(
                                    (rev['rating'] ?? 5).toInt(),
                                    (i) => Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              rev['comment'] ?? '',
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      // Bottom Bar with Add to Cart & Buy Now
      bottomSheet: Container(
        padding: EdgeInsets.all(12),
        color: colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colorScheme.primary),
                ),
                onPressed: () {
                  setState(() {
                    var existing = cartItems.indexWhere(
                      (element) => element['name'] == name,
                    );
                    if (existing >= 0) {
                      cartItems[existing]['quantity'] += quantity;
                    } else {
                      cartItems.add({
                        'name': name,
                        'price': price,
                        'image': image,
                        'quantity': quantity,
                      });
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to Cart successfully!'),
                      backgroundColor: Colors.green[700],
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Buy Now ඔබන විට Login වී ඇද්දැයි පරීක්ෂා කිරීම
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please log in to place an order!'),
                        backgroundColor: Colors.red[700],
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                    return;
                  }

                  double total = price * quantity;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(subtotal: total),
                    ),
                  );
                },
                child: Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
