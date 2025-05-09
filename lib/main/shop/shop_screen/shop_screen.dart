import 'dart:io';

import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/home/home_component/drawer_icon.dart';
import 'package:aiche/main/shop/Model/collection_model.dart';
import 'package:aiche/main/shop/Model/product_model.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_state.dart';
import 'package:aiche/main/shop/shop_screen/collection_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/shared/components/components.dart';
import '../../blogs/blog_details/blog_details_screen.dart';

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

  void _showProductDetails(BuildContext context, ProductModel product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: screenHeight * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.015),
                width: screenWidth * 0.1,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Product image
            Hero(
              tag: 'product_image_${product.id}',
              child: Container(
                height: screenHeight * 0.3,
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl:
                        product.image ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) => Container(
                      color: Colors.grey[700],
                      child: Icon(
                        Icons.image_not_supported,
                        size: screenWidth * 0.15,
                        color: Colors.white54,
                      ),
                    ),
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        height: screenHeight * 0.3,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Product details
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name ?? 'Product',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Price section
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.greenAccent,
                            size: screenWidth < 600 ? 24 : 28,
                          ),
                          Text(
                            '${product.price ?? "0"} EGP',
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Created date
                    if (product.createdAt != null)
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                              size: screenWidth < 600 ? 20 : 24,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Added on',
                                    style: TextStyle(
                                      fontSize: screenWidth < 600 ? 14 : 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    formatDate(product.createdAt!),
                                    style: TextStyle(
                                      fontSize: screenWidth < 600 ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Link section if available
                    if (product.link != null && product.link!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          GestureDetector(
                            onTap: () {
                              // Open the link in a web view or browser
                              launchUrl(Uri.parse(product.link ?? ''));
                            },
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: Colors.white70,
                                    size: screenWidth < 600 ? 20 : 24,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Product Link',
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth < 600 ? 14 : 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          product.link ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth < 600 ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[300],
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              navigateTo(
                context: context,
                widget: CollectionDetailsScreen(
                  collection: collection,
                ),
              );
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
                          imageUrl: collection.image ??
                              'https://via.placeholder.com/150',
                          height: itemHeight * 0.65,
                          // 65% of the item height
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              Container(
                            height: itemHeight * 0.65,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                size: screenWidth < 600 ? 40 : 50),
                          ),
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image placeholder
                                Container(
                                  height: itemHeight * 0.65,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                // Content placeholders
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Title placeholder
                                        Container(
                                          height: 12,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Subtitle placeholder
                                        Container(
                                          height: 10,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Price badge placeholder
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            height: 16,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                collection.total ?? '0',
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
        return GestureDetector(
          onTap: () {
            _showProductDetails(context, product);
          },
          child: Container(
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
                        imageUrl:
                            product.image ?? 'https://via.placeholder.com/150',
                        height: screenWidth < 600 ? 130 : screenWidth * 0.16,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) => Container(
                          height: screenWidth < 600 ? 130 : screenWidth * 0.16,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: screenWidth < 600 ? 40 : 50),
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image placeholder
                              Container(
                                height: screenWidth < 600
                                    ? 130
                                    : screenWidth * 0.16,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                              ),
                              // Content placeholders
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.025),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title placeholder
                                          Container(
                                            height: 14,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Price placeholder
                                          Row(
                                            children: [
                                              Container(
                                                height: 16,
                                                width: 16,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                height: 14,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Button placeholder
                                      Container(
                                        height: screenWidth < 600 ? 36 : 44,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                const Gap10(),
                // Product being ordered
                Text(
                  'Product: ${product.name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth < 600 ? 16 : 18,
                  ),
                ),
                const Gap5(),
                // Price
                Text(
                  'Price: ${product.price ?? "0"} EGP',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: screenWidth < 600 ? 14 : 16,
                  ),
                ),
                const Gap20(),
                // Phone Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    hintText: 'Enter your phone number',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon:
                        Icon(Icons.phone, color: Colors.white.withOpacity(0.7)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
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
                const Gap20(),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: BlocConsumer<ShopCubit, ShopState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return ConditionalBuilder(
                        condition: state is! PlaceOrderLoadingState,
                        fallback: (context) => Platform.isIOS
                            ? const Center(
                                child: CupertinoActivityIndicator(
                                  radius: 20,
                                  color: Colors.white,
                                ),
                              )
                            : const Center(
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.ballRotateChase,
                                    colors: [
                                      Colors.white,
                                    ],
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                        builder: (context) => ElevatedButton(
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
                                  content: Text(
                                    'waiting to order place',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth < 600 ? 14 : 16,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
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
                      );
                    },
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
