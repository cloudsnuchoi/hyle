import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final Widget? icon;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.color,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isText) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color ?? theme.colorScheme.primary,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: _buildChild(context),
      );
    }
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? theme.colorScheme.primary,
          side: BorderSide(
            color: color ?? theme.colorScheme.primary,
            width: 1.5,
          ),
          minimumSize: Size(width ?? double.infinity, height),
          padding: padding,
        ),
        child: _buildChild(context),
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.colorScheme.primary,
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(width ?? double.infinity, height),
        padding: padding,
      ),
      child: _buildChild(context),
    );
  }
  
  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? (isText || isOutlined 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white),
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          AppSpacing.horizontalGapSM,
          Text(
            text,
            style: AppTypography.button,
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: AppTypography.button,
    );
  }
}