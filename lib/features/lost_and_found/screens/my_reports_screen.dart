import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/lost_and_found_item.dart';
import '../widgets/lost_and_found_item_card.dart';
import '../services/lost_and_found_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    LostAndFoundService().addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    LostAndFoundService().removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<LostAndFoundItem> get _myItems {
    return LostAndFoundService().getMyReports();
  }

  List<LostAndFoundItem> _filterByTab(int tabIndex) {
    final items = _myItems;
    switch (tabIndex) {
      case 0: // Aktif
        return items.where((i) => i.isActive).toList();
      case 1: // Dalam Klaim
        return items.where((i) => i.reportStatus == 'DALAM KLAIM').toList();
      case 2: // Riwayat (Selesai + Batal)
        return items.where((i) => !i.isActive).toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE3E1),
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppColors.primaryRed,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Dalam Klaim'),
                Tab(text: 'Riwayat'),
              ],
            ),
          ),
        ),
      ),
      body: _myItems.isEmpty
          ? _buildEmptyAllState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(0),
                _buildTabContent(1),
                _buildTabContent(2),
              ],
            ),
    );
  }

  Widget _buildEmptyAllState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4444),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Laporan yang kamu buat akan muncul di sini. Mulai buat laporan untuk melaporkan barang hilang atau barang temuan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text(
              'Kembali ke Daftar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final items = _filterByTab(tabIndex);
    if (items.isEmpty) {
      return _buildEmptyTabState(tabIndex);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LostAndFoundItemCard(
            item: items[index],
            onStatusUpdated: (newStatus) {
              LostAndFoundService().updateItemStatus(items[index].id, newStatus);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyTabState(int tabIndex) {
    final configs = [
      {
        'icon': Icons.hourglass_empty,
        'title': 'Tidak ada laporan aktif',
        'desc': 'Semua laporan kamu sudah selesai diproses atau masuk tahap klaim.',
      },
      {
        'icon': Icons.handshake_outlined,
        'title': 'Tidak ada proses klaim',
        'desc': 'Belum ada barang yang sedang dalam proses verifikasi dan pengambilan.',
      },
      {
        'icon': Icons.history,
        'title': 'Belum ada riwayat',
        'desc': 'Laporan yang sudah selesai atau dibatalkan akan tampil di sini.',
      },
    ];

    final config = configs[tabIndex];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config['icon'] as IconData, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            config['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4A4444),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              config['desc'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
