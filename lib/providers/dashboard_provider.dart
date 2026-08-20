import 'package:flutter/foundation.dart';
import '../models/dashboard_report_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class DashboardProvider with ChangeNotifier {
  DashboardReportModel? _report;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider() {
    fetchDashboardReport();
  }

  Future<void> fetchDashboardReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _report = _getMockReport();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.reportDashboard);
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

      _report = DashboardReportModel.fromJson(contentMap);
    } else {
      _errorMessage = response.message;
      _report = _getMockReport();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pesanan Masuk ({{url}}report/dashboard/in)
  List<DashboardOrderInModel> _ordersInList = [];
  bool _isLoadingOrdersIn = false;
  List<DashboardOrderInModel> get ordersInList => List.unmodifiable(_ordersInList);
  bool get isLoadingOrdersIn => _isLoadingOrdersIn;

  Future<void> fetchDashboardOrdersIn({int page = 1}) async {
    _isLoadingOrdersIn = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _ordersInList = [
        DashboardOrderInModel(
          invoice: 'INV20240912-2',
          customerName: 'Retail',
          customerType: 'Retail',
          salesName: 'Jayson Kessler',
          transactionType: 'Transfer',
          transactionDate: '2024-09-12 12:11:11',
          total: 150000,
        ),
        DashboardOrderInModel(
          invoice: 'INV20240908-11',
          customerName: 'Retail',
          customerType: 'Retail',
          salesName: 'Jayson Kessler',
          transactionType: 'Transfer',
          transactionDate: '2024-09-08 21:50:16',
          total: 3000,
        ),
      ];
      _isLoadingOrdersIn = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getReportDashboardInUrl(page: page);
    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      List rawList = [];

      if (resData is Map) {
        if (resData['data'] is List) {
          rawList = resData['data'] as List;
        } else if (resData['content'] != null && resData['content']['data'] is List) {
          rawList = resData['content']['data'] as List;
        }
      } else if (resData is List) {
        rawList = resData;
      }

      _ordersInList = rawList.map((e) => DashboardOrderInModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }
    _isLoadingOrdersIn = false;
    notifyListeners();
  }

  // Pesanan Tersimpan ({{url}}report/dashboard/saved)
  List<DashboardOrderSavedModel> _ordersSavedList = [];
  bool _isLoadingOrdersSaved = false;
  List<DashboardOrderSavedModel> get ordersSavedList => List.unmodifiable(_ordersSavedList);
  bool get isLoadingOrdersSaved => _isLoadingOrdersSaved;

  Future<void> fetchDashboardOrdersSaved({int page = 1}) async {
    _isLoadingOrdersSaved = true;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _ordersSavedList = [
        DashboardOrderSavedModel(
          cartId: 'd6d9c711-2bb1-49f1-b790-30e5ea51315a',
          customerName: 'Retail',
          customerType: 'Retail',
          salesName: 'Jayson Kessler',
          date: '2024-09-12 14:13:32',
          totalTransaction: 6000,
        ),
        DashboardOrderSavedModel(
          cartId: 'b4e992dd-48ef-4881-b76d-3b7bcc3f5341',
          customerName: 'Retail',
          customerType: 'Retail',
          salesName: 'Jayson Kessler',
          date: '2024-09-12 12:13:04',
          totalTransaction: 166000,
        ),
      ];
      _isLoadingOrdersSaved = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getReportDashboardSavedUrl(page: page);
    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final dynamic resData = response.data;
      List rawList = [];

      if (resData is Map) {
        if (resData['content'] != null && resData['content']['data'] is List) {
          rawList = resData['content']['data'] as List;
        } else if (resData['data'] is List) {
          rawList = resData['data'] as List;
        }
      } else if (resData is List) {
        rawList = resData;
      }

      _ordersSavedList = rawList.map((e) => DashboardOrderSavedModel.fromJson(Map<String, dynamic>.from(e is Map ? e : {}))).toList();
    }
    _isLoadingOrdersSaved = false;
    notifyListeners();
  }

  // Detail Order In ({{url}}report/dashboard/in/:invoice)
  DashboardOrderDetailModel? _selectedOrderDetail;
  bool _isLoadingOrderDetail = false;
  DashboardOrderDetailModel? get selectedOrderDetail => _selectedOrderDetail;
  bool get isLoadingOrderDetail => _isLoadingOrderDetail;

  Future<void> fetchOrderInDetail(String invoice) async {
    _isLoadingOrderDetail = true;
    _selectedOrderDetail = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _selectedOrderDetail = DashboardOrderDetailModel.fromJson({
        "invoice": invoice,
        "customer": {"name": "Charles", "type": "Retail"},
        "sales": {"name": "Joko"},
        "items": {
          "total": 17,
          "detail": [
            {
              "name": "TAS Super LR",
              "long_name": "Beringin | Super",
              "category": {"parent": "Beringin"},
              "type": "Super",
              "price": 14000,
              "qty": 5,
              "subtotal": 70000
            },
            {
              "name": "TAS LS Kecil HT",
              "long_name": "Losspack | Hitam",
              "category": {"parent": "Losspack"},
              "type": "Hitam",
              "price": 23000,
              "qty": 2,
              "subtotal": 46000
            },
            {
              "name": "TAS K015H",
              "long_name": "Beringin | Kecil",
              "category": {"parent": "Beringin"},
              "type": "Kecil",
              "price": 3000,
              "qty": 10,
              "subtotal": 25000
            }
          ]
        },
        "discount": {"is_percent": false, "value": "5000"},
        "subtotal": 146000,
        "total": 141000
      });
      _isLoadingOrderDetail = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getReportDashboardInDetailUrl(invoice);
    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final resData = response.data;
      Map<String, dynamic> cMap = {};
      if (resData is Map) {
        if (resData['content'] is Map) {
          cMap = Map<String, dynamic>.from(resData['content'] as Map);
        } else {
          cMap = Map<String, dynamic>.from(resData);
        }
      }
      _selectedOrderDetail = DashboardOrderDetailModel.fromJson(cMap);
    }
    _isLoadingOrderDetail = false;
    notifyListeners();
  }

  // Detail Order Saved ({{url}}report/dashboard/saved/:id)
  Future<void> fetchOrderSavedDetail(String cartId) async {
    _isLoadingOrderDetail = true;
    _selectedOrderDetail = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      _selectedOrderDetail = DashboardOrderDetailModel.fromJson({
        "id": cartId,
        "customer": {"name": "Charles", "type": "Retail"},
        "sales": {"name": "Joko"},
        "items": {
          "total": 17,
          "details": [
            {
              "name": "TAS Super LR",
              "long_name": "Beringin | Super",
              "category": {"parent": "Beringin"},
              "type": "Super",
              "price": 14000,
              "qty": 5,
              "subtotal": 70000
            },
            {
              "name": "TAS LS Kecil HT",
              "long_name": "Losspack | Hitam",
              "category": {"parent": "Losspack"},
              "type": "Hitam",
              "price": 23000,
              "qty": 2,
              "subtotal": 46000
            },
            {
              "name": "TAS K015H",
              "long_name": "Beringin | Kecil",
              "category": {"parent": "Beringin"},
              "type": "Kecil",
              "price": 3000,
              "qty": 10,
              "subtotal": 25000
            }
          ]
        },
        "discount": {"is_percent": false, "value": "5000"},
        "subtotal": 146000,
        "total": 141000
      });
      _isLoadingOrderDetail = false;
      notifyListeners();
      return;
    }

    final url = ApiEndpoints.getReportDashboardSavedDetailUrl(cartId);
    final response = await ApiService.get(url);
    if (response.isSuccess && response.data != null) {
      final resData = response.data;
      Map<String, dynamic> cMap = {};
      if (resData is Map) {
        if (resData['content'] is Map) {
          cMap = Map<String, dynamic>.from(resData['content'] as Map);
        } else {
          cMap = Map<String, dynamic>.from(resData);
        }
      }
      _selectedOrderDetail = DashboardOrderDetailModel.fromJson(cMap);
    }
    _isLoadingOrderDetail = false;
    notifyListeners();
  }

  DashboardReportModel _getMockReport() {
    return DashboardReportModel.fromJson({
      "transaction": {
        "in": {"items": 0, "total": 0},
        "saved": {"items": 14, "total": 8},
        "nett": 0
      },
      "stock": [
        {
          "id": "2029c6b2-82f0-477a-afdf-9a14c164d2bb",
          "item": {
            "name": "CUP JELLY 90ML",
            "long_name": "CUP JELLY PLASTIK 90MM + TUTUP",
            "image": "http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png",
            "unit": "Pack"
          },
          "category": {"child": "Cup", "parent": "Cup"},
          "type": "Jelly",
          "qty": 14
        },
        {
          "id": "a7b02b93-c2cf-4803-9c7b-f6caa351a790",
          "item": {
            "name": "GELAS 10OZ TT",
            "long_name": "GELAS PLASTIK TIPTOP 10OZ",
            "image": "http://poswenapidev.nalentora.cloud/storage/images/default/no-image.png",
            "unit": "Pack"
          },
          "category": {"child": "Gelas", "parent": "Gelas"},
          "type": "Plastik",
          "qty": 15
        }
      ]
    });
  }
}
