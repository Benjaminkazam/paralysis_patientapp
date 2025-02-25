import 'package:flutter/material.dart';
import '../models/vital_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VitalData _dummyData = VitalData(
    heartRate: 75,
    bloodPressure: 120,
    temperature: 37,
    oxygenLevel: 98,
    movementStatus: "Stable",
  );

  Widget _buildVitalCard(
      String title, String value, String unit, IconData icon, Color iconColor) {
    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              iconColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 48, // Increased icon size
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: iconColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28, // Increased value size
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Vitals Monitor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildVitalCard(
                  'Heart Rate',
                  _dummyData.heartRate.toString(),
                  'bpm',
                  Icons.favorite_rounded,
                  const Color(0xFFE53935), // Deep red for heart rate
                ),
                _buildVitalCard(
                  'Blood Pressure',
                  _dummyData.bloodPressure.toString(),
                  'mmHg',
                  Icons.speed_rounded,
                  const Color(0xFF1E88E5), // Medical blue for blood pressure
                ),
                _buildVitalCard(
                  'Temperature',
                  _dummyData.temperature.toString(),
                  '°C',
                  Icons.thermostat_rounded,
                  const Color(0xFFFF8F00), // Warm orange for temperature
                ),
                _buildVitalCard(
                  'Oxygen Level',
                  _dummyData.oxygenLevel.toString(),
                  '%',
                  Icons.air_rounded,
                  const Color(0xFF7B1FA2), // Deep purple for oxygen
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.accessibility_new_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Movement Status'),
                subtitle: Text(_dummyData.movementStatus),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Emergency Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Add emergency alerts list here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/interaction');
        },
        child: const Icon(Icons.gesture),
      ),
    );
  }
}
