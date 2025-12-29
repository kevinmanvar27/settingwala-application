import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';

class UserGalleryScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const UserGalleryScreen({super.key, required this.person});

  @override
  State<UserGalleryScreen> createState() => _UserGalleryScreenState();
}

class _UserGalleryScreenState extends State<UserGalleryScreen> {
  List<String> _galleryImages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGalleryFromPerson();
  }

  // Helper to convert relative URLs to full URLs
  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url; // Already absolute
    }
    // Convert relative to absolute using base URL
    return 'https://settingwala.com$url';
  }

  // Load gallery from person data passed from previous screen
  // Note: API doesn't have endpoint for other user's gallery, so we use data from person map
  void _loadGalleryFromPerson() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<String> images = [];
      
      // Get gallery from person map
      final gallery = widget.person['gallery'];
      if (gallery != null && gallery is List) {
        for (var img in gallery) {
          if (img is String && img.isNotEmpty) {
            images.add(_getFullImageUrl(img));
          } else if (img is Map) {
            final url = img['url'] ?? img['image_url'] ?? img['image'] ?? img['path'];
            if (url != null && url.toString().isNotEmpty) {
              images.add(_getFullImageUrl(url.toString()));
            }
          }
        }
      }
      
      // If no gallery images, try to use the main profile image
      if (images.isEmpty) {
        final mainImage = widget.person['image'];
        if (mainImage != null && mainImage.toString().isNotEmpty) {
          images.add(_getFullImageUrl(mainImage.toString()));
        }
      }
      
      setState(() {
        _galleryImages = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading gallery: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final gridPadding = isDesktop ? 20.0 : isTablet ? 16.0 : 12.0;
    final gridSpacing = isDesktop ? 16.0 : isTablet ? 12.0 : 8.0;
    final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final borderRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 64.0 : 48.0;
    final emptyTitleSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;

    return BaseScreen(
      title: "${person['name']}'s Gallery",
      showBackButton: true,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: emptyIconSize,
                        color: Colors.red,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: emptySubtitleSize,
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      ElevatedButton(
                        onPressed: _loadGalleryFromPerson,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _galleryImages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: emptyIconSize,
                            color: primaryColor.withOpacity(0.5),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No photos yet',
                            style: TextStyle(
                              fontSize: emptyTitleSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            '${person['name']} hasn\'t uploaded any photos',
                            style: TextStyle(
                              fontSize: emptySubtitleSize,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(gridPadding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: 1,
                      ),
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showFullImage(context, index),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(borderRadius),
                              child: Image.network(
                                _galleryImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colors.card,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: colors.textTertiary,
                                        size: isTablet ? 40 : 32,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: colors.card,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  // Full screen image viewer with swipe
  void _showFullImage(BuildContext context, int initialIndex) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          images: _galleryImages,
          initialIndex: initialIndex,
          personName: widget.person['name'],
          colors: colors,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}

// Full screen gallery viewer with PageView
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String personName;
  final AppColorSet colors;
  final Color primaryColor;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
    required this.personName,
    required this.colors,
    required this.primaryColor,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: widget.primaryColor,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
