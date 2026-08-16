class ReportSummaryModel {
  final double totalSalesToday;
  final int totalOrdersToday;
  final double totalKasbonActive;
  final int totalProductsLowStock;
  final List<TopProductModel> topSellingProducts;

  ReportSummaryModel({
    required this.totalSalesToday,
    required this.totalOrdersToday,
    required this.totalKasbonActive,
    required this.totalProductsLowStock,
    required this.topSellingProducts,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalSalesToday: (json['total_sales_today'] ?? 0).toDouble(),
      totalOrdersToday: (json['total_orders_today'] ?? 0).toInt(),
      totalKasbonActive: (json['total_kasbon_active'] ?? 0).toDouble(),
      totalProductsLowStock: (json['total_products_low_stock'] ?? 0).toInt(),
      topSellingProducts: (json['top_selling'] as List<dynamic>?)
              ?.map((e) => TopProductModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TopProductModel {
  final String productName;
  final int totalSold;
  final double revenue;

  TopProductModel({
    required this.productName,
    required this.totalSold,
    required this.revenue,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      productName: json['product_name'] ?? json['nama_produk'] ?? '',
      totalSold: (json['total_sold'] ?? json['terjual'] ?? 0).toInt(),
      revenue: (json['revenue'] ?? json['omset'] ?? 0).toDouble(),
    );
  }
}
