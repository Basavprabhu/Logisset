import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  QuerySnapshot<Map<String, dynamic>>? _notificationsSnapshot;
  QuerySnapshot<Map<String, dynamic>>? _locationsSnapshot;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchLocations();
  }

  void _fetchNotifications() async {
    _notificationsSnapshot = await _firestore.collection('notifications').get();
    setState(() {});
  }

  void _fetchLocations() async {
    _locationsSnapshot = await _firestore.collection('movement').get();
    setState(() {});
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredNotifications() {
    if (_notificationsSnapshot == null) return [];
    if (_searchController.text.isEmpty) {
      return _notificationsSnapshot!.docs;
    } else {
      return _notificationsSnapshot!.docs.where((snapshot) {
        String body = snapshot.data().containsKey('body')
            ? snapshot['body']
            : 'No body field found';
        return body
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredLocations() {
    if (_locationsSnapshot == null) return [];
    if (_searchController.text.isEmpty) {
      return _locationsSnapshot!.docs;
    } else {
      return _locationsSnapshot!.docs.where((snapshot) {
        String body = snapshot.data().containsKey('body')
            ? snapshot['body']
            : 'No body field found';
        return body
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0; // Show notifications data
                    });
                  },
                  child: Text('Notifications',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // Show locations data
                    });
                  },
                  child: Text('Location',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                ),
              ),
            ],
          ),
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: _currentIndex == 0
                ? _buildNotificationListView()
                : _buildLocationListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationListView() {
    return ListView.builder(
      itemCount: _filteredNotifications().length,
      itemBuilder: (context, index) {
        DocumentSnapshot? snapshot = _filteredNotifications()[index];
        String body = snapshot.get('body') as String? ?? 'No body field found';
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title:
                Text(body, style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
        );
      },
    );
  }

  Widget _buildLocationListView() {
    return ListView.builder(
      itemCount: _filteredLocations().length,
      itemBuilder: (context, index) {
        DocumentSnapshot? snapshot = _filteredLocations()[index];
        String body = snapshot.get('body') as String? ?? 'No body field found';
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title:
                Text(body, style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
        );
      },
    );
  }
}
