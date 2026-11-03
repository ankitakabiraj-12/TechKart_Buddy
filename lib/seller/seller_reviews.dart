import 'package:flutter/material.dart';
import 'product_service.dart';

class SellerReviewsScreen extends StatefulWidget {
  final bool isStandaloneScreen;
  const SellerReviewsScreen({super.key, this.isStandaloneScreen = true});

  @override
  State<SellerReviewsScreen> createState() => _SellerReviewsScreenState();
}

class _SellerReviewsScreenState extends State<SellerReviewsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Rating aggregate summary
  double _averageRating = 0.0;
  int _totalReviews = 0;
  int _unrepliedCount = 0;
  Map<String, int> _distribution = {
    '5_star': 0,
    '4_star': 0,
    '3_star': 0,
    '2_star': 0,
    '1_star': 0,
  };

  // Review list
  List<dynamic> _reviews = [];
  int _currentPage = 1;
  int _totalPages = 1;

  // Filters
  String _selectedFilter = 'all'; // 'all', 'unreplied', '5', '4', '3', '2', '1'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int? ratingParam;
      bool? hasReplyParam;

      if (_selectedFilter == 'unreplied') {
        hasReplyParam = false;
      } else if (int.tryParse(_selectedFilter) != null) {
        ratingParam = int.parse(_selectedFilter);
      }

      final res = await ProductService.getSellerReviews(
        page: page,
        limit: 15,
        rating: ratingParam,
        hasReply: hasReplyParam,
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );

      if (res.isSuccess && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final summary = data['summary'] as Map<String, dynamic>?;
        final pagination = data['pagination'] as Map<String, dynamic>?;
        final list = data['reviews'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _isLoading = false;
            _reviews = list;
            _currentPage = pagination?['page'] ?? 1;
            _totalPages = pagination?['total_pages'] ?? 1;

            if (summary != null) {
              _averageRating = (summary['average_rating'] as num?)?.toDouble() ?? 0.0;
              _totalReviews = summary['total_reviews'] ?? 0;
              _unrepliedCount = summary['unreplied_count'] ?? 0;
              final dist = summary['distribution'] as Map<String, dynamic>?;
              if (dist != null) {
                _distribution = {
                  '5_star': dist['5_star'] ?? 0,
                  '4_star': dist['4_star'] ?? 0,
                  '3_star': dist['3_star'] ?? 0,
                  '2_star': dist['2_star'] ?? 0,
                  '1_star': dist['1_star'] ?? 0,
                };
              }
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = res.message;
          });
        }
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

  void _onFilterChanged(String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
    });
    _loadReviews(page: 1);
  }

  void _openReplyBottomSheet(Map<String, dynamic> review) {
    final TextEditingController replyController = TextEditingController(
      text: review['seller_reply'] ?? '',
    );
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final existingReply = review['seller_reply'] != null && (review['seller_reply'] as String).isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existingReply ? 'Update Store Reply' : 'Reply as Store',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['product_title'] ?? 'Product',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildRatingStars(review['rating'] ?? 5, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '"${review['title'] ?? ''}"',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Response to Customer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: replyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Thank the customer or address their concern professionally...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final text = replyController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a response message')),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              try {
                                final replyRes = await ProductService.replyToReview(
                                  reviewId: review['id'],
                                  reply: text,
                                );

                                if (replyRes.isSuccess) {
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Store reply published successfully!'),
                                      backgroundColor: Color(0xFF16A34A),
                                    ),
                                  );
                                  if (mounted) {
                                    _loadReviews(page: _currentPage);
                                  }
                                } else {
                                  setModalState(() => isSubmitting = false);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text(replyRes.message)),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              existingReply ? 'Save Changes' : 'Post Reply',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.isStandaloneScreen
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: () => _loadReviews(page: 1),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReviews(page: 1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSummaryCard(),
              _buildFilterChips(),
              if (_isLoading && _reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null && _reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
                        const SizedBox(height: 10),
                        Text(_errorMessage!, style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _loadReviews(page: 1),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No reviews found for this filter',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Customer feedback on your products will appear here.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Reviews (${_reviews.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviews.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final review = _reviews[index] as Map<String, dynamic>;
                    return _buildReviewCard(review);
                  },
                ),
                if (_totalPages > 1) _buildPaginationControls(),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall rating column
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRatingStars(_averageRating.round(), size: 18),
                    const SizedBox(height: 6),
                    Text(
                      '$_totalReviews Verified Reviews',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    if (_unrepliedCount > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_unrepliedCount awaiting reply',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Star distribution bar column
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildDistributionRow(5, _distribution['5_star'] ?? 0),
                    _buildDistributionRow(4, _distribution['4_star'] ?? 0),
                    _buildDistributionRow(3, _distribution['3_star'] ?? 0),
                    _buildDistributionRow(2, _distribution['2_star'] ?? 0),
                    _buildDistributionRow(1, _distribution['1_star'] ?? 0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(int stars, int count) {
    final double pct = _totalReviews > 0 ? (count / _totalReviews) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text('$stars ★', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  stars >= 4 ? const Color(0xFF10B981) : (stars == 3 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All Reviews'},
      {'key': 'unreplied', 'label': 'Unreplied ($_unrepliedCount)'},
      {'key': '5', 'label': '5 ★'},
      {'key': '4', 'label': '4 ★'},
      {'key': '3', 'label': '3 ★'},
      {'key': '2', 'label': '2 ★'},
      {'key': '1', 'label': '1 ★'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (_) => _onFilterChanged(f['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 5;
    final customerName = review['customer_name'] ?? 'Verified Buyer';
    final isVerified = review['is_verified_purchase'] == true;
    final reviewDate = review['created_at'] != null
        ? _formatDate(review['created_at'].toString())
        : '';
    final standoutTags = review['standout_tags'] as List<dynamic>? ?? [];
    final sellerReply = review['seller_reply'] as String?;
    final repliedAt = review['replied_at'] != null
        ? _formatDate(review['replied_at'].toString())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product Title & Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['product_title'] ?? 'Product',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (review['variant_text'] != null && (review['variant_text'] as String).isNotEmpty)
                      Text(
                        'Variant: ${review['variant_text']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              _buildRatingStars(rating, size: 15),
            ],
          ),
          const SizedBox(height: 8),

          // Customer line + verified badge
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                customerName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 11, color: Color(0xFF16A34A)),
                      SizedBox(width: 2),
                      Text(
                        'Verified Purchase',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                reviewDate,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Review Title & Body
          if (review['title'] != null && (review['title'] as String).isNotEmpty) ...[
            Text(
              review['title'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            review['review_text'] ?? '',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),

          // Standout tags
          if (standoutTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: standoutTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // Seller reply block (if replied)
          if (sellerReply != null && sellerReply.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: Color(0xFF0284C7), width: 3.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront, size: 14, color: Color(0xFF0284C7)),
                          SizedBox(width: 4),
                          Text(
                            'Store Response',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                      if (repliedAt.isNotEmpty)
                        Text(
                          repliedAt,
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sellerReply,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer action: Reply button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _openReplyBottomSheet(review),
                icon: Icon(
                  sellerReply != null && sellerReply.isNotEmpty ? Icons.edit_note : Icons.reply,
                  size: 16,
                  color: const Color(0xFF0F172A),
                ),
                label: Text(
                  sellerReply != null && sellerReply.isNotEmpty ? 'Edit Response' : 'Reply as Store',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 ? () => _loadReviews(page: _currentPage - 1) : null,
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages ? () => _loadReviews(page: _currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: index < rating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
        );
      }),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthName = months[dt.month - 1];
      final day = dt.day.toString().padLeft(2, '0');
      return '$day $monthName ${dt.year}';
    } catch (_) {
      return isoString;
    }
  }
}
