import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/glass_container.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.aboutApp,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.primaryDark,
                    AppColors.primaryDark.withValues(alpha: 0.8),
                    const Color(0xFF040924),
                  ]
                : [
                    const Color(0xFF1E88E5),
                    const Color(0xFF42A5F5),
                    const Color(0xFF64B5F6),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStudentCard(
                  context: context,
                  isDark: isDark,
                  title: l10n.member1,
                  name: 'Hoàng Đại Nghĩa',
                  studentId: '23010467',
                  major: 'Công nghệ thông tin',
                  classInfo: 'K17_CNTT5',
                  imagePath: 'assets/images/Nghia.jpg',
                ),
                const SizedBox(height: 24),
                _buildStudentCard(
                  context: context,
                  isDark: isDark,
                  title: l10n.member2,
                  name: 'Nguyễn Thanh Hải',
                  studentId: '23010467',
                  major: 'Khoa học máy tính',
                  classInfo: 'K17_AIKHDL1',
                  imagePath: 'assets/images/Hai.jpg',
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    l10n.translate('version'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String name,
    required String studentId,
    required String major,
    required String classInfo,
    String? imagePath,
  }) {
    final l10n = AppLocalizations.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: imagePath != null ? AssetImage(imagePath) : null,
            child: imagePath == null
                ? const Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.badge_rounded, l10n.studentName, name),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.numbers_rounded, l10n.studentId, studentId),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.school_rounded, l10n.major, major),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.class_rounded, l10n.classInfo, classInfo),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
