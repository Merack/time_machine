import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/config/app_config.dart';
import '../../route/route_name.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '关于',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.DONATE),
            icon: const Icon(Icons.favorite_outline),
            tooltip: '打赏支持',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 应用图标
                _buildAppIcon(),
                const SizedBox(height: 24),
                // 应用名称
                const Text(
                  AppConfig.APPNAME,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // 版本信息
                Text(
                  '版本 ${AppConfig.APPVERSION}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                // 作者信息
                const Text(
                  '作者: ${AppConfig.AUTHOR}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // GitHub 链接
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '源码',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SelectableText(
                      AppConfig.GITHUB,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Text(
                  '${AppConfig.ORGANIZATION} 出品',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/icon/icon.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.timer, size: 50);
        },
      ),
    );
  }
}
