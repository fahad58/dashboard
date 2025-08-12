import 'package:dashboard_ui/const/constant.dart';
import 'package:dashboard_ui/corps/object.dart';
import 'package:dashboard_ui/corps/userinterface.dart';
import 'package:dashboard_ui/server/apiconnect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget>
    with SingleTickerProviderStateMixin {
  List<Objects> _properties = [];
  List<Tenants> _tenants = [];
  List<Objects> _properties_etag = [];
  List<Objects> _properties_mehr = [];
  List<Units> _leer = [];

  TextStyle _style = TextStyle(color: icolor.gray);
  String _searchQuery = '';
  String _filterType = 'All';
  List<Objects> get filteredProperties {
    return _properties_etag.where((property) {
      final matchesSearch =
          property.street!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterType == 'All' || property.objectType.toString() == _filterType;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Objects> get filteredProperties_mehr {
    return _properties_mehr.where((property) {
      final matchesSearch =
          property.street!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterType == 'All' || property.objectType.toString() == _filterType;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _searchQueryTenant = '';

  TextStyle textstylenormal = const TextStyle(color: Colors.black);

  List<Tenants> get filteredTenants {
    return _tenants.where((element) {
      final matchesSearch = element.name!
              .toLowerCase()
              .contains(_searchQueryTenant.toLowerCase()) ||
          element.phone!
              .toLowerCase()
              .contains(_searchQueryTenant.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  Future<List<Objects>> loadProperties() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token').toString();
    ServerHandler server = ServerHandler(
        Request: '/load_all_user_property', sendData: {"token": token});
    List<Objects> objects = await server.RequestObjects();
    if (objects != []) {
      for (var property in objects) {
        if (property.objectType?.toLowerCase() == 'etagenwohnung') {
          _properties_etag.add(property);
        } else {
          _properties_mehr
              .add(property); // You can filter more precisely here if needed
        }

        // Collect tenants from each unit
        if (property.units != null) {
          for (var unit in property.units!) {
            print(unit.tenants);
            if (unit.tenants != null) {
              _tenants.addAll(unit.tenants!);
            }
          }
        }
      }
      return objects;
    } else {
      return [];
    }
  }

  Future<int> loadgesamt(String objectid) async {
    int kosten = 0;
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token').toString();
    ServerHandler server = ServerHandler(
        Request: '/getgesamtsumme',
        sendData: {"token": token, 'object_id': objectid});
    int data = await server.getAbrechnunggesamt();
    print('hey');
    print(data);
    if (data != 0) {
      return data;
    } else {
      return 0;
    }
  }

  late Future<List<Objects>> _futureProperties;
  late UserData userdata;
  late Future<UserData> _futureload;
  Future<UserData> loaduserdata() async {
    String token = await UserData().getToken();
    ServerHandler server =
        ServerHandler(Request: "/get_user_data", sendData: {"token": token});
    UserData userdata = await server.getUserData();
    if (userdata.isEmpty) {
      return UserData();
    } else {
      return userdata;
    }
  }

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _futureProperties = loadProperties();
    _futureload = loaduserdata();
  }

  bool logosearch = false;
  bool selectionMode = false;
  bool selectionModeMehr = false;
  Set<Map<String, dynamic>> selectedUnitObjectMehr = {};
  Set<Map<String, dynamic>> selectedUnitObject = {};
  void toggleSelectionMode() {
    setState(() {
      selectionMode = !selectionMode;
      if (!selectionMode) {
        selectedUnitObject.clear();
      }
    });
  }

  String valuewert = '';
  void toggleCardSelection(String objectId) {
    final selection = {"objectid": objectId};

    setState(() {
      if (selectedUnitObject.any((item) => item["objectid"] == objectId)) {
        selectedUnitObject.removeWhere((item) => item["objectid"] == objectId);
      } else {
        selectedUnitObject.add(selection);
      }
    });

    print(selectedUnitObject);
  }

  void toggleSelectionModeMehr() {
    setState(() {
      selectionModeMehr = !selectionModeMehr;
      if (!selectionModeMehr) {
        selectedUnitObjectMehr.clear();
      }
    });
  }

  bool newisloading = false;

  void toggleCardSelectionMehr(String objectId) {
    final selection = {"objectid": objectId};

    setState(() {
      if (selectedUnitObjectMehr.any((item) => item["objectid"] == objectId)) {
        selectedUnitObjectMehr
            .removeWhere((item) => item["objectid"] == objectId);
      } else {
        selectedUnitObjectMehr.add(selection);
      }
    });

    print(selectedUnitObjectMehr);
  }

  Future<void> sendLohnabrechnung(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token').toString();
    if (selectedUnitObject.isEmpty && selectedUnitObjectMehr.isNotEmpty) {
      //selectedMehr
      List<Map<String, dynamic>> formated = [];
      Map<String, dynamic> body = {'token': token};
      for (var item in selectedUnitObjectMehr) {
        List<Map<String, dynamic>> unitdata = [];
        Objects objectfori = _properties_mehr.firstWhere(
          (obj) => obj.objectId == item['objectid'],
          orElse: () => throw Exception("Object not found"),
        );

        for (Units unit in objectfori.units ?? []) {
          if (unit.tenants!.isNotEmpty) {
            unitdata.add({
              'unitid': unit.unitId,
              'tenantid': unit.tenants![0].tenantId,
            });
          }
        }
        formated.add({
          'objectid': item['objectid'],
          'unitdata': unitdata,
        });
      }
      print("DAS IST DER VALUETEXT WERT $valuewert");
      if (valuewert == "Jahresabrechnung") {
        ServerHandler server = ServerHandler(
            Request: '/create_user_specific_jahresabrechnung', sendData: body);
        await server.createAbrechnungallmainscreen(formated, context);
        setState(() {
          newisloading = false;
          selectionMode = false;
        });
      } else if (valuewert == 'Mieterhöhung') {
        ServerHandler server = ServerHandler(
            Request: '/create_user_specific_tenantincrease', sendData: body);
        await server.createErhohungallmainscreen(formated, context);
        setState(() {
          newisloading = false;
          selectionMode = false;
        });
      } else {
        print('eror');
      }
    } else if (selectedUnitObject.isNotEmpty &&
        selectedUnitObjectMehr.isEmpty) {
      //seletecnormal
      List<Map<String, dynamic>> formated = [];
      Map<String, dynamic> body = {'token': token};
      for (var item in selectedUnitObject) {
        List<Map<String, dynamic>> unitdata = [];
        Objects objectfori = _properties_etag.firstWhere(
          (obj) => obj.objectId == item['objectid'],
          orElse: () => throw Exception("Object not found"),
        );

        for (Units unit in objectfori.units ?? []) {
          if (unit.tenants!.isNotEmpty) {
            unitdata.add({
              'unitid': unit.unitId,
              'tenantid': unit.tenants![0].tenantId,
            });
          }
        }
        formated.add({
          'objectid': item['objectid'],
          'unitdata': unitdata,
        });
      }
      print("DAS IST DER VALUETEXTTTTTTT WERT $valuewert");
      if (valuewert == "Jahresabrechnung") {
        ServerHandler server = ServerHandler(
            Request: '/create_user_specific_jahresabrechnung', sendData: body);
        await server.createAbrechnungallmainscreen(formated, context);
        setState(() {
          newisloading = false;
          selectionMode = false;
        });
      } else if (valuewert == 'Mieterhöhung') {
        ServerHandler server = ServerHandler(
            Request: '/create_user_specific_tenantincrease', sendData: body);
        await server.createErhohungallmainscreen(formated, context);
        setState(() {
          newisloading = false;
          selectionMode = false;
        });
      } else {
        print('eror');
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Column(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: icolor.red,
                      size: 30,
                    ),
                    Text("Error")
                  ],
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: TextEditingController(),
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey.shade600),
                          hintText: "Search everything",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Calendar Icon
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: Colors.grey.shade700,
                  ),

                  // Notifications Icon
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_outlined),
                    color: Colors.grey.shade700,
                  ),

                  // Profile Avatar
                  const SizedBox(width: 8),
                  // const CircleAvatar(
                  //   radius: 18,
                  //   backgroundImage:
                  //       AssetImage('assets/images/profile.jpg'), // Update path
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Dashboard Content Placeholder
            FutureBuilder<UserData>(
              future: _futureload,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: icolor.teal,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  userdata = snapshot.data!;
                  return FutureBuilder<List<Objects>>(
                    future: _futureProperties,
                    builder: (context, AsyncSnapshot<List<Objects>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: icolor.teal,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No properties found.'));
                      } else {
                        _properties = snapshot.data!;

                        print(_tenants);
                        print(_properties_mehr);
                        print(_properties_etag);
                        print('An${_leer.length}');

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Column(
                                children: [
                                  Container(
                                    color: icolor.blue,
                                    child: TabBar(
                                      controller: _tabController,
                                      onTap: (value) {},
                                      tabs: [
                                        Column(
                                          children: [
                                            const Tab(text: 'MFH'),
                                            Text(
                                              "${_properties_mehr.length}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Tab(text: "ETW"),
                                            Text(
                                              "${_properties_etag.length}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Tab(text: "Mieter"),
                                            Text(
                                              "${_tenants.length}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Tab(text: "Leer"),
                                            Text(
                                              "${_properties_mehr.length}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                      ],
                                      labelColor: icolor.gray,
                                      labelStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelColor: Colors.grey,
                                      indicatorColor: icolor.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Hello",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 2, 11, 19),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "This is what we've got for you today",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // Dashboard Cards
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _dashboardCard(
                                                    "Rent received"),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _dashboardCard(
                                                    "Unpaid expenses"),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _dashboardCard(
                                                    "Overdue rent"),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _dashboardCard(
                                                    "Upcoming expenses"),
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
                            // Toggle Button in Bottom Center
                          ],
                        );
                      }
                    },
                  );
                } else {
                  return const Center(child: Text('No user data found.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard card widget
  Widget _dashboardCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(),
      ],
    );
  }

  Widget _buildPropertyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _properties_etag.isEmpty
              ? _buildEmptyState()
              : filteredProperties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined,
                              size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Keine Objekte gefunden.',
                            style: TextStyle(fontSize: 18, color: icolor.gray),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, index) {
                        final property = filteredProperties[index];

                        final address =
                            "${property.street} ${property.houseNumber}";
                        final city =
                            "${property.postalCode ?? ""} ${property.city ?? ""}";

                        final isSelected = selectedUnitObject.any(
                            (item) => item["objectid"] == property.objectId);

                        return Card(
                          elevation: 0.3,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                  width: 1.4,
                                  color: const Color.fromARGB(
                                      255, 179, 179, 179))),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {},
                            child: Row(
                              children: [
                                // Linke Fläche: Haus-Icon oder Toggle-Kreis abhängig vom selectionMode
                                selectionMode
                                    ? GestureDetector(
                                        onTap: () {
                                          toggleCardSelection(
                                              property.objectId!);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey, width: 2),
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check,
                                                  size: 20, color: Colors.white)
                                              : null,
                                        ),
                                      )
                                    : Container(
                                        width: 48,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                                  255, 54, 248, 225)
                                              .withOpacity(0.3),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            bottomLeft: Radius.circular(24),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(Icons.house_rounded,
                                              color: icolor.teal, size: 28),
                                        ),
                                      ),

                                // Restlicher Inhalt der Karte
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              address,
                                              style: const TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              width: 100,
                                              child: FutureBuilder(
                                                future: loadgesamt(property
                                                    .objectId
                                                    .toString()),
                                                builder: (context,
                                                    AsyncSnapshot<int>
                                                        snapshot) {
                                                  int? bodydata = snapshot.data;
                                                  bool minuss = false;
                                                  if (bodydata != null &&
                                                      bodydata < 0) {
                                                    minuss = true;
                                                  }
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            Text("Rechnet..."));
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Container();
                                                  } else if (!snapshot
                                                          .hasData ||
                                                      snapshot.data == 0) {
                                                    return Container();
                                                  } else {
                                                    return Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: minuss
                                                            ? const Color
                                                                .fromARGB(255,
                                                                255, 221, 219)
                                                            : const Color
                                                                .fromARGB(255,
                                                                227, 255, 249),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        "${bodydata.toString()}€",
                                                        style: TextStyle(
                                                          color: minuss
                                                              ? Colors.red
                                                              : icolor.teal,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          city,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.apartment_outlined,
                                                size: 18,
                                                color: Colors.blue[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${property.units?.length ?? 0} Einheiten",
                                              style: const TextStyle(
                                                fontFamily: 'RobotoMono',
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.check_box,
                                                size: 18, color: icolor.teal),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${property.units?.where((u) => u.isOccupied == true).length ?? 0} belegt",
                                              style: const TextStyle(
                                                fontFamily: 'RobotoMono',
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.check_box_outline_blank,
                                                size: 18,
                                                color: Colors.red[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${property.units?.where((u) => u.isOccupied == false).length ?? 0} frei",
                                              style: const TextStyle(
                                                fontFamily: 'RobotoMono',
                                                fontSize: 13,
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
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPropertymehrList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: _properties_mehr.isEmpty
                ? _buildEmptyState()
                : filteredProperties_mehr.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_work_outlined,
                                size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Keine Objekte gefunden.',
                              style:
                                  TextStyle(fontSize: 18, color: icolor.gray),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        itemCount: filteredProperties_mehr.length,
                        itemBuilder: (context, index) {
                          final property = filteredProperties_mehr[index];

                          final address =
                              "${property.street} ${property.houseNumber}";
                          final city =
                              "${property.postalCode ?? ""} ${property.city ?? ""}";

                          final isSelected = selectedUnitObjectMehr.any(
                              (item) => item["objectid"] == property.objectId);

                          return Card(
                            elevation: 0.3,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide(
                                    width: 1.4,
                                    color: const Color.fromARGB(
                                        255, 179, 179, 179))),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {},
                              child: Row(
                                children: [
                                  // Linke Fläche: Haus-Icon oder Toggle-Kreis abhängig vom selectionMode
                                  selectionModeMehr
                                      ? GestureDetector(
                                          onTap: () {
                                            toggleCardSelectionMehr(
                                                property.objectId!);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey, width: 2),
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check,
                                                    size: 20,
                                                    color: Colors.white)
                                                : null,
                                          ),
                                        )
                                      : Container(
                                          width: 48,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                    255, 54, 248, 225)
                                                .withOpacity(0.3),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              bottomLeft: Radius.circular(24),
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(Icons.house_rounded,
                                                color: icolor.teal, size: 28),
                                          ),
                                        ),

                                  // Restlicher Inhalt der Karte
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                address,
                                                style: const TextStyle(
                                                  fontSize: 16.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                height: 30,
                                                width: 100,
                                                child: FutureBuilder(
                                                  future: loadgesamt(property
                                                      .objectId
                                                      .toString()),
                                                  builder: (context,
                                                      AsyncSnapshot<int>
                                                          snapshot) {
                                                    int? bodydata =
                                                        snapshot.data;
                                                    bool minuss = false;
                                                    if (bodydata != null &&
                                                        bodydata < 0) {
                                                      minuss = true;
                                                    }
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child: Text(
                                                              "Rechnet..."));
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Container();
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        snapshot.data == 0) {
                                                      return Container();
                                                    } else {
                                                      return Container(
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: minuss
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  255, 221, 219)
                                                              : const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  227,
                                                                  255,
                                                                  249),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          "${bodydata.toString()}€",
                                                          style: TextStyle(
                                                            color: minuss
                                                                ? Colors.red
                                                                : icolor.teal,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            city,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.apartment_outlined,
                                                  size: 18,
                                                  color: Colors.blue[600]),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${property.units?.length ?? 0} Einheiten",
                                                style: const TextStyle(
                                                  fontFamily: 'RobotoMono',
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(Icons.check_box,
                                                  size: 18, color: icolor.teal),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${property.units?.where((u) => u.isOccupied == true).length ?? 0} belegt",
                                                style: const TextStyle(
                                                  fontFamily: 'RobotoMono',
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                  Icons.check_box_outline_blank,
                                                  size: 18,
                                                  color: Colors.red[600]),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${property.units?.where((u) => u.isOccupied == false).length ?? 0} frei",
                                                style: const TextStyle(
                                                  fontFamily: 'RobotoMono',
                                                  fontSize: 13,
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
                        },
                      ))
      ],
    );
  }

  Widget _buildTenantList() {
    return Column(
      children: [
        Expanded(
          child: _tenants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Keinen Mieter gefunden.',
                        style: TextStyle(fontSize: 18, color: icolor.gray),
                      ),
                    ],
                  ),
                )
              : filteredTenants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Keinen Mieter gefunden.',
                            style: TextStyle(fontSize: 18, color: icolor.gray),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredTenants.length,
                      itemBuilder: (context, index) {
                        final tenant = filteredTenants[index];
                        Units? matchedUnit;
                        Objects? matchedObject;

                        for (final obj in _properties) {
                          final foundUnit = obj.units?.firstWhere(
                            (u) => u.unitId == tenant.unitId,
                            orElse: () => Units(),
                          );
                          print(foundUnit!.toJson());

                          if (foundUnit != null && foundUnit.unitId != null) {
                            matchedUnit = foundUnit;
                            matchedObject = obj;
                            break;
                          }
                        }
                        print(matchedObject);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          color: Colors.white,
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {},
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor:
                                            icolor.blue.withOpacity(0.2),
                                        child: Icon(Icons.person,
                                            size: 28, color: icolor.blue),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1. vollständiger Name
                                            Text(
                                              '${tenant.name ?? ""} ${tenant.surname ?? ""} ',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4),

                                            // 2. Adresse + Etage (grey small)
                                            Text(
                                              '${matchedObject?.street ?? "-"} ${matchedObject?.houseNumber ?? ""} · Etage ${matchedUnit?.floor ?? "-"}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),

                                            SizedBox(height: 12),

                                            // 3. Zahlung und Fälligkeitsdatum
                                            Row(
                                              children: [
                                                Icon(Icons.payment,
                                                    color: Colors.grey[700],
                                                    size: 18),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Miete: ${tenant.rentWithUtilities ?? tenant.rentAmount ?? "-"} €',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  getDueText(int.parse(tenant
                                                      .rentDueDay
                                                      .toString())),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 4. Nachrichtensymbol oben rechts
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(Icons.message_outlined,
                                        color: icolor.teal),
                                    tooltip: "Updates anzeigen",
                                    onPressed: () {
                                      // Logik für Nachrichten oder Updates
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String getDueText(int? rentDueDay) {
    if (rentDueDay == null) {
      return 'Fällig am: -';
    }

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // Das Fälligkeitsdatum im aktuellen Monat und Jahr
    final dueDate = DateTime(currentYear, currentMonth, rentDueDay);

    // Monatsname auf Deutsch
    final monthName = DateFormat.MMMM('de_DE').format(dueDate);

    if (dueDate.isBefore(now)) {
      return 'War fällig am: $rentDueDay. $monthName';
    } else {
      return 'Fällig am: $rentDueDay. $monthName';
    }
  }
}
