// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  final String type; // 'news', 'blog', 'report'

  const ListScreen({super.key, required this.type});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Article>> _future;

  String get _title {
    switch (widget.type) {
      case 'news':
        return 'Berita Terkini';
      case 'blog':
        return 'Blog Terbaru';
      case 'report':
        return 'Laporan Terbaru';
      default:
        return 'Daftar';
    }
  }

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchList(widget.type, limit: 20);
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2233),
        title: Text(
          _title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat data.\nPeriksa koneksi internet Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _future = ApiService.fetchList(widget.type, limit: 20);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF)),
                    child: const Text('Coba Lagi',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(
              child: Text('Tidak ada data.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildArticleCard(context, article);
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(type: widget.type, id: article.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2233),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2F45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: article.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: const Color(0xFF2A2F45),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF6C63FF)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: const Color(0xFF2A2F45),
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey, size: 48),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: const Color(0xFF2A2F45),
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 48),
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (article.newsSite.isNotEmpty)
                    Text(
                      article.newsSite,
                      style: const TextStyle(
                          color: Color(0xFF6C63FF), fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.publishedAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Icon(Icons.arrow_forward,
                          color: Color(0xFF6C63FF), size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
