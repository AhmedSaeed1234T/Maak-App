import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/helpers/subscriptionChecker.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:abokamall/services/UserListCache.dart';
import 'package:abokamall/services/ProfileCacheService.dart';
import 'dart:ui';

class OfflineModeTestingPanel extends StatefulWidget {
  const OfflineModeTestingPanel({super.key});

  @override
  State<OfflineModeTestingPanel> createState() =>
      _OfflineModeTestingPanelState();
}

class _OfflineModeTestingPanelState extends State<OfflineModeTestingPanel>
    with SingleTickerProviderStateMixin {
  final tokenService = getIt<TokenService>();
  double _simulatedDays = 0;
  final Color secondary = const Color(0xFF6C63FF);

  // Stats for the glass cards
  String _tokenStatus = "Checking...";
  String _expireFlag = "Checking...";
  String _offlineClock = "Checking...";
  bool _isPhysicallyValid = true;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _refreshStats();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    final hasToken = await tokenService.getRefreshToken() != null;
    await tokenService.getRefreshTokenExpiry();
    final isLocallyValid = await tokenService.isRefreshTokenLocallyValid();

    final lastCheckStr = await tokenService.storage.read(
      key: TokenService.lastOnlineCheckKey,
    );
    DateTime? lastCheckTime;
    if (lastCheckStr != null) lastCheckTime = DateTime.parse(lastCheckStr);

    final email = await getCurrentUser();
    final flag = email != null ? await getUserIsExpired(email) : false;

    if (mounted) {
      setState(() {
        _tokenStatus = hasToken
            ? (isLocallyValid ? "Active ✅" : "Expired ⚠️")
            : "None ❌";
        _expireFlag = flag ? "EXPIRED 🚨" : "VALID ✅";
        _isPhysicallyValid = !flag;

        if (lastCheckTime != null) {
          final diff = DateTime.now().difference(lastCheckTime);
          _offlineClock = "${diff.inDays}d ${diff.inHours % 24}h ago";
        } else {
          _offlineClock = "Never";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Security Debug Terminal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Status Dashboard ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildStatusCard(
                      "Session",
                      _tokenStatus,
                      Icons.vpn_key_rounded,
                      Colors.cyan,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusCard(
                      "Subscription",
                      _expireFlag,
                      Icons.verified_user_rounded,
                      Colors.amber,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("TIME MACHINE"),
                      _buildGlassPanel(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Simulation Offset",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  "${_simulatedDays.toInt()} Days",
                                  style: const TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _simulatedDays,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              activeColor: primary,
                              inactiveColor: Colors.white10,
                              onChanged: (v) =>
                                  setState(() => _simulatedDays = v),
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              "Rewind Last Online Check",
                              Icons.history_toggle_off_rounded,
                              primary,
                              () => _applyTimeMachine(_simulatedDays.toInt()),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Current: $_offlineClock",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle("SYSTEM OVERRIDES"),
                      _buildGlassPanel(
                        child: Column(
                          children: [
                            _buildOverrideRow(
                              "Subscription Flag",
                              "Manually toggle the 'isExpired' bit",
                              _isPhysicallyValid ? "SET EXPIRED" : "SET VALID",
                              _isPhysicallyValid
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                              _toggleSubscriptionFlag,
                            ),
                            const Divider(color: Colors.white10, height: 32),
                            _buildOverrideRow(
                              "Token Lifetime",
                              "Invalidate local JWT immediately",
                              "EXPIRE TOKENS",
                              Colors.orangeAccent,
                              _expireTokens,
                            ),
                            const Divider(color: Colors.white10, height: 32),
                            _buildOverrideRow(
                              "Factory Data Reset",
                              "Clear all cached offline configs",
                              "RESET CONFIG",
                              Colors.white24,
                              _resetEverything,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      Center(
                        child: TextButton.icon(
                          onPressed: _refreshStats,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text("REFRESH RUNTIME STATS"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: _buildGlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
            color: color.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverrideRow(
    String title,
    String desc,
    String btnLabel,
    Color btnColor,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor.withOpacity(0.2),
            foregroundColor: btnColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: btnColor.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            btnLabel,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  // --- Logic Implementations ---

  Future<void> _applyTimeMachine(int days) async {
    final pastTime = DateTime.now().subtract(Duration(days: days));
    await tokenService.storage.write(
      key: TokenService.lastOnlineCheckKey,
      value: pastTime.toIso8601String(),
    );
    tokenService.lastOnlineCheck = null;

    // ✅ SIMULATE AGED DATA: Adjust Hive cache timestamps too
    await getIt<UserListCacheService>().debugRewindCacheTimestamps(
      Duration(days: days),
    );
    await getIt<ProfileCacheService>().debugRewindCacheTimestamps(
      Duration(days: days),
    );

    await _refreshStats();
    _showSnackBar("System & Cache clock rewound by $days days");
  }

  Future<void> _toggleSubscriptionFlag() async {
    final email = await getCurrentUser();
    if (email == null) return;
    await saveUserIsExpired(email, !await getUserIsExpired(email));
    await _refreshStats();
    _showSnackBar("Subscription flag toggled");
  }

  Future<void> _expireTokens() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await tokenService.storage.write(
      key: TokenService.refreshExpiryKey,
      value: yesterday.toIso8601String(),
    );
    tokenService.refreshExpiry = null;
    await _refreshStats();
    _showSnackBar("JWT Tokens expired");
  }

  Future<void> _resetEverything() async {
    tokenService.lastOnlineCheck = null;
    await tokenService.storage.write(
      key: TokenService.lastOnlineCheckKey,
      value: DateTime.now().toIso8601String(),
    );

    // ✅ Reset cache too
    await getIt<UserListCacheService>().clearAllCache();

    await _refreshStats();
    _showSnackBar("Configuration & Cache reset to defaults");
  }

  void _showSnackBar(String msg) {
    CustomSnackBar.show(context, message: msg, type: SnackBarType.info);
  }
}
