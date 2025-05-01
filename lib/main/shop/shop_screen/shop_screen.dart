import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/home/home_component/drawer_icon.dart';
import 'package:aiche/main/shop/Model/collection_model.dart';
import 'package:aiche/main/shop/Model/product_model.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_state.dart';
import 'package:aiche/main/shop/shop_screen/collection_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/shared/components/components.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopState>(
      listener: (context, state) {},
      builder: (context, state) {
        final shopCubit = ShopCubit.get(context);
        return Scaffold(
          body: Stack(
            children: [
              const BackGround(),
              SafeArea(
                child: _buildContent(context, shopCubit),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ShopCubit shopCubit) {
    final isProductsLoading = shopCubit.state is GetAllProductsLoadingState;
    final isCollectionsLoading =
        shopCubit.state is GetAllCollectionsLoadingState;

    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine grid columns based on screen width
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 900
            ? 3
            : 4;

    // Responsive padding
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width

    // Show loading when fetching data
    if (isProductsLoading || isCollectionsLoading) {
      return loading();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DrawerIcon(),
              SizedBox(width: screenWidth * 0.02), // 2% of screen width
              Text(
                'Shop',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),

          // Collections section
          Text(
            'Collections',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 22 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          shopCubit.allCollections.isEmpty
              ? _buildEmptyState("No Collections Available",
                  "There are currently no collections to display.")
              : _buildCollectionsSection(shopCubit.allCollections, screenWidth),

          SizedBox(height: screenHeight * 0.03),

          // Products section
          Text(
            'All Products',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 22 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          shopCubit.allProducts.isEmpty
              ? _buildEmptyState("No Products Available",
                  "There are currently no products to display.")
              : _buildProductsGrid(
                  shopCubit.allProducts, crossAxisCount, screenWidth),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String title, String message) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.04,
        horizontal: screenWidth * 0.04,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: screenWidth < 600 ? 64 : 80,
            color: Colors.white70,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth < 600 ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth < 600 ? 14 : 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsSection(
      List<CollectionModel> collections, double screenWidth) {
    // Determine collection item width based on screen size
    final itemWidth = screenWidth < 600 ? 160.0 : screenWidth * 0.25;
    final itemHeight = screenWidth < 600 ? 180.0 : 200.0;

    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the collection details screen
              navigateTo(context: context, widget: CollectionDetailsScreen(
                collection: collection,
              ),);
            },
            child: Container(
              width: itemWidth,
              margin: EdgeInsets.only(right: screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: CachedNetworkImage(
                         imageUrl:  collection.image ?? 'https://via.placeholder.com/150',
                          height: itemHeight * 0.65, // 65% of the item height
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              Container(
                            height: itemHeight * 0.65,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                size: screenWidth < 600 ? 40 : 50),
                          ),
                        ),
                      ),
                      // Price badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Colors.greenAccent,
                                size: 14,
                              ),
                              Text(
                                '${collection.total ?? '0'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Collection name and product count
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name ?? 'Collection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${collection.products?.length ?? 0} Products',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: screenWidth < 600 ? 12 : 14,
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
      ),
    );
  }

  Widget _buildProductsGrid(
      List<ProductModel> products, int crossAxisCount, double screenWidth) {
    // Calculate aspect ratio based on screen width
    final childAspectRatio = screenWidth < 600 ? 0.7 : 0.8;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image with gradient overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                     imageUrl:  product.image ?? 'https://via.placeholder.com/150',
                      height: screenWidth < 600 ? 130 : screenWidth * 0.16,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Container(
                        height: screenWidth < 600 ? 130 : screenWidth * 0.16,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported,
                            size: screenWidth < 600 ? 40 : 50),
                      ),
                    ),
                  ),
                  // Subtle gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? 'Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: screenWidth < 600 ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.greenAccent,
                                size: screenWidth < 600 ? 16 : 18,
                              ),
                              Text(
                                '${product.price ?? '0'} EGP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth < 600 ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E86C1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth < 600 ? 8 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            _showPhoneInputBottomSheet(context, product);
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: Text(
                            'Order',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth < 600 ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show bottom sheet for phone input
  void _showPhoneInputBottomSheet(BuildContext context, ProductModel product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final shopCubit = ShopCubit.get(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: const Color(0xFF111347),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Complete Your Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth < 600 ? 20 : 24,
                  ),
                ),
                SizedBox(height: 8),
                // Product being ordered
                Text(
                  'Product: ${product.name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth < 600 ? 16 : 18,
                  ),
                ),
                SizedBox(height: 4),
                // Price
                Text(
                  'Price: ${product.price ?? "0"} EGP',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: screenWidth < 600 ? 14 : 16,
                  ),
                ),
                SizedBox(height: 20),
                // Phone Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    hintText: 'Enter your phone number',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length < 11) {
                      return 'Phone number must be at least 11 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E86C1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth < 600 ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Place order using the product ID and phone number
                        shopCubit.placeProductOrder(
                          productId: product.id ?? 0,
                          phone: phoneController.text,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order placed for ${product.name}'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 600 ? 16 : 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
