import 'package:flutter/material.dart';

// --- MODERN FURNITURE PRODUCT CARD ---
// Elegant, minimalist design inspired by premium furniture brands
// Features: Soft shadows, rounded corners, clean typography
class ProductCard extends StatelessWidget {
  // Product data to display
  final String productName;
  final double price;
  final String imageUrl;
  final VoidCallback onTap;
  final bool isAvailable; // Availability status
  final bool isAdmin; // Whether the current user is admin

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.isAvailable = true,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Match card border radius
      // Hover effect for web/desktop
      hoverColor: Color(0xFFE8DCC4).withOpacity(0.1),
      child: Stack(
        children: [
          // --- MAIN CARD CONTAINER ---
          Card(
            // Card styling comes from theme, but we add custom elevation
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- PRODUCT IMAGE SECTION ---
                // Takes up majority of card space for visual impact
                Expanded(
                  flex: 4, // 4 parts out of 6 total
                  child: Stack(
                    children: [
                      // Product image with rounded top corners
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover, // Fill container while maintaining aspect ratio
                          width: double.infinity,
                          height: double.infinity,
                          // Loading indicator while image loads
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Color(0xFFF5F5F5), // Light gray placeholder
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: Color(0xFF6B4423), // Walnut brown
                                ),
                              ),
                            );
                          },
                          // Error fallback with elegant icon
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Color(0xFFF5F5F5),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chair_outlined,
                                      size: 48,
                                      color: Color(0xFFE8DCC4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image unavailable',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Overlay for unavailable items - semi-transparent black
                      if (!isAvailable)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Color(0xFF2C2C2C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --- PRODUCT INFO SECTION ---
                // Clean, minimal text layout with generous padding
                Expanded(
                  flex: 2, // 2 parts out of 6 total
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product name with elegant typography
                        Text(
                          productName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2C2C2C), // Charcoal black
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Price and admin status row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Price with elegant formatting
                            Flexible(
                              child: Text(
                                '₱${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF6B4423), // Walnut brown
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  decoration: !isAvailable ? TextDecoration.lineThrough : null,
                                  // Ensure fallbacks for glyphs not present in Poppins
                                  fontFamilyFallback: ['Roboto', 'Noto Sans'],
                                ),
                              ),
                            ),
                            // Admin visibility indicator
                            if (isAdmin && !isAvailable)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCE8B70).withOpacity(0.15), // Terracotta tint
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.visibility_off_outlined,
                                  size: 16,
                                  color: Color(0xFFCE8B70),
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
          
          // --- ADMIN BADGE: Availability status indicator ---
          // Only visible to admin users
          if (isAdmin)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Color(0xFF6B7C59) // Olive green
                      : Color(0xFFCE8B70), // Terracotta
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvailable ? 'Available' : 'Hidden',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
