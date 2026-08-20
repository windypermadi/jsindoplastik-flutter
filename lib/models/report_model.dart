class ReportChartItemModel {
  final String date;
  final num total;

  ReportChartItemModel({
    required this.date,
    required this.total,
  });

  factory ReportChartItemModel.fromJson(Map<String, dynamic> json) {
    return ReportChartItemModel(
      date: json['date']?.toString() ?? '',
      total: num.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class ReportBestSellerModel {
  final String name;
  final String? longName;
  final String parentCategory;
  final String childCategory;
  final String unit;
  final int total;

  ReportBestSellerModel({
    required this.name,
    this.longName,
    required this.parentCategory,
    required this.childCategory,
    required this.unit,
    required this.total,
  });

  factory ReportBestSellerModel.fromJson(Map<String, dynamic> json) {
    String pCat = '';
    String cCat = '';
    if (json['category'] is Map) {
      final catMap = json['category'] as Map;
      pCat = catMap['parent']?.toString() ?? '';
      cCat = catMap['child']?.toString() ?? '';
    }

    return ReportBestSellerModel(
      name: json['name']?.toString() ?? '',
      longName: json['long_name']?.toString(),
      parentCategory: pCat,
      childCategory: cCat,
      unit: json['unit']?.toString() ?? 'Pack',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class ReportResponseModel {
  final List<ReportChartItemModel> reportList;
  final List<ReportBestSellerModel> bestSellerList;

  ReportResponseModel({
    required this.reportList,
    required this.bestSellerList,
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) {
    List<ReportChartItemModel> reports = [];
    if (json['report'] is List) {
      reports = (json['report'] as List)
          .map((e) => ReportChartItemModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    }

    List<ReportBestSellerModel> bestSellers = [];
    if (json['best_seller'] is List) {
      bestSellers = (json['best_seller'] as List)
          .map((e) => ReportBestSellerModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {})))
          .toList();
    }

    return ReportResponseModel(
      reportList: reports,
      bestSellerList: bestSellers,
    );
  }
}
