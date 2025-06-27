import 'package:flutter/material.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '打赏支持',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 提示文字
                  Text(
                    '如果你觉得这个项目对你有帮助, 可以考虑打赏',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 收款码容器
                  _buildPaymentCodes(context),

                  const SizedBox(height: 40),

                  // 感谢文字
                  Text(
                    '感谢您的支持!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCodes(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 支付宝收款码
        _buildPaymentCard(
          context: context,
          title: '支付宝',
          imagePath: 'assets/img/alipay.jpg',
          color: theme.colorScheme.secondary,
        ),
        
        const SizedBox(height: 24),
        
        // 微信支付收款码
        _buildPaymentCard(
          context: context,
          title: '微信支付',
          imagePath: 'assets/img/wechatpay.png',
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // 支付方式标题
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            
            // 收款码图片
            Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),

              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
