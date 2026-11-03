import 'package:flutter/material.dart';
import 'admin_top_bar.dart';
import 'admin_profile.dart';
import 'admin_category_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CategoryManagementScreen({super.key, this.onNavigateTab});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  // Selected category index from list
  int _selectedCategoryIndex = 0;

  // Search & Filters
  final TextEditingController _searchController = TextEditingController();
  // Filter index: 0 -> All, 1 -> Roots, 2 -> Subcategories, 3 -> Active
  int _selectedFilter = 0;

  // Pagination & Loading States
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _categories = [];
  Map<String, dynamic>? _metrics;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String statusParam = 'all';
      String? parentIdParam;

      if (_selectedFilter == 1) {
        parentIdParam = 'root';
      } else if (_selectedFilter == 2) {
        // subcategories
        parentIdParam = null;
      } else if (_selectedFilter == 3) {
        statusParam = 'active';
      }

      final query = _searchController.text.trim();
      final data = await AdminCategoryService.getCategories(
        search: query.isNotEmpty ? query : null,
        status: statusParam,
        parentId: parentIdParam,
        page: page,
        limit: 15,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data != null) {
            _categories = data['categories'] as List<dynamic>? ?? [];
            if (_selectedFilter == 2) {
              // Subcategories filter
              _categories = _categories.where((c) => c['parent_id'] != null).toList();
            }
            _metrics = data['metrics'] as Map<String, dynamic>?;
            final pagination = data['pagination'] as Map<String, dynamic>?;
            _currentPage = pagination?['page'] ?? 1;
            _totalPages = pagination?['total_pages'] ?? 1;
            _totalCount = pagination?['total'] ?? _categories.length;

            if (_selectedCategoryIndex >= _categories.length) {
              _selectedCategoryIndex = 0;
            }
          } else {
            _errorMessage = 'Failed to load categories from server';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilter = index;
    });
    _loadCategories(page: 1);
  }

  Future<void> _showCreateOrEditCategoryDialog({Map<String, dynamic>? existingCategory, int? defaultParentId}) async {
    final isEditing = existingCategory != null;
    final nameCtrl = TextEditingController(text: existingCategory?['name']?.toString() ?? '');
    final slugCtrl = TextEditingController(text: existingCategory?['slug']?.toString() ?? '');
    int? selectedParentId = isEditing
        ? (existingCategory['parent_id'] as int?)
        : defaultParentId;
    bool isActive = isEditing ? ((existingCategory['is_active'] ?? 1) == 1) : true;

    // Filter available parent candidates (exclude self)
    final availableParents = _categories
        .where((c) => !isEditing || (c['id'] != existingCategory['id'] && c['parent_id'] == null))
        .toList();

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                isEditing ? 'Edit Category Node' : 'New Category Node',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF03253B),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category Name *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B8095))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Smart Wearables',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF4F8FE),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD6EEFD))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Slug (Optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B8095))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: slugCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. smart-wearables',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF4F8FE),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD6EEFD))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Parent Node', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B8095))),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int?>(
                      initialValue: selectedParentId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF4F8FE),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD6EEFD))),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('None (Root Category)', style: TextStyle(fontSize: 12)),
                        ),
                        ...availableParents.map((p) => DropdownMenuItem<int?>(
                              value: p['id'] as int?,
                              child: Text('${p['name']} (ID: ${p['id']})', style: const TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedParentId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Active / Published', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF03253B))),
                        Switch(
                          value: isActive,
                          activeThumbColor: const Color(0xFF107C41),
                          onChanged: (v) {
                            setDialogState(() {
                              isActive = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B8095))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(dialogCtx).showSnackBar(
                        const SnackBar(content: Text('Category name cannot be empty')),
                      );
                      return;
                    }

                    Navigator.pop(dialogCtx);

                    if (isEditing) {
                      final catId = existingCategory['id'] as int;
                      final res = await AdminCategoryService.updateCategory(
                        id: catId,
                        name: name,
                        slug: slugCtrl.text.trim().isNotEmpty ? slugCtrl.text.trim() : null,
                        parentId: selectedParentId,
                        isActive: isActive,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(res.message.isNotEmpty ? res.message : 'Category updated successfully'),
                            backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
                          ),
                        );
                        _loadCategories(page: _currentPage);
                      }
                    } else {
                      final res = await AdminCategoryService.createCategory(
                        name: name,
                        slug: slugCtrl.text.trim().isNotEmpty ? slugCtrl.text.trim() : null,
                        parentId: selectedParentId,
                        isActive: isActive,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(res.message.isNotEmpty ? res.message : 'Category created successfully'),
                            backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
                          ),
                        );
                        _loadCategories(page: 1);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03253B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Create Node'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCategory(Map<String, dynamic> category) async {
    final catId = category['id'] as int;
    final catName = category['name']?.toString() ?? 'Category';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category Node', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.w800, color: Color(0xFFB52E1D))),
        content: Text('Are you sure you want to delete "$catName"? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B8095))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB52E1D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await AdminCategoryService.deleteCategory(catId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message.isNotEmpty ? res.message : 'Category deleted successfully'),
            backgroundColor: res.isSuccess ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
          ),
        );
        _loadCategories(page: 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Scrollable Body
            Expanded(
              child: _isLoading && _categories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF03253B),
                      ),
                    )
                  : _errorMessage != null && _categories.isEmpty
                      ? _buildErrorView()
                      : RefreshIndicator(
                          color: const Color(0xFF03253B),
                          onRefresh: () => _loadCategories(page: _currentPage),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Category & Taxonomy Engine + Version / Roots
                                _buildHeaderMetrics(),

                                const SizedBox(height: 12),

                                // Search category input
                                _buildSearchBar(),

                                const SizedBox(height: 10),

                                // Filter Pills (All, Roots, Subcategories, Active)
                                _buildFilterPills(),

                                const SizedBox(height: 10),

                                // + New Root & Import JSON Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 38,
                                        child: ElevatedButton(
                                          onPressed: () => _showCreateOrEditCategoryDialog(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF03253B),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(19),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                'New Root',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 38,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Taxonomy JSON Schema export ready.')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD6EEFD),
                                            foregroundColor: const Color(0xFF285C8A),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(19),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.file_upload_outlined, size: 15),
                                              SizedBox(width: 4),
                                              Text(
                                                'Export Schema',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                if (_categories.isEmpty)
                                  _buildEmptyView()
                                else ...[
                                  // Section: TAXONOMY HIERARCHY
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TAXONOMY HIERARCHY',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6B8095),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        'Showing ${_categories.length} of $_totalCount nodes',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B8095),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Live Taxonomy Tree Container
                                  _buildLiveTaxonomyTree(),

                                  const SizedBox(height: 18),

                                  // Node Detail Editor for selected category
                                  _buildLiveNodeDetailCard(),

                                  const SizedBox(height: 18),

                                  // Dynamic Attribute Specifications Schema
                                  _buildAttributeSchemaSection(),

                                  const SizedBox(height: 16),

                                  // Pagination Controls
                                  _buildPaginationControls(),
                                ],

                                const SizedBox(height: 16),

                                // Attribute Schema Lock Active Alert Container
                                _buildLockNoticeCard(),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AdminTopBar(
      title: 'Category Taxonomy',
      subtitle: 'Catalog Hierarchy & Category Rules',
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(2);
        }
      },
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
        );
      },
    );
  }

  Widget _buildHeaderMetrics() {
    final version = _metrics?['version']?.toString() ?? 'v4.2 Published';
    final totalRoots = _metrics?['total_roots']?.toString() ?? '1';
    final totalCategories = _metrics?['total_categories']?.toString() ?? '${_categories.length}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_tree_outlined,
              size: 20,
              color: Color(0xFF285C8A),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category & Taxonomy\nEngine',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                Text(
                  '$totalCategories Categories in MariaDB',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEFD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF285C8A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$version • $totalRoots Roots',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF285C8A),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF4C6A88)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadCategories(page: 1),
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF03253B),
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search category name or slug...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A7591),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _loadCategories(page: 1);
              },
              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF4C6A88)),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF285C8A)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _loadCategories(page: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All Nodes', 'Root Nodes', 'Subcategories', 'Active'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _onFilterSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF03253B) : const Color(0xFFE4F0FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF28547C),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLiveTaxonomyTree() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2ECF5)),
        itemBuilder: (context, index) {
          final c = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          final isRoot = c['parent_id'] == null;
          final productsCount = c['products_count'] ?? 0;
          final specFieldsCount = c['spec_fields_count'] ?? 0;
          final isActive = (c['is_active'] ?? 1) == 1;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              color: isSelected ? const Color(0xFFF0F7FE) : Colors.transparent,
              padding: EdgeInsets.only(
                left: isRoot ? 12.0 : 28.0,
                right: 12.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isRoot ? Icons.folder_open_rounded : Icons.subdirectory_arrow_right_rounded,
                        size: 18,
                        color: isSelected ? const Color(0xFF03253B) : const Color(0xFF4C6A88),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['name']?.toString() ?? '',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                  color: const Color(0xFF03253B),
                                ),
                              ),
                              if (!isActive) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE8E5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'INACTIVE',
                                    style: TextStyle(fontSize: 8, color: Color(0xFFB52E1D), fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '$productsCount SKUs • $specFieldsCount spec fields • /${c['slug']}',
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B8095)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isRoot ? const Color(0xFFD6EEFD) : const Color(0xFFF4F8FE),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD6EEFD)),
                        ),
                        child: Text(
                          isRoot ? 'ROOT' : 'SUB',
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF285C8A)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showCreateOrEditCategoryDialog(existingCategory: c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveNodeDetailCard() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    final c = _categories[_selectedCategoryIndex];
    final catId = c['id'] as int;
    final name = c['name']?.toString() ?? 'Category';
    final slug = c['slug']?.toString() ?? '';
    final isRoot = c['parent_id'] == null;
    final parentName = c['parent_name']?.toString() ?? 'Root Level';
    final productsCount = c['products_count'] ?? 0;
    final isActive = (c['is_active'] ?? 1) == 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF03253B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'CAT-ID-$catId',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF285C8A),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFDE8E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'PUBLISHED' : 'DISABLED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? const Color(0xFF107C41) : const Color(0xFFB52E1D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isRoot ? 'Root Taxonomy Node › $name' : '$parentName › $name',
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF6B8095),
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Field Config Grid
          Row(
            children: [
              Expanded(
                child: _buildConfigField(
                  label: 'CANONICAL SLUG',
                  value: '/$slug',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfigField(
                  label: 'PARENT CATEGORY',
                  value: parentName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildConfigField(
                  label: 'ACTIVE LISTINGS',
                  value: '$productsCount Live SKUs',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConfigField(
                  label: 'STATUS',
                  value: isActive ? 'Active Catalog' : 'Hidden',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons: Edit Node, + Subcategory, Delete Node
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCreateOrEditCategoryDialog(existingCategory: c),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Edit Node',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (isRoot) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCreateOrEditCategoryDialog(defaultParentId: catId),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD6EEFD)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '+ Subcategory',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF285C8A)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: () => _confirmDeleteCategory(c),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Delete',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFB52E1D)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B8095),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: const Color(0xFF285C8A)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF03253B),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeSchemaSection() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    final c = _categories[_selectedCategoryIndex];
    final specCount = c['spec_fields_count'] ?? 0;
    final catName = c['name'] ?? 'Category';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Attribute Schema',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF03253B),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EEFD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$specCount Rules Bound',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF285C8A),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'For $catName',
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B8095)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2ECF5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category specifications & schema templates are dynamically bound to MariaDB products for "$catName".',
                style: const TextStyle(fontSize: 11, color: Color(0xFF556F88), height: 1.3),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dynamic specs include Brand, Warranty, Material, Port Config, Power, Battery Life, and Technical Specs.',
                style: TextStyle(fontSize: 10, color: Color(0xFF285C8A), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentPage > 1
                ? () => _loadCategories(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 16),
            label: const Text('Previous', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF03253B),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _currentPage < _totalPages
                ? () => _loadCategories(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 16),
            label: const Text('Next', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCFD8DC),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF285C8A)),
              SizedBox(width: 6),
              Text(
                'TAXONOMY GOVERNANCE & INTEGRITY',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF03253B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Category deletions are strictly guarded in MariaDB. Categories with active product listings or subcategories cannot be deleted without first reassigning dependent catalog entities.',
            style: TextStyle(
              fontSize: 9.5,
              height: 1.35,
              color: Color(0xFF2B445B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2ECF5), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.category_outlined, size: 48, color: Color(0xFF90A4AE)),
          const SizedBox(height: 12),
          const Text(
            'No Categories Found',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF03253B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No category nodes match your search query or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              _onFilterSelected(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03253B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Clear Filters & Search', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFB52E1D)),
            const SizedBox(height: 12),
            const Text(
              'Failed to Load Categories',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF03253B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF556F88)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadCategories(page: _currentPage),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03253B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
