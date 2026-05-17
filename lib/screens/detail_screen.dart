// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String type;
  final int id;

  const DetailScreen({super.key, required this.type, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Article> _future;

  String get _title {
    switch (widget.type) {
      case 'news':
        return 'News Detail';
      case 'blog':
        return 'Blog Detail';
      case 'report':
        return 'Report Detail';
      default:
        return 'Detail';
    }
  }

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchDetail(widget.type, widget.id);
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka halaman web.')),
        );
      }
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
      body: FutureBuilder<Article>(
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
                  const Icon(Icons.error_outline, color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat detail.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _future =
                            ApiService.fetchDetail(widget.type, widget.id);
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

          final article = snapshot.data!;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    article.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 240,
                              color: const Color(0xFF2A2F45),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF6C63FF)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 240,
                              color: const Color(0xFF2A2F45),
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey, size: 64),
                            ),
                          )
                        : Container(
                            height: 240,
                            color: const Color(0xFF2A2F45),
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 64),
                          ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // News site & date
                          if (article.newsSite.isNotEmpty)
                            Text(
                              article.newsSite,
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(article.publishedAt),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          const Divider(color: Color(0xFF2A2F45)),
                          const SizedBox(height: 16),

                          // Summary
                          const Text(
                            'Ringkasan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article.summary.isNotEmpty
                                ? article.summary
                                : 'Tidak ada ringkasan tersedia.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.7,
                            ),
                          ),

                          // Extra padding for FAB
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FAB overlay pinned to bottom right
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: () => _launchUrl(article.url),
                  backgroundColor: const Color(0xFF6C63FF),
                  icon: const Icon(Icons.open_in_browser, color: Colors.white),
                  label: const Text(
                    'Buka Web',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
