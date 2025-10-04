import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final String? semanticHint;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double padding;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.semanticHint,
    this.iconColor,
    this.backgroundColor,
    this.size = 24.0,
    this.padding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Semantics(
      label: semanticLabel,
      button: true,
      hint: semanticHint,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 48.0,
            minHeight: 48.0,
          ),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).iconTheme.color,
            size: size,
          ),
        ),
      ),
    );
  }
}