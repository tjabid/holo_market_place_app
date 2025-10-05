import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable{
  final String id;
  final String displayName;
  final IconData icon;
  final bool isSelected;

  const Category({required this.id, required this.displayName, required this.icon, this.isSelected = false});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      displayName: json['displayName'],
      icon: json['icon'],
      isSelected: json['isSelected'],
    );
  }
  
  @override
  List<Object?> get props => [id, displayName, icon, isSelected];

}