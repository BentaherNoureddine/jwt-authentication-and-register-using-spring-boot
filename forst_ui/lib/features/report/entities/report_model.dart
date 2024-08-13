import 'dart:ffi';

import 'package:equatable/equatable.dart';

import 'category_entity.dart';

class ReportEntity extends Equatable {

  final Long id;

  final Category category;

  final String description;

  final Long reporterId;

  final String photo;

  final String location;

  final DateTime createdAt;

  const ReportEntity(
      {required this.id,
      required this.category,
      required this.createdAt,
      required this.description,
      required this.location,
      required this.photo,
      required this.reporterId});

  @override
  List<Object?> get props => [id,category,createdAt,description,location,photo,reporterId];
}



