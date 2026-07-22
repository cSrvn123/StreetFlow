import 'package:flutter/material.dart';
import '../services/autocomplete_service.dart';

class SearchPanel extends StatefulWidget {
  final TextEditingController fromController;
  final TextEditingController toController;

  final VoidCallback onUseMyLocation;
  final VoidCallback onFindRoute;

  final double currentLat;
  final double currentLon;

  final Function(
      double lat,
      double lon,
      String address,
      ) onDestinationSelected;

  const SearchPanel({
    super.key,
    required this.fromController,
    required this.toController,
    required this.onUseMyLocation,
    required this.onFindRoute,
    required this.currentLat,
    required this.currentLon,
    required this.onDestinationSelected,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {

List<Map<String, dynamic>> suggestions = [];

bool loading = false;

Future<void> searchDestination(String value) async {

if (value.length < 2) {

setState(() {
suggestions = [];
});

return;
}

setState(() {
loading = true;
});

try {

suggestions =
await AutoCompleteService.search(
value,
widget.currentLat,
widget.currentLon,
);

} catch (e) {

debugPrint(e.toString());

}

setState(() {
loading = false;
});

}

@override
Widget build(BuildContext context) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
boxShadow: const [
BoxShadow(
color: Colors.black26,
blurRadius: 18,
offset: Offset(0, 8),
),
],
),
padding: const EdgeInsets.all(18),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [

Row(
children: const [
Icon(
Icons.route,
color: Colors.blue,
size: 30,
),
SizedBox(width: 10),
Text(
"StreetFlow",
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
],
),

const SizedBox(height: 18),

TextField(
controller: widget.fromController,
decoration: InputDecoration(
prefixIcon: const Icon(
Icons.my_location,
color: Colors.green,
),
hintText: "Starting Location",
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 14),

TextField(
controller: widget.toController,
onChanged: searchDestination,
decoration: InputDecoration(
prefixIcon: const Icon(
Icons.location_on,
color: Colors.red,
),
hintText: "Destination",
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide.none,
),
suffixIcon: loading
? const Padding(
padding: EdgeInsets.all(12),
child: SizedBox(
width: 18,
height: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
),
),
)
: null,
),
),

const SizedBox(height: 8),
if (suggestions.isNotEmpty)
Container(
constraints: const BoxConstraints(
maxHeight: 220,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: ListView.builder(
shrinkWrap: true,
itemCount: suggestions.length,
itemBuilder: (context, index) {
final place = suggestions[index];

return ListTile(
leading: const Icon(
Icons.location_on,
color: Colors.blue,
),
title: Text(place["name"]),
subtitle: Text(place["address"]),

onTap: () {

widget.toController.text =
place["address"];

widget.onDestinationSelected(
place["lat"],
place["lon"],
place["address"],
);

setState(() {
suggestions = [];
});

},
);
},
),
),

const SizedBox(height: 18),

Row(
children: [

Expanded(
child: OutlinedButton.icon(
onPressed: widget.onUseMyLocation,
icon: const Icon(Icons.my_location),
label: const Text("My Location"),
style: OutlinedButton.styleFrom(
minimumSize: const Size(0, 55),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
),

const SizedBox(width: 12),

Expanded(
child: ElevatedButton.icon(
onPressed: widget.onFindRoute,
icon: const Icon(Icons.search),
label: const Text("Find"),
style: ElevatedButton.styleFrom(
minimumSize: const Size(0, 55),
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
),
),

],
),

],
),
);}}