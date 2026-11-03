import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isHome;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showNotifications;
  final bool showProfile;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const AdminTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isHome = false,
    this.onBack,
    this.actions,
    this.showNotifications = true,
    this.showProfile = true,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop() || onBack != null;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left section: Home branding OR [Back Button + Screen Title]
            Expanded(
              child: Row(
                children: [
                  if (isHome) ...[
                    // Logo + App Name ONLY on Home
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
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF03253B),
                            letterSpacing: -0.2,
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
                    ),
                  ] else ...[
                    // Non-Home screens: Working Back Button + Actual Screen Title
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
                                  color: const Color(0xFFE2ECF5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF03253B),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF03253B),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty)
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF556F88),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right Actions: Custom actions or notifications + profile
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...?actions,
                if (showNotifications)
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF263C4F),
                      size: 23,
                    ),
                    onPressed: onNotificationTap ?? () {},
                    tooltip: 'Notifications',
                  ),
                if (showProfile)
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A5A6A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
