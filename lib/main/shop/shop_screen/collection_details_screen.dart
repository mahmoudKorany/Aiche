import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/shop/Model/collection_model.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final CollectionModel collection;

  const CollectionDetailsScreen({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  State<CollectionDetailsScreen> createState() =>
      _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleDescription() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _shareCollection() {
    final String shareText =
        "Check out this collection: ${widget.collection.name}\nTotal price: ${widget.collection.total} EGP\nProducts: ${widget.collection.products?.map((p) => p.name).join(", ") ?? 'No products'}";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine grid columns based on screen width
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 900
            ? 3
            : 4;

    // Calculate aspect ratio based on screen width
    final childAspectRatio = screenWidth < 600 ? 0.9 : 0.8;

    // Filter products based on search query only (removed favorites filter)
    List<Products> filteredProducts = [];
    if (widget.collection.products != null) {
      filteredProducts = widget.collection.products!.where((product) {
        final nameMatch =
            product.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false;
        return nameMatch;
      }).toList();
    }

    return BlocConsumer<ShopCubit, ShopState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isLoading = state is PlaceOrderLoadingState;

        return Scaffold(
          body: Stack(children: [
            const BackGround(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap50(),
                // App bar with back button, collection name and share button
                _buildAppBar(context, screenWidth, screenHeight),

                // Collection image and details
                _buildCollectionHeader(context, screenWidth, screenHeight),

                // Products grid
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    child: widget.collection.products == null ||
                            widget.collection.products!.isEmpty
                        ? _buildEmptyState(context)
                        : filteredProducts.isEmpty
                            ? _buildNoResultsFound(screenWidth)
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.02,
                                  bottom: screenHeight * 0.04,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: screenWidth * 0.03,
                                  mainAxisSpacing: screenWidth * 0.03,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _buildProductCard(
                                      context, product, screenWidth);
                                },
                              ),
                  ),
                ),
                const Gap10(),
                _buildOrderButton(context, screenWidth, screenHeight)
              ],
            ),

            // Loading overlay
            if (isLoading)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ]),
          // Order button at the bottom
        );
      },
    );
  }

  Widget _buildAppBar(
      BuildContext context, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: Row(
        children: [
          const Pop(),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Text(
              widget.collection.name ?? 'Collection Details',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionHeader(
      BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection image with view more button
          Stack(
            children: [
              // Collection image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: widget.collection.image ??
                      'https://via.placeholder.com/150',
                  height: screenHeight * 0.2,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) => Container(
                    height: screenHeight * 0.2,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported,
                        size: screenWidth * 0.1),
                  ),
                ),
              ),

              // Gradient overlay for better text readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // View more button
              Positioned(
                bottom: 10,
                right: 10,
                child: InkWell(
                  onTap: () => _showCollectionImageFullScreen(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        const Text(
                          'View',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Collection details
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collection name with share button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.collection.name ?? 'Collection',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _shareCollection,
                      icon: Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: screenWidth < 600 ? 20 : 24,
                      ),
                      tooltip: 'Share collection',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                // Collection description with expand/collapse functionality
                if (widget.collection.description != null &&
                    widget.collection.description!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _toggleDescription,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Text(
                            widget.collection.description!,
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 14 : 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: _isExpanded ? null : 2,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Show more/less button
                      if (widget.collection.description!.length > 100)
                        GestureDetector(
                          onTap: _toggleDescription,
                          child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.01),
                            child: Row(
                              children: [
                                Text(
                                  _isExpanded ? 'Show less' : 'Show more',
                                  style: TextStyle(
                                    fontSize: screenWidth < 600 ? 12 : 14,
                                    color: Colors.blue[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.blue[300],
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                SizedBox(height: screenHeight * 0.01),

                // Price and product count row with animations
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Price section
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.greenAccent,
                                size: screenWidth < 600 ? 20 : 22,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Price',
                                  style: TextStyle(
                                    fontSize: screenWidth < 600 ? 12 : 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${widget.collection.total ?? '0'} EGP',
                                  style: TextStyle(
                                    fontSize: screenWidth < 600 ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Vertical divider
                      Container(
                        height: screenHeight * 0.05,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),

                      // Product count section
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.blue[300],
                                size: screenWidth < 600 ? 20 : 22,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Products',
                                  style: TextStyle(
                                    fontSize: screenWidth < 600 ? 12 : 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${widget.collection.products?.length ?? 0}',
                                  style: TextStyle(
                                    fontSize: screenWidth < 600 ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCollectionImageFullScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.collection.name ?? 'Collection Image',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareCollection,
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: widget.collection.image ??
                    'https://via.placeholder.com/150',
                fit: BoxFit.contain,
                errorWidget: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: screenWidth * 0.2,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Image could not be loaded',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Products product, double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showProductDetails(context, product),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Stack(
                children: [
                  // Product image
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.image ?? 'https://via.placeholder.com/150',
                        height: screenWidth < 600 ? 120 : screenWidth * 0.15,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: screenWidth < 600 ? 120 : screenWidth * 0.15,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: screenWidth < 600 ? 40 : 50),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay for better text readability
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
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product details
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
                          // Product name
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

                          SizedBox(height: screenHeight * 0.005),

                          // Product price
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Products product) {
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
                  child: Image.network(
                    product.image ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[700],
                      child: Icon(
                        Icons.image_not_supported,
                        size: screenWidth * 0.15,
                        color: Colors.white54,
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
                                    product.createdAt!,
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
                          Container(
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
                                          fontSize: screenWidth < 600 ? 14 : 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        product.link!,
                                        style: TextStyle(
                                          fontSize: screenWidth < 600 ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[300],
                                          decoration: TextDecoration.underline,
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

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: screenWidth * 0.2,
            color: Colors.white70,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'No Products Available',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Text(
              'There are currently no products in this collection.',
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

  Widget _buildNoResultsFound(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: screenWidth * 0.15,
            color: Colors.white70,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Text(
              'Try adjusting your search or filters to find what you\'re looking for.',
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

  Widget _buildOrderButton(
      BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: Colors.greenAccent,
                    size: screenWidth < 600 ? 22 : 24,
                  ),
                  Text(
                    '${widget.collection.total ?? "0"} EGP',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E86C1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () {
              // Show bottom sheet to collect phone number
              _showPhoneNumberBottomSheet(context, screenWidth, screenHeight);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Order Collection',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New method to show phone number bottom sheet
  void _showPhoneNumberBottomSheet(
      BuildContext context, double screenWidth, double screenHeight) {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
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
                SizedBox(height: screenHeight * 0.01),
                // Collection being ordered
                Text(
                  'Collection: ${widget.collection.name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth < 600 ? 16 : 18,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                // Price
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.greenAccent,
                      size: screenWidth < 600 ? 16 : 18,
                    ),
                    Text(
                      '${widget.collection.total ?? "0"} EGP',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: screenWidth < 600 ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
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
                SizedBox(height: screenHeight * 0.02),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E86C1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Place order using the collection ID and phone number
                        if (widget.collection.id != null) {
                          shopCubit.placeCollectionOrder(
                            collectionId: widget.collection.id ??0,
                            phone: phoneController.text,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order placed for ${widget.collection.name}'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Cannot place order. Invalid collection ID.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
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
