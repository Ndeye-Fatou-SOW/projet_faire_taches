 
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../pages/todo_form.dart';
import '../providers/home_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Démarre l'initialisation du provider une seule fois
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accueil",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.cyanAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => provider.logout(context),
          ),
        ],
        elevation: 4,
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo de profil
                  Center(
                    child: GestureDetector(
                      onTap: provider.pickProfileImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: provider.profileImagePath != null
                              ? FileImage(File(provider.profileImagePath!))
                              : null,
                          child: provider.profileImagePath == null
                              ? const Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.blueAccent)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bienvenue
                  Center(
                    child: Text(
                      "Bienvenue ${provider.username.isNotEmpty ? provider.username : "Utilisateur"}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Météo
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thermostat, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            "Température : ${provider.temperature}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Adresse
                  if (provider.currentAddress.isNotEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.green),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Adresse : ${provider.currentAddress}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Bouton gestion des tâches
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ok = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TodoFormPage(accountId: provider.accountId),
                          ),
                        );
                        if (ok == true) {
                          await provider.loadTasks();
                        }
                      },
                      icon: const Icon(Icons.task_alt, size: 24),
                      label: const Text(
                        "Gestion des Tâches",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Liste des tâches
                  if (provider.userTasks.isEmpty)
                    const Center(
                      child: Text(
                        "Aucune tâche pour le moment",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.userTasks.length,
                        itemBuilder: (context, index) {
                          final Todo todo = provider.userTasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(
                                todo.todo,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  decoration: todo.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                "Date : ${todo.date.day}/${todo.date.month}/${todo.date.year}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              trailing: Icon(
                                todo.done
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color:
                                    todo.done ? Colors.green : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Carte
                  if (provider.currentLatLng != null)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: provider.currentLatLng!,
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                             // urlTemplate:"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                             // userAgentPackageName: 'com.kasm.tourism',
                             urlTemplate: "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=xktcPACSHFEKJiwkAzgm",
                              userAgentPackageName: 'com.kasm.tourisme',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: provider.currentLatLng!,
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

