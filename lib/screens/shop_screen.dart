import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart'; 
import 'login_screen.dart';
import 'product_detail_screen.dart'; 

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  bool isDarkMode = false; // Default theme is light mode

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    Color backgroundColor = isDarkMode ? Color(0xFF0F172A) : Color(0xFFF8FAFC);
    Color appBarColor = isDarkMode ? Color(0xFF1E293B) : Colors.white;
    Color cardColor = isDarkMode ? Color(0xFF1E293B).withOpacity(0.7) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Color(0xFF1E293B);
    Color subTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    Color searchBgColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: isDarkMode ? 0 : 1,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: searchBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: textColor, fontSize: 15),
            cursorColor: Colors.amber[700],
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: subTextColor, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: subTextColor, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),
        actions: [
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: subTextColor, size: 20),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  searchQuery = '';
                });
              },
            ),
            
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.grey[800],
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            tooltip: 'Toggle Theme',
          ),

          currentUser == null
              ? TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()))
                        .then((_) => setState(() {}));
                  },
                  icon: Icon(Icons.login, size: 18),
                  label: Text('Login'),
                )
              : IconButton(
                  icon: Icon(Icons.logout, color: subTextColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: appBarColor,
                        title: Text('Logout Confirmation', style: TextStyle(color: textColor)),
                        content: Text(
                            'Are you sure you want to log out from your account?', style: TextStyle(color: subTextColor)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await FirebaseAuth.instance.signOut();
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Logged out successfully!')),
                              );
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 55,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, categorySnapshot) {
                List<String> categories = ['All'];
                
                if (categorySnapshot.hasData) {
                  for (var doc in categorySnapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    if (data.containsKey('name')) {
                      categories.add(data['name'].toString());
                    }
                  }
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var category = categories[index];
                    bool isSelected = selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.amber[700],
                        backgroundColor: isDarkMode ? Color(0xFF1E293B) : Colors.white,
                        labelStyle: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : (isDarkMode ? Colors.grey[300] : Colors.black87),
                            fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected 
                                ? Colors.amber.shade700 
                                : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                          ),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.amber));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No products found in Firebase!', style: TextStyle(color: subTextColor)));
                }

                var products = snapshot.data!.docs;
                var filteredProducts = products.where((product) {
                  var data = product.data() as Map<String, dynamic>;
                  var productName = (data['name'] ?? '').toString().toLowerCase();
                  var productCategory = data.containsKey('category')
                      ? (data['category'] ?? '').toString().toLowerCase()
                      : '';

                  bool matchesCategory = (selectedCategory == 'All') || 
                      (productCategory == selectedCategory.toLowerCase());
                  bool matchesSearch = productName.contains(searchQuery);

                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                      child: Text('No items found!',
                          style: TextStyle(color: subTextColor, fontSize: 16)));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(12.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72, 
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filteredProducts[index];
                    var productData = product.data() as Map<String, dynamic>;
                    var productName = productData['name'] ?? 'No Name';
                    var productPrice = productData['price'] ?? 0.0;
                    
                    // මිල නිවැරදිව double ආකාරයට ලබා ගැනීම
                    double priceDouble = 0.0;
                    if (productPrice is int) {
                      priceDouble = productPrice.toDouble();
                    } else if (productPrice is double) {
                      priceDouble = productPrice;
                    } else if (productPrice is String) {
                      priceDouble = double.tryParse(productPrice) ?? 0.0;
                    }

                    var productImage = productData.containsKey('image')
                        ? productData['image'] ?? ''
                        : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productData: productData,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white, // ඉමේජ් එක වටේට සුදු පාට පසුබිමක්
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: productImage.isNotEmpty
                                      ? Image.network(
                                          productImage,
                                          fit: BoxFit.contain,
                                          errorBuilder: (c, e, s) => Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Icon(
                                          Icons.shopping_basket,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productName,
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4),
                                  Text('Rs. ${priceDouble.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: Colors.amber[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 30,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber[700],
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          )),
                                      onPressed: () {
                                        setState(() {
                                          var existingIndex = cartItems.indexWhere(
                                              (item) =>
                                                  item['name'] == productName);
                                          if (existingIndex >= 0) {
                                            cartItems[existingIndex]['quantity'] +=
                                                1;
                                          } else {
                                            cartItems.add({
                                              'name': productName,
                                              'price': priceDouble,
                                              'image': productImage,
                                              'quantity': 1
                                            });
                                          }
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '$productName added to Cart!'),
                                              backgroundColor: Colors.green[700],
                                              duration: Duration(
                                                  milliseconds: 1000)),
                                        );
                                      },
                                      child: Text('Add to Cart',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}