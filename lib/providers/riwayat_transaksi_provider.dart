import 'package:flutter/foundation.dart';
import '../models/riwayat_transaksi_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_endpoints.dart';

class RiwayatTransaksiProvider with ChangeNotifier {
  List<RiwayatTransaksiGroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  DateTime? _startDate;
  DateTime? _endDate;

  List<RiwayatTransaksiGroupModel> get groups {
    if (_searchQuery.isEmpty) return _groups;
    final q = _searchQuery.toLowerCase();

    List<RiwayatTransaksiGroupModel> filtered = [];
    for (final group in _groups) {
      final matchingTxs = group.transactions.where((t) {
        return t.customerName.toLowerCase().contains(q) ||
            t.salesName.toLowerCase().contains(q) ||
            t.paymentMethod.toLowerCase().contains(q);
      }).toList();

      if (matchingTxs.isNotEmpty) {
        filtered.add(RiwayatTransaksiGroupModel(
          dateDay: group.dateDay,
          dateMonthYear: group.dateMonthYear,
          dayOfWeek: group.dayOfWeek,
          dailyTotal: matchingTxs.fold(0.0, (sum, item) => sum + item.totalAmount),
          transactions: matchingTxs,
        ));
      }
    }
    return filtered;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  RiwayatTransaksiProvider() {
    fetchRiwayatTransaksi();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    fetchRiwayatTransaksi();
  }

  Future<void> fetchRiwayatTransaksi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final isMock = await StorageService.isMockMode();
    if (isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _groups = _getMockGroups();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.get(ApiEndpoints.reportsSales);
    if (response.isSuccess && response.data != null) {
      final List dataList = response.data is List ? response.data : (response.data['data'] ?? []);
      if (dataList.isNotEmpty && dataList.first is Map && (dataList.first as Map).containsKey('date_day')) {
        _groups = dataList.map((e) => RiwayatTransaksiGroupModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        _groups = _getMockGroups();
      }
    } else {
      _groups = _getMockGroups();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<RiwayatTransaksiGroupModel> _getMockGroups() {
    return [
      RiwayatTransaksiGroupModel(
        dateDay: '27',
        dateMonthYear: 'Juni 2024',
        dayOfWeek: 'Kamis',
        dailyTotal: 547500,
        transactions: [
          RiwayatTransaksiItemModel(
            id: 'TX-2701',
            customerName: 'Anggi',
            customerType: 'VIP',
            salesName: 'Joko',
            date: '27 Juni 2024',
            subtotal: 146000,
            totalDiscount: 5000,
            totalAmount: 141000,
            paymentMethod: 'QR',
            items: [
              RiwayatOrderItemModel(code: '01', name: 'TAS Super LR', parentCategory: 'Beringin', childCategory: 'Super', unitPrice: 14000, qty: 5, subtotal: 70000),
              RiwayatOrderItemModel(code: '01', name: 'TAS LS Kecil HT', parentCategory: 'Losspack', childCategory: 'Hitam', unitPrice: 23000, qty: 2, subtotal: 46000),
              RiwayatOrderItemModel(code: '01', name: 'TAS K015H', parentCategory: 'Beringin', childCategory: 'Kecil', unitPrice: 3000, qty: 10, subtotal: 25000),
            ],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2702',
            customerName: 'Dita',
            customerType: 'Retail',
            salesName: 'Joko',
            date: '27 Juni 2024',
            subtotal: 350000,
            totalDiscount: 0,
            totalAmount: 350000,
            paymentMethod: 'Tunai',
            items: [
              RiwayatOrderItemModel(code: '02', name: 'GELAS 10OZ TT', parentCategory: 'Food Pack', childCategory: 'Gelas', unitPrice: 35000, qty: 10, subtotal: 350000),
            ],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2703',
            customerName: 'Siska',
            customerType: 'Retail',
            salesName: 'Rudi',
            date: '27 Juni 2024',
            subtotal: 51500,
            totalDiscount: 0,
            totalAmount: 51500,
            paymentMethod: 'Transfer',
            items: [
              RiwayatOrderItemModel(code: '03', name: 'SEDOTAN MM', parentCategory: 'Alat Makan', childCategory: 'Pipet', unitPrice: 10300, qty: 5, subtotal: 51500),
            ],
          ),
        ],
      ),
      RiwayatTransaksiGroupModel(
        dateDay: '25',
        dateMonthYear: 'Juni 2024',
        dayOfWeek: 'Selasa',
        dailyTotal: 3775400,
        transactions: [
          RiwayatTransaksiItemModel(
            id: 'TX-2501',
            customerName: 'Andi',
            customerType: 'Retail',
            salesName: 'Joko',
            date: '25 Juni 2024',
            subtotal: 652000,
            totalDiscount: 0,
            totalAmount: 652000,
            paymentMethod: 'Tunai',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2502',
            customerName: 'David',
            customerType: 'VIP',
            salesName: 'Rudi',
            date: '25 Juni 2024',
            subtotal: 536000,
            totalDiscount: 0,
            totalAmount: 536000,
            paymentMethod: 'QR',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2503',
            customerName: 'Kus',
            customerType: 'Retail',
            salesName: 'Sales',
            date: '25 Juni 2024',
            subtotal: 286100,
            totalDiscount: 0,
            totalAmount: 286100,
            paymentMethod: 'Tunai',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2504',
            customerName: 'Junaedi',
            customerType: 'Retail',
            salesName: 'Sales',
            date: '25 Juni 2024',
            subtotal: 243000,
            totalDiscount: 0,
            totalAmount: 243000,
            paymentMethod: 'Kasbon',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2505',
            customerName: 'Surya',
            customerType: 'VIP',
            salesName: 'Joko',
            date: '25 Juni 2024',
            subtotal: 2058300,
            totalDiscount: 0,
            totalAmount: 2058300,
            paymentMethod: 'Transfer',
            items: [],
          ),
        ],
      ),
      RiwayatTransaksiGroupModel(
        dateDay: '20',
        dateMonthYear: 'Juni 2024',
        dayOfWeek: 'Kamis',
        dailyTotal: 5305900,
        transactions: [
          RiwayatTransaksiItemModel(
            id: 'TX-2001',
            customerName: 'Bayu Hanggara',
            customerType: 'VIP',
            salesName: 'Joko',
            date: '20 Juni 2024',
            subtotal: 1526000,
            totalDiscount: 0,
            totalAmount: 1526000,
            paymentMethod: 'Tunai',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2002',
            customerName: 'Yoga',
            customerType: 'Retail',
            salesName: 'Rudi',
            date: '20 Juni 2024',
            subtotal: 853000,
            totalDiscount: 0,
            totalAmount: 853000,
            paymentMethod: 'QR',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2003',
            customerName: 'Sanah',
            customerType: 'Retail',
            salesName: 'Sales',
            date: '20 Juni 2024',
            subtotal: 358900,
            totalDiscount: 0,
            totalAmount: 358900,
            paymentMethod: 'Tunai',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2004',
            customerName: 'Tri',
            customerType: 'VIP',
            salesName: 'Joko',
            date: '20 Juni 2024',
            subtotal: 2568000,
            totalDiscount: 0,
            totalAmount: 2568000,
            paymentMethod: 'Transfer',
            items: [],
          ),
        ],
      ),
      RiwayatTransaksiGroupModel(
        dateDay: '20',
        dateMonthYear: 'Juni 2024',
        dayOfWeek: 'Kamis',
        dailyTotal: 1597000,
        transactions: [
          RiwayatTransaksiItemModel(
            id: 'TX-2005',
            customerName: 'Retail',
            customerType: 'Retail',
            salesName: 'Sales',
            date: '20 Juni 2024',
            subtotal: 146000,
            totalDiscount: 0,
            totalAmount: 146000,
            paymentMethod: 'Tunai',
            items: [],
          ),
          RiwayatTransaksiItemModel(
            id: 'TX-2006',
            customerName: 'Sri',
            customerType: 'VIP',
            salesName: 'Joko',
            date: '20 Juni 2024',
            subtotal: 451000,
            totalDiscount: 0,
            totalAmount: 451000,
            paymentMethod: 'QR',
            items: [],
          ),
        ],
      ),
    ];
  }
}
