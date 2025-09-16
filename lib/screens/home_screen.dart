import 'dart:convert';
import 'package:apz_utils/apz_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/plugin_metadata.dart';
import '../widgets/dynamic_form.dart';
import '../services/plugin_launcher.dart';
import 'result_screen.dart';
import 'plugin_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PluginMetadata> plugins = [];

  @override
  void initState() {
    super.initState();
    loadPluginMetadata();
  }

  Future<void> loadPluginMetadata() async {
    final jsonString = await rootBundle.loadString('assets/plugin_metadata.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      plugins = parsePluginMetadata(jsonMap);
    });
  }

  void openPluginForm(PluginMetadata plugin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PluginFormScreen(plugin: plugin),
      ),
    );
  }

  IconData _getPluginIcon(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'contact':
      case 'contact_picker':
        return Icons.contacts;
      case 'date_picker':
      case 'custom_datepicker':
        return Icons.calendar_today;
      case 'device_info':
        return Icons.device_hub;
      case 'gps':
        return Icons.location_on;
      case 'in_app_review':
        return Icons.star_rate;
      case 'inapp_update':
        return Icons.system_update;
      case 'network_state':
      case 'network_state_perm':
        return Icons.wifi;
      case 'notification':
        return Icons.notifications;
      case 'pdf_viewer':
        return Icons.picture_as_pdf;
      case 'photopicker':
        return Icons.photo_library;
      case 'qr':
        return Icons.qr_code;
      case 'screenshot':
        return Icons.screenshot;
      case 'send_sms':
        return Icons.sms;
      case 'app_switch':
        return Icons.swap_horiz;
      case 'biometric':
        return Icons.fingerprint;
      case 'deeplink':
        return Icons.link;
      case 'device_fingerprint':
        return Icons.security;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Icons.document_scanner;
      case 'file_operations':
        return Icons.folder_open;
      case 'apz_peripherals':
        return Icons.devices;
      case 'apz_screen_security':
        return Icons.screen_lock_portrait;
      case 'apz_share':
        return Icons.share;
      case 'apz_webview':
        return Icons.web;
      case 'apz_idle_timeout':
        return Icons.timer;
      default:
        return Icons.extension;
    }
  }

  Color _getPluginColor(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
      case 'photopicker':
        return Colors.blue;
      case 'contact':
      case 'contact_picker':
        return Colors.green;
      case 'date_picker':
      case 'custom_datepicker':
        return Colors.orange;
      case 'device_info':
      case 'device_fingerprint':
        return Colors.purple;
      case 'gps':
        return Colors.red;
      case 'in_app_review':
        return Colors.amber;
      case 'inapp_update':
        return Colors.teal;
      case 'network_state':
      case 'network_state_perm':
        return Colors.indigo;
      case 'notification':
        return Colors.pink;
      case 'pdf_viewer':
        return Colors.brown;
      case 'qr':
        return Colors.cyan;
      case 'screenshot':
        return Colors.grey;
      case 'send_sms':
        return Colors.lightGreen;
      case 'app_switch':
        return Colors.deepPurple;
      case 'biometric':
        return Colors.deepOrange;
      case 'deeplink':
        return Colors.lightBlue;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Colors.blueGrey;
      case 'file_operations':
        return Colors.lime;
      case 'apz_peripherals':
        return Colors.indigo;
      case 'apz_screen_security':
        return Colors.red;
      case 'apz_share':
        return Colors.green;
      case 'apz_webview':
        return Colors.blue;
      case 'apz_idle_timeout':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Tester'),
        elevation: 0,
      ),floatingActionButton: kDebugMode
          ? FloatingActionButton(
              key: const ValueKey('home_button_dumpWidgetTree'),
              onPressed: () {
                debugDumpApp();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Widget tree dumped to console.'),
                  ),
                );
              },
              backgroundColor: Colors.amber,
              child: const Icon(Icons.bug_report),
              tooltip: 'Dump Widget Tree',
            )
          : null,
      body: plugins.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading plugins...'),
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
                ),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: plugins.length,
                itemBuilder: (context, index) {
                  final plugin = plugins[index];
                  final icon = _getPluginIcon(plugin.name);
                  final color = _getPluginColor(plugin.name);
                  
                  return Card(
                    elevation: 8,
                    shadowColor: color.withOpacity(0.3),
                    child: InkWell(
                      onTap: () => openPluginForm(plugin),
                      key: ValueKey('home_button_${plugin.name}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.1),
                              color.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  icon,
                                  size: 32,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                plugin.name.replaceAll('_', ' ').toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${plugin.fields.length} fields',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
