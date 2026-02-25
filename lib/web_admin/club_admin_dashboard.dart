import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/models/club.dart';
import 'package:unihub/utils/glass_components.dart';

class ClubAdminDashboard extends StatefulWidget {
  final Club club;
  const ClubAdminDashboard({super.key, required this.club});

  @override
  State<ClubAdminDashboard> createState() => _ClubAdminDashboardState();
}

class _ClubAdminDashboardState extends State<ClubAdminDashboard> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.black26,
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white10,
            child: Text(
              widget.club.shortName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.club.name,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildMenuItem(0, Icons.people, "Üyeler"),
          _buildMenuItem(1, Icons.event, "Etkinlikler"),
          _buildMenuItem(2, Icons.info, "Kulüp Bilgileri"),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.white70),
            title: const Text("Geri Dön", style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, color: isSelected ? Colors.cyanAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildMembersView();
      case 1:
        return _buildEventsView();
      case 2:
        return _buildInfoView();
      default:
        return Container();
    }
  }

  Future<void> _showRoleChangeDialog(Map<String, dynamic> member) async {
    String? newRole = member['role'];
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43).withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Rol Değiştir", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Kullanıcı: ${member['user_id']}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            const Text("Yeni Rol Seçin:", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  RadioListTile<String>(
                    title: const Text("Başkan", style: TextStyle(color: Colors.white)),
                    value: "president",
                    groupValue: newRole,
                    onChanged: (value) => setState(() => newRole = value),
                    activeColor: Colors.cyanAccent,
                  ),
                  RadioListTile<String>(
                    title: const Text("Yönetici", style: TextStyle(color: Colors.white)),
                    value: "admin",
                    groupValue: newRole,
                    onChanged: (value) => setState(() => newRole = value),
                    activeColor: Colors.cyanAccent,
                  ),
                  RadioListTile<String>(
                    title: const Text("Üye", style: TextStyle(color: Colors.white)),
                    value: "member",
                    groupValue: newRole,
                    onChanged: (value) => setState(() => newRole = value),
                    activeColor: Colors.cyanAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(context);
              await _updateMemberRole(member['user_id'], newRole!);
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMemberRole(String userId, String newRole) async {
    try {
      await Supabase.instance.client
          .from('club_members')
          .update({'role': newRole})
          .eq('user_id', userId)
          .eq('club_id', widget.club.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rol başarıyla güncellendi")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rol güncellenirken hata: $e")),
        );
      }
    }
  }

  Future<void> _removeMember(String userId) async {
    try {
      await Supabase.instance.client
          .from('club_members')
          .delete()
          .eq('user_id', userId)
          .eq('club_id', widget.club.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Üye kulüpten çıkarıldı")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Üye çıkarılırken hata: $e")),
        );
      }
    }
  }

  Widget _buildMembersView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Üye Yönetimi", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('club_members')
                  .stream(primaryKey: ['club_id', 'user_id'])
                  .eq('club_id', widget.club.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final members = snapshot.data!;
                return AuraGlassCard(
                  child: ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (c, i) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.cyan.withValues(alpha: 0.3),
                          child: Text(member['role'].substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(member['user_id'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(member['role'], style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                              onPressed: () => _showRoleChangeDialog(member),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                              onPressed: () => _removeMember(member['user_id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Etkinlik Yönetimi", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showCreateEventDialog,
                icon: const Icon(Icons.add),
                label: const Text("Yeni Etkinlik"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('events')
                  .stream(primaryKey: ['id'])
                  .eq('club_id', widget.club.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final events = snapshot.data!;
                return AuraGlassCard(
                  child: ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (c, i) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        leading: const Icon(Icons.event, color: Colors.cyanAccent),
                        title: Text(event['title'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(event['start_time'], style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await Supabase.instance.client.from('events').delete().eq('id', event['id']);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoView() {
    return ClubInfoEditView(
      club: widget.club,
      onUpdate: (updatedClub) {
        // Kulüp bilgileri güncellendiğinde state'i güncelle
        setState(() {
          // Widget'ı yeniden build etmek için
        });
      },
    );
  }

  Future<void> _showCreateEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final maxParticipantsController = TextEditingController();
    
    DateTime? startDate;
    DateTime? endDate;
    String? eventType;
    bool isOnline = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: AuraGlassCard(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event, color: Colors.cyanAccent, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Yeni Etkinlik Oluştur",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Etkinlik Adı
                  const Text("Etkinlik Adı", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  AuraGlassTextField(
                    controller: titleController,
                    hintText: "Etkinlik adını girin",
                  ),
                  const SizedBox(height: 16),
                  
                  // Açıklama
                  const Text("Açıklama", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  AuraGlassTextField(
                    controller: descriptionController,
                    hintText: "Etkinlik açıklaması",
                  ),
                  const SizedBox(height: 16),
                  
                  // Etkinlik Türü
                  const Text("Etkinlik Türü", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  AuraGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: eventType,
                      hint: const Text("Tür seçin", style: TextStyle(color: Colors.white70)),
                      dropdownColor: const Color(0xFF2C5364),
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['Sosyal', 'Akademik', 'Kariyer', 'Spor', 'Kültür', 'Diğer'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          eventType = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Çevrimiçi/Çevrimdışı
                  Row(
                    children: [
                      Checkbox(
                        value: isOnline,
                        onChanged: (value) {
                          setState(() {
                            isOnline = value ?? false;
                          });
                        },
                        activeColor: Colors.cyanAccent,
                      ),
                      const Text("Çevrimiçi Etkinlik", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Konum
                  if (!isOnline) ...[
                    const Text("Konum", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    AuraGlassTextField(
                      controller: locationController,
                      hintText: "Etkinlik yeri",
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Başlangıç Tarihi
                  const Text("Başlangıç Tarihi", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            startDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: AuraGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white70),
                          const SizedBox(width: 12),
                          Text(
                            startDate == null 
                              ? "Tarih ve saat seçin" 
                              : "${startDate!.day}/${startDate!.month}/${startDate!.year} ${startDate!.hour.toString().padLeft(2, '0')}:${startDate!.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bitiş Tarihi
                  const Text("Bitiş Tarihi", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            endDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: AuraGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white70),
                          const SizedBox(width: 12),
                          Text(
                            endDate == null 
                              ? "Tarih ve saat seçin" 
                              : "${endDate!.day}/${endDate!.month}/${endDate!.year} ${endDate!.hour.toString().padLeft(2, '0')}:${endDate!.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Maksimum Katılımcı
                  const Text("Maksimum Katılımcı (Opsiyonel)", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  AuraGlassTextField(
                    controller: maxParticipantsController,
                    hintText: "Sınırsız için boş bırakın",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  
                  // Butonlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal", style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (titleController.text.isEmpty || 
                              descriptionController.text.isEmpty || 
                              startDate == null || 
                              endDate == null ||
                              (!isOnline && locationController.text.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                            );
                            return;
                          }
                          
                          Navigator.pop(context);
                          await _createEvent(
                            title: titleController.text,
                            description: descriptionController.text,
                            startDate: startDate!,
                            endDate: endDate!,
                            eventType: eventType ?? 'Diğer',
                            isOnline: isOnline,
                            location: locationController.text,
                            maxParticipants: maxParticipantsController.text.isEmpty 
                                ? null 
                                : int.tryParse(maxParticipantsController.text),
                          );
                        },
                        child: const Text("Oluştur"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String eventType,
    required bool isOnline,
    required String location,
    int? maxParticipants,
  }) async {
    try {
      final client = Supabase.instance.client;
      
      final eventData = {
        'club_id': widget.club.id,
        'title': title,
        'description': description,
        'start_time': startDate.toIso8601String(),
        'end_time': endDate.toIso8601String(),
        'event_type': eventType,
        'is_online': isOnline,
        'location': isOnline ? null : location,
        'max_participants': maxParticipants,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      await client
          .from('events')
          .insert(eventData)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Etkinlik başarıyla oluşturuldu!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Etkinlik oluşturulurken hata: $e")),
        );
      }
    }
  }
}

class ClubInfoEditView extends StatefulWidget {
  final Club club;
  final Function(Club) onUpdate;
  
  const ClubInfoEditView({
    super.key, 
    required this.club, 
    required this.onUpdate,
  });

  @override
  State<ClubInfoEditView> createState() => _ClubInfoEditViewState();
}

class _ClubInfoEditViewState extends State<ClubInfoEditView> {
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _mainColorController;
  
  String? _logoPath;
  String? _bannerPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _shortNameController = TextEditingController(text: widget.club.shortName);
    _descriptionController = TextEditingController(text: widget.club.description);
    _categoryController = TextEditingController(text: widget.club.category);
    _mainColorController = TextEditingController(text: widget.club.mainColor);
    _logoPath = widget.club.logoPath;
    _bannerPath = widget.club.bannerPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _mainColorController.dispose();
    super.dispose();
  }

  Future<void> _updateClubInfo() async {
    if (_nameController.text.isEmpty || _shortNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları doldurun'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      
      final updatedData = {
        'name': _nameController.text,
        'short_name': _shortNameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'main_color': _mainColorController.text,
        'logo_path': _logoPath,
        'banner_path': _bannerPath,
      };

      await client
          .from('clubs')
          .update(updatedData)
          .eq('id', widget.club.id)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        final updatedClub = Club(
          id: widget.club.id,
          universityId: widget.club.universityId,
          name: _nameController.text,
          shortName: _shortNameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          mainColor: _mainColorController.text,
          logoPath: _logoPath,
          bannerPath: _bannerPath,
          tags: widget.club.tags,
          status: widget.club.status,
        );

        widget.onUpdate(updatedClub);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kulüp bilgileri güncellendi'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme hatası: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    // TODO: Image picker implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resim seçme özelliği yakında eklenecek')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: AuraGlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kulüp Bilgilerini Düzenle",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // Logo ve Banner Önizlemesi
            Row(
              children: [
                // Logo
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                          image: _logoPath != null
                              ? DecorationImage(
                                  image: NetworkImage(_logoPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _logoPath == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickImage(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.withValues(alpha: 0.2),
                          foregroundColor: Colors.cyanAccent,
                        ),
                        child: const Text("Logo Değiştir"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Banner
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                          image: _bannerPath != null
                              ? DecorationImage(
                                  image: NetworkImage(_bannerPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _bannerPath == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _pickImage(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.withValues(alpha: 0.2),
                          foregroundColor: Colors.cyanAccent,
                        ),
                        child: const Text("Banner Değiştir"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Form Alanları
            _buildTextField("Kulüp Adı", _nameController, required: true),
            const SizedBox(height: 16),
            _buildTextField("Kısa Ad", _shortNameController, required: true, maxLength: 10),
            const SizedBox(height: 16),
            _buildTextField("Kategori", _categoryController),
            const SizedBox(height: 16),
            _buildTextField("Ana Renk (Hex)", _mainColorController, hint: "#00FFFF"),
            const SizedBox(height: 16),
            _buildTextField("Açıklama", _descriptionController, maxLines: 4),
            const SizedBox(height: 30),
            
            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateClubInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Değişiklikleri Kaydet", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {
    bool required = false,
    int? maxLength,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            if (required) const Text(" *", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        AuraGlassTextField(
          controller: controller,
          hintText: hint ?? label,
          keyboardType: TextInputType.text,
          maxLines: maxLines,
        ),
        if (maxLength != null)
          Text(
            "${controller.text.length}/$maxLength",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
      ],
    );
  }
}