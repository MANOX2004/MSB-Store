import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart'; // ඔබගේ ProductDetailScreen එක ඇති ෆයිල් එක මෙතැනට import කරන්න

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading orders: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var orderDocs = snapshot.data!.docs;

          orderDocs.sort((a, b) {
            var aTime =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            var bTime =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              var orderData = orderDocs[index].data() as Map<String, dynamic>;

              String status = orderData['status'] ?? 'Pending';
              String paymentMethod =
                  orderData['paymentMethod'] ?? 'Cash on Delivery';
              List items = orderData['items'] ?? [];

              // Total Amount එක නිවැරදිව ලබා ගැනීම හෝ ගණනය කර ගැනීම
              double total = 0.0;
              if (orderData.containsKey('total') &&
                  orderData['total'] != null) {
                total = (orderData['total'] ?? 0.0).toDouble();
              } else if (orderData.containsKey('totalAmount') &&
                  orderData['totalAmount'] != null) {
                total = (orderData['totalAmount'] ?? 0.0).toDouble();
              } else if (orderData.containsKey('subtotal') &&
                  orderData['subtotal'] != null) {
                total = (orderData['subtotal'] ?? 0.0).toDouble();
              } else {
                for (var item in items) {
                  double itemPrice = (item['price'] ?? 0.0).toDouble();
                  int itemQty = (item['quantity'] ?? 1).toInt();
                  total += (itemPrice * itemQty);
                }
              }

              var timestamp = orderData['timestamp'] as Timestamp?;
              String dateStr = '';
              if (timestamp != null) {
                DateTime date = timestamp.toDate();
                dateStr =
                    '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}';
              }

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID & Status Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${orderDocs[index].id.substring(0, 6).toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Pending'
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: status == 'Pending'
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: $dateStr',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        'Payment: $paymentMethod',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      Divider(height: 16, thickness: 1),

                      // Ordered Items List with Images & ProductDetailScreen Navigation
                      Text(
                        'Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, itemIndex) {
                          var item = items[itemIndex] as Map<String, dynamic>;
                          String productName = item['name'] ?? 'Product Name';
                          double price = (item['price'] ?? 0.0).toDouble();
                          int quantity = item['quantity'] ?? 1;
                          String imageUrl =
                              item['image'] ?? item['imageUrl'] ?? '';

                          return InkWell(
                            onTap: () {
                              // ප්‍රඩක්ට් එක ක්ලික් කළ විට ProductDetailScreen වෙත ඩේටා යැවීම[cite: 1]
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productData: {
                                      'id': item['id'] ?? productName,
                                      'name': productName,
                                      'price': price,
                                      'image': imageUrl,
                                      'description':
                                          item['description'] ??
                                          'No description available for this product.',
                                      'sellerName':
                                          item['sellerName'] ??
                                          item['seller'] ??
                                          'Official Store',
                                      'sellerId': item['sellerId'] ?? '',
                                      'rating': item['rating'] ?? 4.5,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Row(
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.image_not_supported,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 12),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Qty: $quantity',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Item Price
                                  Text(
                                    'Rs. ${(price * quantity).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Divider(height: 16, thickness: 1),
                      // Total Amount Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Rs. ${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
