import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/gallery_service.dart';
import '../model/getgalerymodel.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Gallery> _galleryImages = [];
  
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingGallery = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() {
      _isLoadingGallery = true;
    });

    try {
      final result = await GalleryService.getGallery();
      
      if (result != null && result.success == true && result.data?.gallery != null) {
        setState(() {
          _galleryImages = result.data!.gallery!;
        });
      }
    } catch (e) {
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading gallery: $e', style: const TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGallery = false;
        });
      }
    }
  }

  Future<bool> _uploadImage(File imageFile) async {
    try {
      final result = await GalleryService.uploadImage(imageFile);
      
      if (result != null && result.success == true) {
        return true;
      }
      return false;
    } catch (e) {
      
      return false;
    }
  }

  Future<void> _pickImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });
        
        int successCount = 0;
        int failCount = 0;
        
        for (final file in pickedFiles) {
          final imageFile = File(file.path);
          final success = await _uploadImage(imageFile);
          
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        }
        
        await _loadGallery();
        
        if (mounted) {

          if (successCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$successCount image(s) uploaded successfully${failCount > 0 ? ', $failCount failed' : ''}',
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: failCount > 0 ? AppColors.warning : AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          } else if (failCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload $failCount image(s)', style: const TextStyle(color: AppColors.white)),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e', style: const TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });
        
        final imageFile = File(pickedFile.path);
        final success = await _uploadImage(imageFile);
        
        if (success) {
          await _loadGallery();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image uploaded successfully!', style: TextStyle(color: AppColors.white)),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to upload image', style: TextStyle(color: AppColors.white)),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking picture: $e', style: const TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _removeImage(int index) async {
    final gallery = _galleryImages[index];
    final imageId = gallery.id;
    
    if (imageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot delete: Invalid image ID', style: TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final colors = context.colors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Image',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this image?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await GalleryService.deleteImage(imageId);
      
      if (result != null && result.success == true) {
        setState(() {
          _galleryImages.removeAt(index);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Image deleted successfully', style: const TextStyle(color: AppColors.white)),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete image', style: TextStyle(color: AppColors.white)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        }
      }
    } catch (e) {
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting image: $e', style: const TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageOptions() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 30 : 25.0),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Add Photos to Gallery',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.photo_camera,
                      title: 'Take Photo',
                      onTap: () {
                        Navigator.pop(context);
                        _takePicture();
                      },
                      colors: colors,
                      primaryColor: primaryColor,
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImages();
                      },
                      colors: colors,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 24 : 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AppColorSet colors,
    required Color primaryColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: isSmallScreen ? 28 : isTablet ? 40 : 32,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 12 : isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return BaseScreen(
      title: 'My Gallery',
      showBackButton: true,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadGallery,
            color: primaryColor,
            child: _isLoadingGallery
                ? _buildLoadingState(primaryColor)
                : _galleryImages.isEmpty
                    ? _buildEmptyGallery(colors, primaryColor)
                    : _buildGalleryGrid(colors, primaryColor),
          ),
          if (_isLoading || _isUploading)
            Container(
              color: AppColors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_isLoading || _isUploading) ? null : _showImageOptions,
        backgroundColor: (_isLoading || _isUploading) ? primaryColor.withOpacity(0.5) : primaryColor,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildEmptyGallery(AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isSmallScreen ? 100 : isTablet ? 160 : 120,
                  height: isSmallScreen ? 100 : isTablet ? 160 : 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    size: isSmallScreen ? 48 : isTablet ? 80 : 60,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),
                Text(
                  'Your Gallery is Empty',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Tap the + button to add photos to your gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid(AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final crossAxisCount = isDesktop ? 5 : isTablet ? 4 : isSmallScreen ? 2 : 3;
    final spacing = isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0;
    
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Photos (${_galleryImages.length})',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                return _buildImageTile(index, colors, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(int index, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    
    final borderRadius = isSmallScreen ? 12.0 : isTablet ? 20.0 : 15.0;
    final closeIconSize = isSmallScreen ? 14.0 : isTablet ? 20.0 : 16.0;
    final closeButtonPadding = isSmallScreen ? 3.0 : isTablet ? 6.0 : 4.0;
    
    final gallery = _galleryImages[index];
    final imageUrl = gallery.url ?? '';
    
    return GestureDetector(
      onTap: () => _showImageFullScreen(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? CachedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: Container(
                        color: colors.card,
                        child: Icon(
                          Icons.broken_image,
                          color: colors.textSecondary,
                          size: isSmallScreen ? 24 : 32,
                        ),
                      ),
                    )
                  : Container(
                      color: colors.card,
                      child: Icon(
                        Icons.image,
                        color: colors.textSecondary,
                        size: isSmallScreen ? 24 : 32,
                      ),
                    ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: EdgeInsets.all(closeButtonPadding),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.54),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: closeIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageFullScreen(int index) {
    final gallery = _galleryImages[index];
    final imageUrl = gallery.url ?? '';
    
    if (imageUrl.isEmpty) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: AppColors.black,
            iconTheme: const IconThemeData(color: AppColors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Navigator.pop(context);
                  _removeImage(index);
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: CachedImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                ),
                errorWidget: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
