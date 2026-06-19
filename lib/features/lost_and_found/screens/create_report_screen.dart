import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/lost_and_found_bottom_bar.dart';
import '../services/lost_and_found_service.dart';

class CreateReportScreen extends StatefulWidget {
  final bool initialIsLostReport;

  const CreateReportScreen({
    Key? key,
    this.initialIsLostReport = true,
  }) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  late bool isLaporKehilangan;

  @override
  void initState() {
    super.initState();
    isLaporKehilangan = widget.initialIsLostReport;
  }
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Controllers for inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4A4444),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryRed),
                title: const Text('Galeri Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        _dateController.text = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  void _submitReport() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar('Nama barang tidak boleh kosong');
      return;
    }
    if (_selectedCategory == null) {
      _showSnackbar('Silakan pilih kategori barang');
      return;
    }
    if (_dateController.text.trim().isEmpty) {
      _showSnackbar('Silakan pilih tanggal kejadian');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showSnackbar('Lokasi tidak boleh kosong');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackbar('Deskripsi tidak boleh kosong');
      return;
    }

    // Tampilkan Dialog Sukses Premium
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 72,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Laporan Terkirim!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4444),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isLaporKehilangan
                      ? 'Laporan kehilangan berhasil dibuat. Semoga barangmu segera ditemukan!'
                      : 'Laporan penemuan berhasil dibuat. Terima kasih atas kepedulianmu!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Tutup dialog
                      
                      // Buat objek data laporan baru
                      final Map<String, dynamic> newReport = {
                        'status': isLaporKehilangan ? 'LOST REPORT' : 'FOUND REPORT',
                        'itemName': _nameController.text.trim().toUpperCase(),
                        'location': _locationController.text.trim(),
                        'imageUrl': _imageFile != null
                            ? _imageFile!.path
                            : (isLaporKehilangan 
                                ? 'https://images.unsplash.com/photo-1532619675605-1ecc6c23db2e?q=80&w=300' 
                                : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300'),
                        'category': _selectedCategory,
                        'date': _dateController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'reporterName': LostAndFoundService().activeUserName,
                        'reporterAvatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150',
                        'reporterRating': 5.0,
                        'isLostReport': isLaporKehilangan,
                        'reportStatus': 'DIPROSES',
                        'statusColor': isLaporKehilangan ? AppColors.primaryRed : const Color(0xFF00897B),
                      };

                      Navigator.pop(context, newReport); // Pop kembali ke MainScreen dengan data baru
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Kembali ke Menu'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Background Merah Melengkung di atas
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),

                  // Konten Utama
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE3E1), // Warna krem/pink pucat
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              const Text(
                                'Buat Laporan',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4A4444),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bantu komunitas dengan melaporkan barang yang\nhilang atau ditemukan di sekitar kampus.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Toggle Buttons
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLaporKehilangan = true),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isLaporKehilangan ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Lapor Kehilangan\nBarang',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isLaporKehilangan ? AppColors.primaryRed : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLaporKehilangan = false),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: !isLaporKehilangan ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Lapor Menemukan\nBarang',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: !isLaporKehilangan ? AppColors.primaryRed : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Form Container (Merah)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('NAMA BARANG'),
                                    _buildTextField(
                                      hintText: 'Contoh: Kunci Motor Honda, Jaket Almamater',
                                      controller: _nameController,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    _buildLabel('KATEGORI'),
                                    _buildDropdown(hintText: 'Pilih Kategori'),
                                    const SizedBox(height: 16),

                                    _buildLabel('TANGGAL KEJADIAN'),
                                    _buildTextField(
                                      hintText: 'Ketuk untuk memilih tanggal',
                                      controller: _dateController,
                                      readOnly: true,
                                      onTap: _selectDate,
                                    ),
                                    const SizedBox(height: 16),

                                    _buildLabel('LOKASI TERAKHIR'),
                                    _buildTextField(
                                      hintText: 'Contoh: Kantin Teknik, Lab Komputer 3',
                                      controller: _locationController,
                                      prefixIcon: Icons.location_on,
                                    ),
                                    const SizedBox(height: 16),

                                    _buildLabel('DESKRIPSI'),
                                    _buildTextField(
                                      hintText: 'Sebutkan ciri-ciri khusus (misal: ada gantungan kunci boneka, warna luntur di saku)...',
                                      controller: _descriptionController,
                                      maxLines: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Bagian Upload Foto & Submit (Samping-sampingan)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Kotak Pilih Gambar (Interaktif)
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 105,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: _imageFile != null
                                            ? Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.file(_imageFile!, fit: BoxFit.cover),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _imageFile = null;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(
                                                          color: Colors.black54,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryRed.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: AppColors.primaryRed,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: const Text(
                                                      'Pilih Gambar',
                                                      style: TextStyle(
                                                        color: AppColors.primaryRed,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Deskripsi & Kirim Laporan
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Pastikan foto terlihat jelas untuk mempercepat proses verifikasi',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.black54,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _submitReport,
                                            icon: const Icon(Icons.send, size: 14),
                                            label: const Text(
                                              'Kirim Laporan',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFA81C1C), // Merah gelap
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Reusable bottom navigation bar matching the mockup
            const LostAndFoundBottomBar(activeIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    IconData? prefixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.primaryRed, size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hintText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          hint: Text(
            hintText,
            style: const TextStyle(color: Colors.black38, fontSize: 13),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: const [
            DropdownMenuItem(value: 'Elektronik', child: Text('Elektronik', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'Aksesoris & Personal', child: Text('Aksesoris & Personal', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'Buku & Alat Tulis', child: Text('Buku & Alat Tulis', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'Dokumen Penting', child: Text('Dokumen Penting', style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: 'Lain-lain', child: Text('Lain-lain', style: TextStyle(fontSize: 13))),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ),
    );
  }
}
