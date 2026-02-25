import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:unihub/utils/hex_color.dart';
import 'package:unihub/utils/glass_components.dart';
import 'package:unihub/services/database_service.dart';
import 'package:unihub/models/university.dart';
import 'package:unihub/models/club.dart';
import 'package:unihub/models/app_enums.dart';
import 'package:unihub/web_admin/club_admin_dashboard.dart';

// --- 1. SPONSOR YÖNETİCİSİ ---
class SponsorManager extends StatefulWidget {
  const SponsorManager({super.key});
  @override
  State<SponsorManager> createState() => _SponsorManagerState();
}

class _SponsorManagerState extends State<SponsorManager> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  PlatformFile? _logoFile;
  PlatformFile? _bannerFile;
  bool _isUploading = false;

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _logoFile = result.files.first);
    }
  }

  Future<void> _pickBanner() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _bannerFile = result.files.first);
    }
  }

  Future<String?> _uploadFile(PlatformFile file, String folder) async {
    try {
      debugPrint("Dosya yükleniyor: ${file.name}, Boyut: ${file.bytes?.length ?? 0} bytes");
      
      if (file.bytes == null) {
        throw Exception("Dosya içeriği boş.");
      }
      
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
      final path = "$folder/$fileName";
      
      // Dosya türünü kontrol et
      if (!file.name.toLowerCase().endsWith('.jpg') && 
          !file.name.toLowerCase().endsWith('.jpeg') && 
          !file.name.toLowerCase().endsWith('.png') && 
          !file.name.toLowerCase().endsWith('.gif')) {
        throw Exception("Sadece JPG, PNG ve GIF dosyaları yükleyebilirsiniz.");
      }
      
      // Dosya boyutu kontrolü (5MB)
      if (file.bytes!.length > 5 * 1024 * 1024) {
        throw Exception("Dosya boyutu 5MB'den küçük olmalıdır.");
      }
      
      debugPrint("Yükleme yolu: $path");
      
      await Supabase.instance.client.storage
          .from('sponsors')
          .uploadBinary(path, file.bytes!);
      
      debugPrint("Dosya başarıyla yüklendi: $path");
      return path;
    } on StorageException catch (e) {
      debugPrint("Storage hatası: ${e.message} - ${e.statusCode}");
      if (e.message.contains('Bucket not found')) {
        throw Exception("Storage bucket bulunamadı. Lütfen Supabase dashboard'dan 'sponsors' bucket'ını oluşturun.");
      } else if (e.message.contains('Unauthorized')) {
        throw Exception("Yükleme yetkiniz yok. Lütfen giriş yaptığınızdan emin olun.");
      } else if (e.message.contains('Payload too large')) {
        throw Exception("Dosya çok büyük. Lütfen 5MB'den küçük bir dosya seçin.");
      }
      rethrow;
    } catch (e) {
      debugPrint("Yükleme hatası ($folder): $e");
      throw Exception("Dosya yüklenirken bir hata oluştu: $e");
    }
  }

  Future<void> _addSponsor() async {
    if (_nameController.text.isEmpty || _logoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen en az bir isim ve logo seçiniz.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      debugPrint("Sponsor ekleme başlatıldı: ${_nameController.text}");
      
      String? logoPath = await _uploadFile(_logoFile!, 'logos');
      if (logoPath == null) {
        throw Exception("Logo yüklenirken bir hata oluştu. Lütfen tekrar deneyin.");
      }

      String? bannerPath;
      if (_bannerFile != null) {
        bannerPath = await _uploadFile(_bannerFile!, 'banners');
      }

      final response = await Supabase.instance.client.from('app_sponsors').insert({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'logo_path': logoPath, 
        'banner_path': bannerPath,
        'created_at': DateTime.now().toIso8601String(),
      }).select().timeout(const Duration(seconds: 15));

      debugPrint("Sponsor başarıyla eklendi: $response");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sponsor başarıyla eklendi!"),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _nameController.clear();
          _descController.clear();
          _logoFile = null;
          _bannerFile = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      debugPrint("Sponsor ekleme HATASI: $e");
      String errorMsg = e.toString();
      if (e is PostgrestException) {
        errorMsg = "Veritabanı hatası: ${e.message}";
      } else if (e is TimeoutException) {
        errorMsg = "İşlem zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: $errorMsg"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteSponsor(String id) async {
    try {
      await Supabase.instance.client.from('app_sponsors').delete().eq('id', id);
    } catch (e) {
      debugPrint("Sponsor silinemedi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: AuraGlassCard(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sponsor Ekle",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Firma Adı"),
                  const SizedBox(height: 15),
                  _buildTextField(_descController, "Kampanya Metni"),
                  const SizedBox(height: 20),
                  
                  // Logo Seçimi
                  _buildFilePicker("Logo (Profil)", _logoFile, _pickLogo),
                  const SizedBox(height: 15),
                  
                  // Banner Seçimi
                  _buildFilePicker("Banner (Geniş)", _bannerFile, _pickBanner),
                  const SizedBox(height: 30),
                  
                  if (_isUploading)
                    const CircularProgressIndicator(color: Colors.cyanAccent)
                  else
                    ElevatedButton.icon(
                      onPressed: _addSponsor,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Sponsoru Yayınla"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('app_sponsors')
                  .select('*')
                  .order('created_at', ascending: false)
                  .timeout(const Duration(seconds: 15)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
                }

                final sponsors = snapshot.data ?? [];
                if (sponsors.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz sponsor eklenmemiş. Soldaki panelden yeni sponsor ekleyebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: sponsors.length,
                  itemBuilder: (context, index) {
                    var data = sponsors[index];
                    final logoUrl = DatabaseService().getPublicUrl('sponsors', data['logo_path']);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: AuraGlassCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: logoUrl.isNotEmpty 
                              ? Image.network(
                                  logoUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.white),
                                )
                              : const Icon(Icons.business, color: Colors.white),
                          ),
                          title: Text(data['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['description'] ?? "", style: const TextStyle(color: Colors.white70)),
                              if (data['banner_path'] != null)
                                const Text("✅ Banner Yüklü", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteSponsor(data['id'].toString()),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

// --- Shared Helpers ---
Widget _buildFilePicker(String label, PlatformFile? file, VoidCallback onPick) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 5),
      InkWell(
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Icon(file == null ? Icons.image_outlined : Icons.check_circle, 
                   color: file == null ? Colors.white54 : Colors.greenAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file?.name ?? "Dosya Seç...",
                  style: TextStyle(color: file == null ? Colors.white38 : Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 8),
      AuraGlassTextField(
        controller: controller,
        hintText: label,
        maxLines: maxLines,
      ),
    ],
  );
}

// --- 2. KULÜP OLUŞTURUCU ---
class ClubCreator extends StatefulWidget {
  const ClubCreator({super.key});
  @override
  State<ClubCreator> createState() => _ClubCreatorState();
}

class _ClubCreatorState extends State<ClubCreator> {
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _colorController = TextEditingController(text: "#00BCD4");
  
  PlatformFile? _logoFile;
  PlatformFile? _bannerFile;
  bool _isUploading = false;

  final DatabaseService _dbService = DatabaseService();
  int? _selectedUniId;
  List<University> _universities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final unis = await _dbService.getUniversities();
      if (mounted) {
        setState(() {
          _universities = unis;
          if (unis.isNotEmpty) _selectedUniId = unis.first.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Üniversiteler yüklenemedi: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _logoFile = result.files.first);
    }
  }

  Future<void> _pickBanner() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _bannerFile = result.files.first);
    }
  }

  Future<String?> _uploadFile(PlatformFile file, String folder) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
      final path = "$folder/$fileName";
      
      await Supabase.instance.client.storage
          .from('clubs')
          .uploadBinary(path, file.bytes!);
      
      return path;
    } catch (e) {
      debugPrint("Yükleme hatası ($folder): $e");
      return null;
    }
  }

  Future<void> _createClub() async {
    if (_nameController.text.isEmpty || _selectedUniId == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen kulüp adı ve üniversite seçiniz.")));
       return;
    }

    setState(() => _isUploading = true);

    try {
      String? logoPath;
      if (_logoFile != null) {
        logoPath = await _uploadFile(_logoFile!, 'logos');
      }

      String? bannerPath;
      if (_bannerFile != null) {
        bannerPath = await _uploadFile(_bannerFile!, 'banners');
      }

      await Supabase.instance.client.from('clubs').insert({
        'name': _nameController.text.trim(),
        'short_name': _shortNameController.text.trim().toUpperCase(),
        'description': _descController.text.trim(),
        'category': _categoryController.text.trim(),
        'university_id': _selectedUniId,
        'main_color': _colorController.text.trim(),
        'logo_path': logoPath,
        'banner_path': bannerPath,
        'status': ClubStatus.active.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      }).timeout(const Duration(seconds: 15));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kulüp Başarıyla Oluşturuldu!"), backgroundColor: Colors.green));
        
        _nameController.clear();
        _shortNameController.clear();
        _descController.clear();
        _categoryController.clear();
        setState(() {
          _logoFile = null;
          _bannerFile = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      debugPrint("Kulüp oluşturulamadı: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.redAccent));
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(30),
        child: AuraGlassCard(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Yeni Kulüp Oluştur",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),

                DropdownButtonFormField<int>(
                initialValue: _selectedUniId,
                dropdownColor: const Color(0xFF203A43),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Üniversite",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
                items: _universities
                    .map((uni) => DropdownMenuItem(value: uni.id, child: Text(uni.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedUniId = val),
              ),
              const SizedBox(height: 15),

              _buildTextField(_nameController, "Kulüp Adı"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField(_shortNameController, "Kısaltma")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_categoryController, "Kategori")),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(_descController, "Açıklama", maxLines: 3),
              const SizedBox(height: 15),
              _buildTextField(_colorController, "Tema Rengi (Hex)"),
              const SizedBox(height: 20),
              
              // Logo ve Banner Seçimi
              Row(
                children: [
                  Expanded(child: _buildFilePicker("Logo", _logoFile, _pickLogo)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildFilePicker("Banner", _bannerFile, _pickBanner)),
                ],
              ),
              const SizedBox(height: 30),
              
              if (_isUploading)
                const CircularProgressIndicator(color: Colors.cyanAccent)
              else
                ElevatedButton.icon(
                  onPressed: _createClub,
                  icon: const Icon(Icons.add_circle),
                  label: const Text("Sisteme Ekle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

// --- 3. TÜM KULÜPLERİ YÖNET ---
class AllClubsManager extends StatelessWidget {
  const AllClubsManager({super.key});

  Future<void> _deleteClub(BuildContext context, int clubId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("⚠️ KESİN SİLME", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bu işlem geri alınamaz. Kulüp ve tüm verileri silinecek.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SİL"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final client = Supabase.instance.client;
        await client.from('club_members').delete().eq('club_id', clubId);
        await client.from('events').delete().eq('club_id', clubId);
        await client.from('clubs').delete().eq('id', clubId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kulüp silindi.")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('clubs')
          .select('*')
          .timeout(const Duration(seconds: 15)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
        }

        var clubsData = snapshot.data ?? [];
        if (clubsData.isEmpty) return const Center(child: Text("Kayıtlı kulüp yok.", style: TextStyle(color: Colors.white)));

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 1.2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: clubsData.length,
            itemBuilder: (context, index) {
              final club = Club.fromJson(clubsData[index]);
              final Color primaryColor = hexToColor(club.mainColor);
              final logoUrl = DatabaseService().getPublicUrl('clubs', club.logoPath);

              return AuraGlassCard(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor.withValues(alpha: 0.2),
                          radius: 35,
                          backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                          child: logoUrl.isEmpty 
                            ? Text(
                                club.shortName,
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                              )
                            : null,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          club.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          club.category,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ClubAdminDashboard(club: club)),
                                );
                              },
                              child: const Text("Yönet", style: TextStyle(color: Colors.cyanAccent)),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _deleteClub(context, club.id),
                            ),
                          ],
                        )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: club.status == ClubStatus.active 
                              ? Colors.green.withValues(alpha: 0.2) 
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          club.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8, 
                            color: club.status == ClubStatus.active ? Colors.greenAccent : Colors.orangeAccent
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- 4. ETKİNLİK YÖNETİMİ (GLOBAL) ---
class GlobalEventManagement extends StatelessWidget {
  const GlobalEventManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('events')
          .select('*')
          .order('start_time', ascending: false)
          .timeout(const Duration(seconds: 15)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Etkinlikler yüklenemedi: ${snapshot.error}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final events = snapshot.data ?? [];
        
        if (events.isEmpty) {
          return const Center(
            child: Text(
              "Henüz bir etkinlik planlanmamış.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tüm Etkinlikler",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AuraGlassCard(
                  child: ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.1)),
                    itemBuilder: (context, index) {
                      final eventData = events[index];
                      return ListTile(
                        leading: const Icon(Icons.event, color: Colors.cyanAccent),
                        title: Text(eventData['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${eventData['location']} - ${DateTime.parse(eventData['start_time']).toString().substring(0, 16)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await Supabase.instance.client.from('events').delete().eq('id', eventData['id']);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- 5. ÜNİVERSİTE YÖNETİMİ ---
class UniversityManager extends StatefulWidget {
  const UniversityManager({super.key});

  @override
  State<UniversityManager> createState() => _UniversityManagerState();
}

class _UniversityManagerState extends State<UniversityManager> {
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _domainController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addUniversity() async {
    if (_nameController.text.isEmpty || _shortNameController.text.isEmpty || _domainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('universities').insert({
        'name': _nameController.text.trim(),
        'short_name': _shortNameController.text.trim(),
        'domain': _domainController.text.trim().startsWith('@') 
            ? _domainController.text.trim() 
            : '@${_domainController.text.trim()}',
      });

      _nameController.clear();
      _shortNameController.clear();
      _domainController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Üniversite başarıyla eklendi!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUniversity(int id) async {
    try {
      await Supabase.instance.client.from('universities').delete().eq('id', id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Silinemedi: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: AuraGlassCard(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Üniversite Ekle",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Üniversite Tam Adı"),
                  const SizedBox(height: 15),
                  _buildTextField(_shortNameController, "Kısa Ad (Örn: İTÜ)"),
                  const SizedBox(height: 15),
                  _buildTextField(_domainController, "E-posta Uzantısı (Örn: @itu.edu.tr)"),
                  const SizedBox(height: 30),
                  
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.cyanAccent)
                  else
                    ElevatedButton.icon(
                      onPressed: _addUniversity,
                      icon: const Icon(Icons.add_business),
                      label: const Text("Üniversiteyi Kaydet"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('universities')
                  .select('*')
                  .order('name', ascending: true)
                  .timeout(const Duration(seconds: 15)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Bağlantı Hatası\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text("Tekrar Dene", style: TextStyle(color: Colors.cyanAccent)),
                        )
                      ],
                    ),
                  );
                }
                
                final unis = snapshot.data ?? [];
                
                if (unis.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz üniversite eklenmemiş.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: unis.length,
                  itemBuilder: (context, index) {
                    final uni = unis[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: AuraGlassCard(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.cyanAccent,
                            child: Icon(Icons.school, color: Colors.black),
                          ),
                          title: Text(uni['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("Kısa Ad: ${uni['short_name']} | Domain: ${uni['domain']}", 
                                      style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteUniversity(uni['id']),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

