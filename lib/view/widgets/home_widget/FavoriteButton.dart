// أضف هذا الـ Widget في نفس الملف تحت class _HomeScreenState
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../view_model/favorites_cuibt/favorites_cubit.dart';

class FavoriteButton extends StatefulWidget {
  final String adId;
  final bool isFavorited;

  const FavoriteButton({
    required this.adId,
    required this.isFavorited,
  });

  @override
  State<FavoriteButton> createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    context.read<FavoritesCubit>().toggleFavorite(widget.adId);

    // تشغيل الأنيميشن
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _toggleFavorite,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isFavorited ? Colors.red.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isFavorited ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorited ? Colors.red : Colors.grey.shade400,
            size: 22,
          ),
        ),
      ),
    );
  }
}