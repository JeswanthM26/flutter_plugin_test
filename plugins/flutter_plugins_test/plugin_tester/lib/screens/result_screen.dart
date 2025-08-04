import 'package:flutter/material.dart';
import '../models/plugin_metadata.dart';

class ResultScreen extends StatelessWidget {
  final PluginMetadata plugin;
  final dynamic result;

  const ResultScreen({
    Key? key,
    required this.plugin,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;

    // You can expand this logic for more plugin-specific result displays
    if (result == null) {
      content = const Text('No result or operation was cancelled.');
    } else if (plugin.name == 'camera' && result is Map && result['imagePath'] != null) {
      content = Column(
        children: [
          if (result['imagePath'] != null)
            Image.file(result['imageFile']),
          if (result['base64'] != null)
            SelectableText('Base64: ${result['base64']!.substring(0, 100)}...'),
        ],
      );
    } else if (plugin.name == 'contact' && result is List) {
      content = Expanded(
        child: ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, index) {
            final contact = result[index];
            return ListTile(
              title: Text(contact['name'] ?? ''),
              subtitle: Text('Phone: ${contact['numbers']?.join(', ') ?? ''}'),
            );
          },
        ),
      );
    } else if (plugin.name == 'contact_picker' && result is Map) {
      content = ListTile(
        title: Text(result['fullName'] ?? ''),
        subtitle: Text('Phone: ${result['phoneNumber'] ?? ''}'),
      );
    } else if (plugin.name == 'date_picker' && result is List) {
      content = Text('Selected date(s): ${result.join(', ')}');
    } else if (plugin.name == 'device_info' && result is Map) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result.entries
            .map<Widget>((e) => Text('${e.key}: ${e.value}'))
            .toList(),
      );
    }
    

else if (plugin.name == 'gps' && result is Map) {
  if (result.containsKey('error')) {
    content = Text('Error: ${result['error']}');
  } else {
    content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latitude: ${result['latitude']}'),
        Text('Longitude: ${result['longitude']}'),
        Text('Accuracy: ${result['accuracy']}'),
        Text('Altitude: ${result['altitude']}'),
        Text('Speed: ${result['speed']}'),
        Text('Timestamp: ${result['timestamp']}'),
      ],
    );
  }
}

else if (plugin.name == 'in_app_review') {
  content = const Text('In-app review dialog requested.');
}
else if (plugin.name == 'inapp_update' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries
        .map((e) => Text('${e.key}: ${e.value}'))
        .toList(),
  );
}
else if (plugin.name == 'network_state' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries
        .map((e) => Text('${e.key}: ${e.value}'))
        .toList(),
  );
}
else if (plugin.name == 'notification') {
  content = const Text('Notification triggered.');
}
else if (plugin.name == 'pdf_viewer' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('PDF Source: ${result['source']}'),
      Text('Source Type: ${result['sourceType']}'),
      if (result['password'] != null) Text('Password: ${result['password']}'),
      if (result['headers'] != null) Text('Headers: ${result['headers']}'),
      const Text('Open the PDF viewer in your app for full functionality.'),
    ],
  );
}
else if (plugin.name == 'photopicker' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (result['imagePath'] != null)
        Image.file(result['imageFile']),
      if (result['base64'] != null)
        SelectableText('Base64: ${result['base64']!.substring(0, 100)}...'),
    ],
  );
}
else if (plugin.name == 'qr' && result is Map) {
  // For QR generator, show the generated QR image
  if (result['qrBytes'] != null) {
    content = Image.memory(result['qrBytes']);
  } else {
    content = const Text('QR code generated.');
  }
}
else if (plugin.name == 'screenshot' && result is Map) {
  content = const Text('Screenshot captured and saved.');
}
else if (plugin.name == 'send_sms' && result is Map) {
  content = Text('SMS status: ${result['status']}');
}
else if (plugin.name == 'app_switch' && result is Map) {
  content = Text('App State: ${result['state']}');
}
else if (plugin.name == 'biometric' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Authentication Status: ${result['status'] ? "Success" : "Failed"}'),
      Text('Message: ${result['message']}'),
    ],
  );
}
else if (plugin.name == 'deeplink' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (result.containsKey('initialLink'))
        Text('Initial Link: ${result['initialLink'] ?? "null"}'),
      if (result.containsKey('streamListening'))
        const Text('Listening for live deep links via stream...'),
    ],
  );
}
// else if (plugin.name == 'device_fingerprint' && result is Map) {
//   content = Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text('Fingerprint:', style: Theme.of(context).textTheme.titleMedium),
//       const SizedBox(height: 8),
//       SelectableText(result['fingerprint'] ?? 'No result'),
//     ],
//   );
// }
else if (plugin.name == 'device_fingerprint' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Device Fingerprint:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SelectableText(result['fingerprint'] ?? 'Unavailable'),
    ],
  );
}

if (plugin.name == 'digi_scan_image') {
  final List images = result['scannedImages'] ?? [];
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Scanned Images:', style: Theme.of(context).textTheme.titleMedium),
      ...images.map<Widget>((img) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text("Image URI: ${img['imageUri']} | Size: ${img['bytes']} bytes"),
        );
      }).toList(),
    ],
  );
} else if (plugin.name == 'digi_scan_pdf') {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Scanned PDF:', style: Theme.of(context).textTheme.titleMedium),
      SelectableText(result['pdfUri'] ?? 'No file returned'),
    ],
  );
}
else if (plugin.name == 'file_operations' && result is Map) {
  final files = result['files'] as List<dynamic>?;
  if (files == null) {
    content = const Text('No files selected or operation canceled.');
  } else {
    content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Picked Files:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...files.map<Widget>((f) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '• ${f['name']} (${f['size']} bytes)\n  Path: ${f['path']}\n  MIME: ${f['mimeType']}',
            ),
          );
        }).toList(),
      ],
    );
  }
}
else if (plugin.name == 'network_state_perm' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Carrier Name: ${result['carrierName']}'),
      Text('MCC: ${result['mcc']}'),
      Text('MNC: ${result['mnc']}'),
      Text('Network Type: ${result['networkType']}'),
      Text('Connection Type: ${result['connectionType']}'),
      Text('VPN: ${result['isVpn']}'),
      Text('IP Address: ${result['ipAddress']}'),
      Text('Bandwidth (Mbps): ${result['bandwidthMbps']}'),
      Text('Latency (ms): ${result['latency']}'),
      Text('SSID: ${result['ssid']}'),
      Text('Signal Strength: ${result['signalStrengthLevel']} / 4'),
    ],
  );
}
if (plugin.name == 'apz_peripherals' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries.map((entry) {
      return Text('${entry.key}: ${entry.value}');
    }).toList(),
  );
}
if (plugin.name == 'apz_screen_security' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries.map((e) {
      return Text('${e.key}: ${e.value}');
    }).toList(),
  );
}
if (plugin.name == 'apz_share' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries.map((e) {
      return Text('${e.key}: ${e.value}');
    }).toList(),
  );
}
if (plugin.name == 'apz_webview' && result is Map) {
  content = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: result.entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
  );
}
if (plugin.name == 'apz_idle_timeout') {
  content = Text(result['status'] ?? 'Timeout behavior initialized.');
}


     else {
      content = Text(result.toString());
    }

    return Scaffold(
      appBar: AppBar(title: Text('${plugin.name} Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}