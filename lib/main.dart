import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Wars Karakterleri',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.orbitronTextTheme(),
      ),
      home: const KarakterListesi(),
    );
  }
}

class KarakterListesi extends StatefulWidget {
  const KarakterListesi({super.key});

  @override
  State<KarakterListesi> createState() => _KarakterListesiState();
}

class _KarakterListesiState extends State<KarakterListesi> {
  List<dynamic> tumKarakterler = [];
  List<dynamic> filtreliKarakterler = [];
  Map<String, dynamic>? seciliKarakter;
  Set<String> favoriler = {};
  TextEditingController aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    karakterleriGetir();
  }

  Future<void> karakterleriGetir() async {
    try {
      final String jsonVeri =
          await rootBundle.loadString('assets/karakterler.json');
      final veri = json.decode(jsonVeri);
      setState(() {
        tumKarakterler = veri['results'];
        filtreliKarakterler = List.from(tumKarakterler);
        seciliKarakter = tumKarakterler[0];
      });
    } catch (e) {
      print("YEREL VERİ HATASI: $e");
    }
  }

  void karakterFiltrele(String arama) {
    setState(() {
      filtreliKarakterler = tumKarakterler
          .where((k) =>
              k['name'].toLowerCase().contains(arama.toLowerCase()))
          .toList();
    });
  }

  void favoriToggle(String isim) {
    setState(() {
      if (favoriler.contains(isim)) {
        favoriler.remove(isim);
      } else {
        favoriler.add(isim);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Star Wars Karakterleri"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: "Favoriler",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                builder: (_) => FavoriListesi(
                  favoriler: favoriler,
                  karakterler: tumKarakterler,
                  onKarakterSec: (k) {
                    setState(() {
                      seciliKarakter = k;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Center(
                child: Text(
                  'Karakter Listesi',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: aramaController,
                decoration: const InputDecoration(
                  labelText: 'Ara...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: karakterFiltrele,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filtreliKarakterler.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final k = filtreliKarakterler[index];
                  return ListTile(
                    title: Text(k['name']),
                    trailing: IconButton(
                      icon: Icon(
                        favoriler.contains(k['name'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoriler.contains(k['name'])
                            ? Colors.red
                            : const Color.fromARGB(255, 255, 0, 0),
                      ),
                      onPressed: () => favoriToggle(k['name']),
                    ),
                    onTap: () {
                      setState(() {
                        seciliKarakter = k;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: seciliKarakter == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            seciliKarakter!['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        seciliKarakter!['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      bilgiSatiri("Boy", seciliKarakter!['height']),
                      bilgiSatiri("Kilo", seciliKarakter!['mass']),
                      bilgiSatiri("Saç Rengi", seciliKarakter!['hair_color']),
                      bilgiSatiri("Ten Rengi", seciliKarakter!['skin_color']),
                      bilgiSatiri("Göz Rengi", seciliKarakter!['eye_color']),
                      bilgiSatiri("Doğum Yılı", seciliKarakter!['birth_year']),
                      bilgiSatiri("Cinsiyet", seciliKarakter!['gender']),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget bilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$baslik:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            deger,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class FavoriListesi extends StatelessWidget {
  final Set<String> favoriler;
  final List<dynamic> karakterler;
  final Function(Map<String, dynamic>) onKarakterSec;

  const FavoriListesi({
    super.key,
    required this.favoriler,
    required this.karakterler,
    required this.onKarakterSec,
  });

  @override
  Widget build(BuildContext context) {
    final favoriListesi =
        karakterler.where((k) => favoriler.contains(k['name'])).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Favori Karakterler", style: TextStyle(fontSize: 20)),
          const Divider(),
          ...favoriListesi.map((k) => ListTile(
                title: Text(k['name']),
                onTap: () => onKarakterSec(k),
              )),
        ],
      ),
    );
  }
}
