import 'package:flutter/material.dart';

class InteractionPage extends StatefulWidget {
  const InteractionPage({super.key});

  @override
  State<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  bool _isConnected = true;
  // Add finger state tracking
  final Map<String, bool> _activeFingers = {
    'index': false,
    'middle': false,
    'ring': false,
    'pinky': false,
  };

  // Add finger configurations
  final Map<String, Map<String, dynamic>> _fingerConfigs = {
    'index': {
      'color': const Color(0xFF2196F3), // Blue for food
      'icon': Icons.restaurant_menu,
      'action': 'Need food',
    },
    'middle': {
      'color': const Color(0xFF00BCD4), // Cyan for water
      'icon': Icons.water_drop,
      'action': 'Need Water',
    },
    'ring': {
      'color': const Color(0xFFE91E63), // Pink for medical
      'icon': Icons.medical_services,
      'action': 'Need Nurse or Medicine',
    },
    'pinky': {
      'color': const Color(0xFF9C27B0), // Purple for assistance
      'icon': Icons.wc,
      'action': 'Need Assistance for bathroom',
    },
  };

  void _handleFingerMovement(String finger, String action) {
    setState(() {
      _activeFingers[finger] = true;
    });

    // Check if multiple fingers are active
    int activeCount = _activeFingers.values.where((active) => active).length;

    if (activeCount > 1) {
      _showAlert(
        'Emergency Alert',
        'Multiple finger movements detected!\nTreating as emergency signal.',
        true,
      );
    } else {
      _showAlert(
        'Action Detected',
        'Patient moved: $finger\nRequested: $action',
        false,
      );
    }

    // Reset finger state after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activeFingers[finger] = false;
        });
      }
    });
  }

  void _showAlert(String title, String message, bool isEmergency) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: isEmergency
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Text(message),
          icon: Icon(
            isEmergency ? Icons.warning_rounded : Icons.info_outline,
            color: isEmergency
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFingerMovementCard(String finger) {
    final config = _fingerConfigs[finger.toLowerCase()]!;
    final Color fingerColor = config['color'] as Color;
    final bool isActive = _activeFingers[finger.toLowerCase()] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () =>
            _handleFingerMovement(finger.toLowerCase(), config['action']),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? fingerColor : fingerColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      fingerColor.withOpacity(0.2),
                      Colors.white,
                    ],
                  )
                : null,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fingerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: fingerColor.withOpacity(0.2),
                ),
              ),
              child: Icon(
                config['icon'] as IconData,
                color: fingerColor,
                size: 32,
              ),
            ),
            title: Text(
              '$finger Finger',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isActive ? fingerColor : null,
              ),
            ),
            subtitle: Text(
              config['action'] as String,
              style: TextStyle(
                color: isActive ? fingerColor : fingerColor.withOpacity(0.7),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: fingerColor.withOpacity(0.5),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Finger Movement Controls'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Connection status container
          Container(
            padding: const EdgeInsets.all(16.0),
            color: _isConnected
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected
                      ? const Color(0xFF43A047)
                      : const Color(0xFFD32F2F),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Sensor Connected' : 'Sensor Disconnected',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Instructions text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Move your fingers as indicated below to communicate:',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          // Finger movement list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildFingerMovementCard('Index'),
                _buildFingerMovementCard('Middle'),
                _buildFingerMovementCard('Ring'),
                _buildFingerMovementCard('Pinky'),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Note: Moving multiple fingers simultaneously will trigger an emergency alert',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Emergency button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showAlert(
                  'Emergency Alert',
                  'Emergency signal received from patient!\nImmediate assistance required.',
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_rounded, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'EMERGENCY',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
