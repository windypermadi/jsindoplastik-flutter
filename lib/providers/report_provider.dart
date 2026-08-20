import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class ReportProvider with ChangeNotifier {
  ReportResponseModel? _reportResponse;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected filters
  String _selectedType = 'sales'; // 'in', 'saved', 'sales'
  String _selectedFilter = 'today'; // 'today', 'week', 'month', 'year', 'custom'
  DateTime? _dateStart;
  DateTime? _dateEnd;

  // Summary Metrics
  int _pesananMasukCount = 16;
  int _pesananTersimpanCount = 36;
  int _pesananSalesCount = 4;
  double _totalPemasukan = 1256000.0;

  ReportResponseModel? get reportResponse => _reportResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedType => _selectedType;
  String get selectedFilter => _selectedFilter;
  DateTime? get dateStart => _dateStart;
  DateTime? get dateEnd => _dateEnd;

  int get pesananMasukCount => _pesananMasukCount;
  int get pesananTersimpanCount => _pesananTersimpanCount;
  int get pesananSalesCount => _pesananSalesCount;
  double get totalPemasukan => _totalPemasukan;

  List<ReportChartItemModel> get chartData => _reportResponse?.reportList ?? [];
  List<ReportBestSellerModel> get bestSellers => _reportResponse?.bestSellerList ?? [];

  ReportProvider() {
    fetchReport();
  }

  void setType(String type) {
    _selectedType = type;
    fetchReport();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    if (filter != 'custom') {
      _dateStart = null;
      _dateEnd = null;
    }
    fetchReport();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _selectedFilter = 'custom';
    _dateStart = start;
    _dateEnd = end;
    fetchReport();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> fetchReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _reportResponse = _getMockReport();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getReportFilteredUrl(
      type: _selectedType,
      filter: _selectedFilter,
      dateStart: _dateStart != null ? _formatDate(_dateStart!) : null,
      dateEnd: _dateEnd != null ? _formatDate(_dateEnd!) : null,
    );

    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      Map<String, dynamic> contentMap = {};
      if (resData is Map) {
        if (resData['content'] is Map) {
          contentMap = Map<String, dynamic>.from(resData['content'] as Map);
        } else {
          contentMap = Map<String, dynamic>.from(resData);
        }
      }

      _reportResponse = ReportResponseModel.fromJson(contentMap);
    } else {
      _errorMessage = response.message;
      _reportResponse = _getMockReport();
    }

    _isLoading = false;
    notifyListeners();
  }

  ReportResponseModel _getMockReport() {
    return ReportResponseModel(
      reportList: [
        ReportChartItemModel(date: '00:00', total: 0),
        ReportChartItemModel(date: '04:00', total: 2),
        ReportChartItemModel(date: '08:00', total: 5),
        ReportChartItemModel(date: '12:00', total: 8),
        ReportChartItemModel(date: '16:00', total: 3),
        ReportChartItemModel(date: '20:00', total: 5),
        ReportChartItemModel(date: '23:59', total: 0),
      ],
      bestSellerList: [
        ReportBestSellerModel(
          name: 'HG 1KG N G',
          longName: 'HD 02 | Naga',
          parentCategory: 'Food Pack',
          childCategory: 'Kantong',
          unit: 'Pack',
          total: 59,
        ),
        ReportBestSellerModel(
          name: 'Karet Jago',
          longName: 'Karet Gelang Merah',
          parentCategory: 'Aksesoris',
          childCategory: 'Karet',
          unit: 'Pack',
          total: 42,
        ),
        ReportBestSellerModel(
          name: 'GELAS 10OZ TT',
          longName: 'GELAS PLASTIK TIPTOP 10OZ',
          parentCategory: 'Food Pack',
          childCategory: 'Gelas',
          unit: 'Pack',
          total: 35,
        ),
        ReportBestSellerModel(
          name: 'SEDOTAN MM',
          longName: 'PIPET PUTIH TEKUK PREMIUM',
          parentCategory: 'Alat Makan',
          childCategory: 'Pipet',
          unit: 'kg',
          total: 28,
        ),
      ],
    );
  }
}
