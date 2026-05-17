import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrailerPlayerWidget extends StatelessWidget {
  final String youtubeId;

  const TrailerPlayerWidget({super.key, required this.youtubeId});

  Future<void> _launchYoutube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
    // Mở bằng ứng dụng mặc định (ưu tiên ứng dụng Youtube nếu có, nếu không mở bằng Web)
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ảnh thumbnail chất lượng cao từ Youtube
    final thumbnailUrl = 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

    return GestureDetector(
      onTap: _launchYoutube,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black87),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Lớp phủ màu đen mờ để làm nổi bật nút Play
            Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            // Nút Play hiển thị trực quan
            Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
