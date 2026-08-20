import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 9));
  DateTime _endDate = DateTime.now();

  final Map<String, String> _filterLabels = {
    'today': 'Hari Ini',
    'yesterday': 'Kemarin',
    'week': '7 Hari Sebelumnya',
    'month': '30 Hari Sebelumnya',
    'year': '1 Tahun',
    'custom': 'Kustom',
  };

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);

    String dropdownValue = reportProv.selectedFilter;
    if (!_filterLabels.containsKey(dropdownValue)) {
      dropdownValue = 'today';
    }

    final activeFilterName = _filterLabels[dropdownValue] ?? 'Hari Ini';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Filter Dropdown Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('Hari ini')),
                  DropdownMenuItem(value: 'yesterday', child: Text('Kemarin')),
                  DropdownMenuItem(value: 'week', child: Text('7 Hari Sebelumnya')),
                  DropdownMenuItem(value: 'month', child: Text('30 Hari Sebelumnya')),
                  DropdownMenuItem(value: 'year', child: Text('1 Tahun')),
                  DropdownMenuItem(value: 'custom', child: Text('Kustom')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    if (val == 'yesterday') {
                      final yesterday = DateTime.now().subtract(const Duration(days: 1));
                      reportProv.setCustomDateRange(yesterday, yesterday);
                    } else if (val == 'custom') {
                      _selectDateRange(context, reportProv);
                    } else {
                      reportProv.setFilter(val);
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Custom Date Range Pickers (Filter Tanggal)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Tanggal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context, reportProv),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Awal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(_startDate),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context, reportProv),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Akhir', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(_endDate),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Summary Metric Header Banner
          Text(
            activeFilterName,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.rupiah(reportProv.totalPemasukan),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            '16 Pesanan',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // 4. 2x2 Interactive Metric Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTabCard(
                  title: 'Pesanan Masuk',
                  value: '${reportProv.pesananMasukCount}',
                  isSelected: reportProv.selectedType == 'in',
                  onTap: () => reportProv.setType('in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTabCard(
                  title: 'Pesanan Tersimpan',
                  value: '${reportProv.pesananTersimpanCount}',
                  isSelected: reportProv.selectedType == 'saved',
                  onTap: () => reportProv.setType('saved'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTabCard(
                  title: 'Pesanan Sales',
                  value: '${reportProv.pesananSalesCount}',
                  isSelected: reportProv.selectedType == 'sales' && reportProv.selectedFilter != 'total_income',
                  onTap: () => reportProv.setType('sales'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTabCard(
                  title: 'Total Pemasukan',
                  value: Formatters.rupiah(reportProv.totalPemasukan),
                  isSelected: reportProv.selectedType == 'sales' && reportProv.selectedFilter == 'total_income',
                  onTap: () {
                    reportProv.setType('sales');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Bar Chart Section ("Grafik Penjualan...")
          Text(
            'Grafik Penjualan $activeFilterName',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: reportProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBarChart(reportProv.chartData),
          ),
          const SizedBox(height: 24),

          // 6. Best Sellers Section ("Produk Terlaris")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produk Terlaris',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Icon(Icons.arrow_drop_up, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),

          if (reportProv.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (reportProv.bestSellers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Belum ada data produk terlaris', style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportProv.bestSellers.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = reportProv.bestSellers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.longName ?? '${item.parentCategory} | ${item.childCategory}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.total} ${item.unit}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricTabCard({
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected ? const Color(0xFF29B6F6) : Colors.white;
    final textColor = isSelected ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isSelected ? Colors.white70 : AppColors.textSecondary;
    final borderColor = isSelected ? const Color(0xFF29B6F6) : Colors.grey.shade300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF29B6F6).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<ReportChartItemModel> chartData) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text('Belum ada data grafik', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final maxVal = chartData.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final double safeMax = (maxVal == 0 ? 10 : maxVal).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: chartData.map((item) {
        final double ratio = (item.total / safeMax).clamp(0.05, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 14,
                  height: 120 * ratio,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.date,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _selectStartDate(BuildContext context, ReportProvider prov) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      prov.setCustomDateRange(_startDate, _endDate);
    }
  }

  Future<void> _selectEndDate(BuildContext context, ReportProvider prov) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      prov.setCustomDateRange(_startDate, _endDate);
    }
  }

  Future<void> _selectDateRange(BuildContext context, ReportProvider prov) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      prov.setCustomDateRange(range.start, range.end);
    }
  }
}
