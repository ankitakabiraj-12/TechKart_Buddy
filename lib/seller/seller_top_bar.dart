import 'package:flutter/material.dart';

/// Standard Top Bar for screens in the seller directory.
///
/// Rules:
/// - When [isHome] is 	rue (Seller Dashboard only):
///   Displays TechKart Buddy logo and app name with store info/actions.
/// - When [isHome] is alse (all other non-splash screens):
///   Displays actual screen [title], optional [subtitle], a functional back button,
///   and optional trailing actions.
class SellerTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isHome;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showNotification;
  final bool showProfile;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const SellerTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isHome = false,
    this.onBack,
    this.actions,
    this.showNotification = false,
    this.showProfile = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop() || onBack != null;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Home branding OR [Back Button + Title]
            Expanded(
              child: Row(
                children: [
                  if (isHome) ...[
                    // TechKart Buddy Logo + Name ONLY on Seller Dashboard
                    Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'asset/techkart_buddy_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF03253B),
                            size: 22,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF03253B),
                                letterSpacing: -0.2,
                                height: 1.15,
                              ),
                              children: [
                                TextSpan(text: 'TechKart '),
                                TextSpan(
                                  text: 'Buddy',
                                  style: TextStyle(
                                    color: Color(0xFF285C8A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF556980),
                                fontWeight: FontWeight.w500,
                                height: 1.15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // Non-Home screens: Functional Back Button + Actual Screen Title
                    if (canGoBack)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onBack ?? () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFD3E4F6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: Color(0xFF03253B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                              letterSpacing: -0.2,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF556980),
                                fontWeight: FontWeight.w500,
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right: Optional actions or notification/profile icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...?actions,
                if (showNotification) ...[
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onNotificationTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5EFF9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 19,
                              color: Color(0xFF28384C),
                            ),
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  notificationCount > 99 ? '99+' : '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (showProfile) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B6774),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
