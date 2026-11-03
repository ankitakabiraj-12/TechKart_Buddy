import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'seller_top_bar.dart';
import 'product_service.dart';

class AddProduct extends StatefulWidget {
  final String? editingSku;
  final int? productId;
  final String? initialTitle;
  final double? initialPrice;
  final double? initialMrp;
  final int? initialStock;
  final String? initialDescription;
  final int? initialCategoryId;
  final int? initialSubcategoryId;
  final Map<String, dynamic>? initialSpecifications;

  const AddProduct({
    super.key,
    this.editingSku,
    this.productId,
    this.initialTitle,
    this.initialPrice,
    this.initialMrp,
    this.initialStock,
    this.initialDescription,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.initialSpecifications,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _shortDescCtrl;
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _listingCtrl;
  final _stockCtrl = TextEditingController(text: '4');

  int _stockCount = 4;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  // Live Category & Specification State
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  String _selectedCategoryName = 'Wearables & Smartwatches';
  bool _isLoadingCategories = false;

  // Subcategory State
  List<Map<String, dynamic>> _subcategories = [];
  int? _selectedSubcategoryId;
  String _selectedSubcategoryName = 'Select Subcategory';
  bool _isLoadingSubcategories = false;

  bool _isLoadingSpecs = false;
  List<Map<String, dynamic>> _specSchema = [];
  final Map<String, dynamic> _specValues = {};

  final List<String> _galleryImages = [
    'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800&q=80',
    'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.initialTitle ?? 'Chronos Ultra 2 (49mm GPS Titanium V',
    );
    _shortDescCtrl = TextEditingController(
      text: widget.initialDescription ??
          'Aerospace-grade titanium case, 3000-nit LTPO display, multi-band dual GPS, 72-hour battery life in extreme...',
    );
    _mrpCtrl = TextEditingController(
      text: widget.initialMrp != null
          ? widget.initialMrp!.toInt().toString()
          : '49,900',
    );
    _listingCtrl = TextEditingController(
      text: widget.initialPrice != null
          ? widget.initialPrice!.toInt().toString()
          : '42,900',
    );
    if (widget.initialStock != null) {
      _stockCount = widget.initialStock!;
      _stockCtrl.text = _stockCount.toString();
    }

    _selectedCategoryId = widget.initialCategoryId ?? 2;
    _selectedSubcategoryId = widget.initialSubcategoryId;
    if (widget.initialSpecifications != null) {
      _specValues.addAll(widget.initialSpecifications!);
    }

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res = await ProductService.getCategories();
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);

      if (res.isSuccess && res.data != null) {
        final List<dynamic> raw = res.data is List ? res.data as List : [];
        setState(() {
          _categories = raw.map((c) => Map<String, dynamic>.from(c as Map)).toList();
          final found = _categories.firstWhere(
            (c) => c['id'] == _selectedCategoryId,
            orElse: () => _categories.isNotEmpty ? _categories.first : {'id': 2, 'name': 'Wearables & Smartwatches'},
          );
          _selectedCategoryId = found['id'] as int?;
          _selectedCategoryName = found['name'] as String? ?? 'Wearables & Smartwatches';
        });

        if (_selectedCategoryId != null) {
          _fetchCategorySpecifications(_selectedCategoryId!);
          _fetchSubcategories(_selectedCategoryId!);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchCategorySpecifications(int categoryId) async {
    setState(() => _isLoadingSpecs = true);
    try {
      final res = await ProductService.getCategorySpecifications(categoryId);
      if (!mounted) return;
      setState(() => _isLoadingSpecs = false);

      if (res.isSuccess && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final rawSchema = data['schema'] as List<dynamic>? ?? [];
        final defaults = data['defaults'] as Map<String, dynamic>? ?? {};

        setState(() {
          _specSchema = rawSchema.map((s) => Map<String, dynamic>.from(s as Map)).toList();
          for (final f in _specSchema) {
            final key = f['key'] as String;
            if (!_specValues.containsKey(key) || _specValues[key] == null || _specValues[key].toString().isEmpty) {
              _specValues[key] = defaults[key] ?? f['default'] ?? '';
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSpecs = false);
    }
  }

  Future<void> _fetchSubcategories(int categoryId) async {
    setState(() => _isLoadingSubcategories = true);
    try {
      final res = await ProductService.getSubcategories(categoryId);
      if (!mounted) return;
      setState(() => _isLoadingSubcategories = false);

      if (res.isSuccess && res.data != null) {
        List<dynamic> raw = [];
        if (res.data is Map && (res.data as Map)['subcategories'] is List) {
          raw = (res.data as Map)['subcategories'] as List;
        } else if (res.data is List) {
          raw = res.data as List;
        }

        setState(() {
          _subcategories = raw.map((c) => Map<String, dynamic>.from(c as Map)).toList();
          if (_selectedSubcategoryId != null) {
            final found = _subcategories.firstWhere(
              (s) => s['id'] == _selectedSubcategoryId,
              orElse: () => {},
            );
            if (found.isNotEmpty) {
              _selectedSubcategoryName = found['name'] as String? ?? 'Select Subcategory';
            } else {
              _selectedSubcategoryId = null;
              _selectedSubcategoryName = 'Select Subcategory';
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSubcategories = false);
    }
  }

  Future<void> _showSubcategorySelectionDialog() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a main category first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_subcategories.isEmpty) {
      await _fetchSubcategories(_selectedCategoryId!);
    }
    if (!mounted) return;

    if (_subcategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subcategories found for this category.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _subcategories.where((sub) {
              final name = (sub['name'] ?? '').toString().toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (context, scrollController) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Subcategory',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2559),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_subcategories.length} Subcategories',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search subcategories...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) {
                          setModalState(() => query = val);
                        },
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching subcategories found.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                              itemBuilder: (context, index) {
                                final sub = filtered[index];
                                final isSelected = sub['id'] == _selectedSubcategoryId;

                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    sub['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF28384C),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'In $_selectedCategoryName',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Color(0xFF1565C0), size: 18)
                                      : null,
                                  onTap: () => Navigator.pop(context, sub),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedSubcategoryId = selected['id'] as int;
        _selectedSubcategoryName = selected['name'] as String? ?? '';
      });
    }
  }

  Future<void> _showCategorySelectionDialog() async {
    if (_categories.isEmpty) {
      await _fetchCategories();
    }
    if (!mounted || _categories.isEmpty) return;

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = _categories.where((cat) {
              final name = (cat['name'] as String? ?? '').toLowerCase();
              return searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.75,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Product Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF072138),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF5A6B7C)),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCCDFF0)),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setModalState(() {
                              searchQuery = val.trim();
                            });
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search_rounded, size: 20, color: Color(0xFF5A6B7C)),
                            hintText: 'Search 45 categories...',
                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF7A8B9C)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF072138)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matching categories found.',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF5A6B7C)),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final cat = filtered[i];
                                  final isSelected = cat['id'] == _selectedCategoryId;
                                  final order = cat['display_order'] ?? (i + 1);
                                  return InkWell(
                                    onTap: () => Navigator.of(ctx).pop(cat),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFE8F2FD) : const Color(0xFFF0F5FD),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFCCDFF0),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 26,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFD6E4F0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$order',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected ? Colors.white : const Color(0xFF072138),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              cat['name'] as String? ?? '',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                color: isSelected ? const Color(0xFF072138) : const Color(0xFF28384C),
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 20,
                                              color: Color(0xFF1565C0),
                                            ),
                                        ],
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
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final newId = selected['id'] as int;
      setState(() {
        _selectedCategoryId = newId;
        _selectedCategoryName = selected['name'] as String? ?? '';
        _selectedSubcategoryId = null;
        _selectedSubcategoryName = 'Select Subcategory';
        _subcategories.clear();
        _specValues.clear();
      });
      _fetchCategorySpecifications(newId);
      _fetchSubcategories(newId);
    }
  }

  double _parsePrice(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  // Pre-curated realistic product photographs available in the gallery picker
  static const List<Map<String, String>> _sampleCatalogPhotos = [
    {
      'label': 'Chronos Titanium Front Cover',
      'url': 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800&q=80',
      'tag': '49mm LTPO Cover'
    },
    {
      'label': 'Titanium Side Crown Angle',
      'url': 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&q=80',
      'tag': 'Side Angle'
    },
    {
      'label': 'Ceramic Case Back & Sensors',
      'url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80',
      'tag': 'Sensors & Back'
    },
    {
      'label': 'Lifestyle On-Wrist Action',
      'url': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=800&q=80',
      'tag': 'On-Wrist'
    },
    {
      'label': 'Dual USB-C GaN Charger',
      'url': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&q=80',
      'tag': 'Power & GaN'
    },
    {
      'label': 'Studio ANC Wireless Headset',
      'url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
      'tag': 'Studio Audio'
    },
  ];

  Future<void> _showGalleryPickerDialog() async {
    final selectedPhoto = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Product Image to Upload',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF072138),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF5A6B7C)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose high-res angle photo to upload to live storage:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5A6B7C)),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _sampleCatalogPhotos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = _sampleCatalogPhotos[i];
                      return InkWell(
                        onTap: () => Navigator.of(ctx).pop(item),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCCDFF0)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  item['url']!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 44,
                                    height: 44,
                                    color: const Color(0xFFE4EDF7),
                                    child: const Icon(Icons.broken_image, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF072138),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['tag']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF5A6B7C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.cloud_upload_outlined, size: 18, color: Color(0xFF1E4B75)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedPhoto != null && mounted) {
      setState(() => _isUploadingImage = true);

      try {
        // Download selected image bytes and upload via multipart request to Core PHP API
        final getResp = await http.get(Uri.parse(selectedPhoto['url']!));
        if (getResp.statusCode == 200) {
          final bytes = getResp.bodyBytes;
          final fileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final uploadRes = await ProductService.uploadProductImages(
            productId: widget.productId,
            fileBytesList: [bytes],
            fileNames: [fileName],
            isPrimary: _galleryImages.isEmpty,
          );

          if (!mounted) return;
          setState(() => _isUploadingImage = false);

          if (uploadRes.isSuccess && uploadRes.data != null) {
            final data = uploadRes.data as Map<String, dynamic>;
            final uploadedList = data['uploaded'] as List<dynamic>? ?? [];
            if (uploadedList.isNotEmpty) {
              final uploadedUrl = uploadedList[0]['url'] as String? ?? selectedPhoto['url']!;
              setState(() {
                _galleryImages.add(uploadedUrl);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image uploaded and stored successfully.'),
                  backgroundColor: Color(0xFF072138),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
          }
        }

        // Fallback to direct selection if server network unavailable
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
            _galleryImages.add(selectedPhoto['url']!);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isUploadingImage = false);
          // Add URL directly
          setState(() => _galleryImages.add(selectedPhoto['url']!));
        }
      }
    }
  }

  Future<void> _handleSaveProduct({required String status}) async {
    final title = _titleCtrl.text.trim();
    final description = _shortDescCtrl.text.trim();
    final price = _parsePrice(_listingCtrl.text);
    final mrp = _parsePrice(_mrpCtrl.text);

    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product title (at least 3 characters).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid listing price.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (mrp > 0 && mrp < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MRP cannot be less than listing price.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final specs = Map<String, dynamic>.from(_specValues);

      final images = _galleryImages.isNotEmpty
          ? _galleryImages
          : [
              'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=800&q=80',
              'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800&q=80',
            ];

      dynamic res;
      if (widget.productId != null && widget.productId! > 0) {
        // Edit Mode: Update existing product via PUT /buddy/products/{id}
        res = await ProductService.updateProduct(
          widget.productId!,
          title: title,
          categoryId: _selectedCategoryId,
          subcategoryId: _selectedSubcategoryId,
          description: description,
          specifications: specs,
          price: price,
          mrp: mrp > 0 ? mrp : null,
          stockQuantity: _stockCount,
          status: status,
          images: images,
        );
      } else {
        // Create Mode: Add new product via POST /buddy/products
        res = await ProductService.addProduct(
          title: title,
          categoryId: _selectedCategoryId,
          subcategoryId: _selectedSubcategoryId,
          description: description,
          specifications: specs,
          price: price,
          mrp: mrp > 0 ? mrp : null,
          stockQuantity: _stockCount,
          status: status,
          images: images,
        );
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (res.isSuccess) {
        final message = widget.productId != null
            ? (status == 'draft' ? 'Product draft updated.' : 'Product updated successfully.')
            : (status == 'draft' ? 'Draft saved successfully.' : 'Product submitted for review.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF072138),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Failed to save product.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortDescCtrl.dispose();
    _mrpCtrl.dispose();
    _listingCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null || widget.editingSku != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFE),
      appBar: SellerTopBar(
        title: isEditing ? 'Edit Product' : 'Add New Product',
        subtitle: 'Inventory Management',
        showProfile: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── STEP 1 CARD & PROGRESS ──
              Container(
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4E6F8), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4C5D80),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Step 1 of 2: Basic Info & Catalog',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF072138),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EDF7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFC7DDF2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune_rounded, size: 11, color: Color(0xFF5A6B7C)),
                              SizedBox(width: 4),
                              Text(
                                'Edit Mode',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5A6B7C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.featured_play_list_outlined, size: 13, color: Color(0xFF5A6B7C)),
                            const SizedBox(width: 5),
                            RichText(
                              text: TextSpan(
                                text: 'Editing SKU:  ',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C)),
                                children: [
                                  TextSpan(
                                    text: widget.editingSku ?? 'TK-WAT-ULT2-TI',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF072138),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '85% Complete',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4C5D80),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 5,
                        width: double.infinity,
                        color: const Color(0xFFD4E4F5),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.85,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C5D80),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PRODUCT GALLERY ──
              _buildSectionCard(
                icon: Icons.photo_library_outlined,
                title: 'Product Gallery',
                trailing: '${_galleryImages.length} of 4 uploaded',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main image preview
                        GestureDetector(
                          onTap: _isUploadingImage ? null : _showGalleryPickerDialog,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF3B5070), width: 2),
                            ),
                            child: Stack(
                              children: [
                                if (_galleryImages.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _galleryImages.first,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.watch_outlined, size: 42, color: Color(0xFF8DA5C0)),
                                      ),
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Icon(Icons.watch_outlined, size: 42, color: Color(0xFF8DA5C0)),
                                  ),
                                if (_isUploadingImage)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF03142E),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'COVER',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Angle thumbnails & Upload button
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _showGalleryPickerDialog,
                                    child: _buildAngleThumbnail('Side Angle', Icons.rotate_right_outlined, filled: _galleryImages.length > 1),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _showGalleryPickerDialog,
                                    child: _buildAngleThumbnail('Case Back', Icons.flip_outlined, filled: _galleryImages.length > 2),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _showGalleryPickerDialog,
                                    child: _buildAngleThumbnail('+ Add Photo', Icons.add_photo_alternate_outlined, filled: false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap "+ Add Photo" to select & upload angle photos (max 5MB).',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF5A6B7C), height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── PRODUCT IDENTITY ──
              _buildSectionCard(
                icon: Icons.verified_outlined,
                title: 'Product Identity',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildLabelRow('Product Listing Title', '44 / 120'),
                    const SizedBox(height: 6),
                    _buildTextField(controller: _titleCtrl),
                    const SizedBox(height: 14),
                    const Text(
                      'Primary Category',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C)),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _showCategorySelectionDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCCDFF0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.folder_outlined, size: 15, color: Color(0xFF4C5D70)),
                                const SizedBox(width: 8),
                                Text(
                                  _isLoadingCategories ? 'Loading categories...' : _selectedCategoryName,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF28384C), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Change',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.unfold_more_rounded, size: 12, color: Color(0xFF1565C0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Subcategory',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C)),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _showSubcategorySelectionDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCCDFF0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.category_outlined, size: 15, color: Color(0xFF4C5D70)),
                                const SizedBox(width: 8),
                                Text(
                                  _isLoadingSubcategories
                                      ? 'Loading subcategories...'
                                      : _selectedSubcategoryName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _selectedSubcategoryId != null
                                        ? const Color(0xFF28384C)
                                        : const Color(0xFF718096),
                                    fontWeight: _selectedSubcategoryId != null
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Select',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.unfold_more_rounded, size: 12, color: Color(0xFF1565C0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Brand Verification',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCCDFF0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.corporate_fare_outlined, size: 15, color: Color(0xFF4C5D70)),
                              SizedBox(width: 6),
                              Text(
                                'Chronos',
                                style: TextStyle(fontSize: 12.5, color: Color(0xFF28384C), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_rounded, size: 11, color: Color(0xFF2E7D32)),
                                SizedBox(width: 4),
                                Text(
                                  'Verified Brand',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Short Description & Highlights',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _shortDescCtrl,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF28384C), height: 1.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF0F5FD),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCCDFF0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCCDFF0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3B6688), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── KEY SPECIFICATIONS ──
              _buildSectionCard(
                icon: Icons.tune_rounded,
                title: 'Key Specifications',
                trailing: '${_specSchema.length} Fields (${_selectedCategoryName.split(" ").first})',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (_isLoadingSpecs)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 10),
                              Text('Loading category specification schema...', style: TextStyle(fontSize: 12, color: Color(0xFF5A6B7C))),
                            ],
                          ),
                        ),
                      )
                    else if (_specSchema.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCCDFF0)),
                        ),
                        child: const Text(
                          'No specification fields defined for this category.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF5A6B7C)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _specSchema.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final field = _specSchema[index];
                          final key = field['key'] as String;
                          final label = field['label'] as String? ?? key;
                          final type = field['type'] as String? ?? 'text';
                          final options = (field['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                          final currentValue = (_specValues[key] ?? field['default'] ?? '').toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A6B7C), fontWeight: FontWeight.w600),
                                  ),
                                  if (field['required'] == true)
                                    const Text('Required', style: TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () => _editSpecField(key, label, type, options, currentValue),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5FD),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCCDFF0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          currentValue.isNotEmpty ? currentValue : 'Not Specified',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: currentValue.isNotEmpty ? const Color(0xFF0A2038) : const Color(0xFF8DA5C0),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF5A6B7C)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── INVENTORY & PRICING ──
              _buildSectionCard(
                icon: Icons.attach_money_rounded,
                title: 'Inventory & Pricing',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MRP (₹)',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF5A6B7C))),
                              const SizedBox(height: 6),
                              _buildTextField(controller: _mrpCtrl, isNumber: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Listing Price (₹)',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF5A6B7C))),
                              const SizedBox(height: 6),
                              _buildTextField(controller: _listingCtrl, isNumber: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Commission Row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('TechKart Commission (6%)',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF4C5D70))),
                              Text('- ₹ 2,574',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD32F2F))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, size: 13, color: Color(0xFF4C7DA8)),
                                  SizedBox(width: 4),
                                  Text('Est. Payout per Unit',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF4C5D70))),
                                ],
                              ),
                              const Text('₹ 40,326',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF072138))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Available Stock',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Allocated to central warehouse',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                    ),
                    const SizedBox(height: 8),
                    // Stepper
                    Row(
                      children: [
                        _buildStepperBtn(
                          icon: Icons.remove,
                          onTap: () {
                            if (_stockCount > 0) setState(() => _stockCount--);
                          },
                        ),
                        Container(
                          width: 52,
                          alignment: Alignment.center,
                          child: Text(
                            '$_stockCount',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF072138),
                            ),
                          ),
                        ),
                        _buildStepperBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _stockCount++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── TAX & WARRANTY ──
              _buildSectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Tax & Warranty',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.account_balance_outlined,
                      label: 'Applicable VAT & Taxes',
                      value: 'Included in price (5% Standard Tech VAT registered)',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.shield_outlined,
                      label: 'Warranty Period',
                      value: '1 Year Official Brand Warranty (India Official Hubs)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── BOTTOM ACTIONS ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Save Draft
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F0FB),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextButton.icon(
                          onPressed: _isSubmitting ? null : () => _handleSaveProduct(status: 'draft'),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF072138)),
                                )
                              : const Icon(Icons.bookmark_border_rounded, size: 16, color: Color(0xFF072138)),
                          label: const Text(
                            'Save Draft',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF072138),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Submit for Review
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF03142E),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextButton(
                          onPressed: _isSubmitting ? null : () => _handleSaveProduct(status: 'published'),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isEditing ? 'Save Changes' : 'Submit for Review',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Compliance note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.access_time_outlined, size: 13, color: Color(0xFF5A6B7C)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Automated catalog compliance review finishes within 4 hours.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF5A6B7C)),
                        textAlign: TextAlign.center,
                      ),
                    ),
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

  // ── HELPERS ──

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0ECF7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F0FB),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 16, color: const Color(0xFF1E4B75)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF072138),
                    ),
                  ),
                ],
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF4C5D70)),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildAngleThumbnail(String label, IconData icon, {required bool filled}) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFFE3F0FB) : const Color(0xFFF3F7FC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: filled ? const Color(0xFF3B6688) : const Color(0xFFCCDFF0),
            ),
          ),
          child: Icon(icon, size: 22,
              color: filled ? const Color(0xFF285688) : const Color(0xFFB0C8DE)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: filled ? const Color(0xFF374E65) : const Color(0xFF9AB0C6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelRow(String label, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF28384C))),
        Text(trailing,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5A6B7C))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0A2038), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F5FD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCDFF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCDFF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B6688), width: 1.5),
        ),
      ),
    );
  }



  Widget _buildStepperBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCDFF0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF28384C)),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3FD),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF285688)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0A2038))),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF4C5D70))),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editSpecField(
    String key,
    String label,
    String type,
    List<String> options,
    String currentValue,
  ) async {
    if (type == 'select' && options.isNotEmpty) {
      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $label',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF072138),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF5A6B7C)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final opt = options[i];
                        final isSel = opt == currentValue;
                        return InkWell(
                          onTap: () => Navigator.of(ctx).pop(opt),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFE8F2FD) : const Color(0xFFF0F5FD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? const Color(0xFF1565C0) : const Color(0xFFCCDFF0),
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? const Color(0xFF072138) : const Color(0xFF28384C),
                                  ),
                                ),
                                if (isSel)
                                  const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF1565C0)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (selected != null && mounted) {
        setState(() {
          _specValues[key] = selected;
        });
      }
    } else {
      // Freeform Text Input Modal
      final textCtrl = TextEditingController(text: currentValue);
      final savedText = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit $label',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF072138)),
          ),
          content: TextField(
            controller: textCtrl,
            autofocus: true,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0A2038)),
            decoration: InputDecoration(
              hintText: 'Enter specification value...',
              filled: true,
              fillColor: const Color(0xFFF0F5FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCDFF0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCDFF0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF5A6B7C))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03142E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(ctx).pop(textCtrl.text.trim()),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (savedText != null && mounted) {
        setState(() {
          _specValues[key] = savedText;
        });
      }
    }
  }
}
