import 'package:dashboard_ui/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_ui/corps/object.dart';
import 'package:dashboard_ui/corps/userinterface.dart';
import 'package:dashboard_ui/const/immocolors.dart';
import 'package:dashboard_ui/server/apiconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String kGoogleApiKey = "AIzaSyDtkobiOYUM6siPJZSrTATgadHKxohxrLU";

class AddPropertyScreen extends StatefulWidget {
  bool? inherited;
  AddPropertyScreen({super.key, this.inherited});

  @override
  AddPropertyScreenState createState() =>
      AddPropertyScreenState(inherited: inherited);
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool? inherited;
  AddPropertyScreenState({this.inherited});
  bool _isSingle = false;
  bool _isMultiple = false;
  List<Units>? objectsc;
  Objects? object;
  bool _continue_afteradress = false;
  bool _neuehinzufugen = false;
  bool _continue_after_zusatz = false;

  // Form fields
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _builtYearController = TextEditingController();
  DateTime? buildYear;
  int? buildYearf;
  final _totalFloorsController = TextEditingController();
  final _roomsController = TextEditingController();
  final _rentController = TextEditingController();
  final _levelsController = TextEditingController();
  final _unitsPerLevelController = TextEditingController();
  final _energyRatingController = TextEditingController();
  final _notesController = TextEditingController();
  final _squaremeter = TextEditingController();

  //

  // TENANT SECTION

  final _tenantnameController = TextEditingController();
  final _tenantsurnamenameController = TextEditingController();
  final _tenantemailController = TextEditingController();
  final _tenantcontactController = TextEditingController();
  final _tenantnationalityController = TextEditingController();
  final _tenantidNumberController = TextEditingController();
  final _tenantrentAmountController = TextEditingController();
  final _tenantwarmrentAmountController = TextEditingController();
  final _tenantrentwithutensilsController = TextEditingController();
  final _tenantdepositAmountController = TextEditingController();
  final _tenantrentDueDayController = TextEditingController();
  final _tenantlevelController = TextEditingController();
  final _tenantunitController = TextEditingController();
  final _tenantcompanyController = TextEditingController();
  DateTime? _birthdate;
  DateTime? _contractStart;
  DateTime? _contractEnd;
  DateTime? _lastRent;
  bool _isMarried = false;
  bool _hasPets = false;
  bool _hasbalkon = false;
  bool _hasbad = false;
  bool _isActive = true;
  bool abschliessen = false;
  bool mietercomplete = false;
  bool _isnotScan = false;

  bool _isActive_rentPaid = false;
  int selectedUnitIndex = 0;
  //

  bool _hasGarden = false;
  bool _hasParking = false;
  bool _hasElevator = false;
  bool? _isactive_bes = false;
  bool zwischenstep = false;

  //tenantcontine
  bool _tenantcontinue = false;
  bool _tenantcontinue_aftercontract = false;

  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _selectYear(BuildContext context) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Wähle das Baujahr'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1750),
              lastDate: DateTime.now(),
              selectedDate: buildYear ?? DateTime.now(),
              onChanged: (DateTime dateTime) {
                setState(() {
                  buildYearf = dateTime.year;
                  buildYear = dateTime;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  bool isLoading = false;

  String _heatingType = 'Fernwärme';

  final List<String> _heatingOptions = [
    'Gasetagenheizung',
    'Fernwärme',
    'Zentralheizung'
  ];
  String _flooramount = 'Erdgeschoß';
  bool _islocal = false;
  @override
  void initState() {
    super.initState();
    objectsc = []; // ← Initialisiere es als leere Liste
  }

  String _roomamount = '1';
  final List<String> _roomoptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  String _personenamount = '1';
  final List<String> _personenoption = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  String _geschlechtamount = 'Herr';
  final List<String> _geschlechterOption = ['Herr', "Frau"];

  final List<String> _flooroptions = [
    "Erdgeschoß",
    '1. OG',
    '2. OG ',
    '3. OG ',
    '4. OG ',
    '5. OG ',
    '6. OG ',
    '7. OG ',
    '8. OG ',
    '9. OG ',
    '10. OG ',
    '11. OG ',
    '12. OG ',
    '13. OG ',
    '14. OG ',
    '15. OG ',
    '16. OG ',
    '17. OG ',
    '18. OG ',
    '19. OG ',
    '20. OG '
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _tenantsurnamenameController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _builtYearController.dispose();
    _totalFloorsController.dispose();
    _roomsController.dispose();
    _rentController.dispose();
    _levelsController.dispose();
    _tenantcompanyController.dispose();
    _unitsPerLevelController.dispose();
    _energyRatingController.dispose();
    _notesController.dispose();
    _squaremeter.dispose();
    _tenantnameController.dispose();
    _tenantemailController.dispose();
    _tenantcontactController.dispose();
    _tenantnationalityController.dispose();
    _tenantidNumberController.dispose();
    _tenantrentwithutensilsController.dispose();
    _tenantrentAmountController.dispose();
    _tenantwarmrentAmountController.dispose();
    _tenantdepositAmountController.dispose();
    _tenantrentDueDayController.dispose();
    _tenantlevelController.dispose();
    _tenantunitController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Map<int, bool> isLeerstandMap = {};
  Map<int, bool> isVermietetMap = {};
  bool isleerstandn = false;
  bool isvermietern = false;

  // tempoary
  String temporary = '';
  bool addsvermieter = false;
  //for search bar
  List<Map<String, String>> _suggestions = [];
  void _searchPlace(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&language=de&components=country:de';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];

      setState(() {
        _suggestions = predictions
            .map<Map<String, String>>((p) => {
                  'description': p['description'],
                  'place_id': p['place_id'],
                })
            .toList();
      });
    } else {
      print("Autocomplete Fehler: ${response.body}");
    }
  }

  Future<void> _getAddressDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey&language=de';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final components = data['result']['address_components'] as List;

      for (var component in components) {
        final types = component['types'] as List;

        if (types.contains('route')) {
          _streetController.text = component['long_name'];
        } else if (types.contains('street_number')) {
          _houseNumberController.text = component['long_name'];
        } else if (types.contains('locality')) {
          _cityController.text = component['long_name'];
        } else if (types.contains('postal_code')) {
          _postalCodeController.text = component['long_name'];
        }
      }
    } else {
      print("Details Fehler: ${response.body}");
    }
  }

  void _onSuggestionTap(String description, String placeId) async {
    setState(() {
      _streetController.text = description;
      _suggestions = [];
    });

    await _getAddressDetails(placeId);
  }

  @override
  Widget build(BuildContext context) {
    print(inherited);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Immobilie hinzufügen',
          style: TextStyle(color: Colors.black),
        ),
        leading: inherited != null && inherited == true
            ? Container()
            : IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Container(
        child: ListView(
          children: [
            Column(
              children: [
                if (objectsc != null &&
                    objectsc!.isNotEmpty &&
                    abschliessen == false &&
                    zwischenstep == false)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${_streetController.text}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            if (_isSingle)
                              Text(Objects().getHausTyp(objectsc!)),
                            if (_isMultiple) Text('Etagenwohnungen')
                          ],
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Schon Eingetragen",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            )),
                        SizedBox(
                          height: 7,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: objectsc!.map((unit) {
                            //unit
                            print(unit);
                            final address = [
                              object?.street?.trim(),
                              object?.houseNumber?.trim()
                            ]
                                .where(
                                    (part) => part != null && part.isNotEmpty)
                                .join(' ');

                            final city = object?.city?.trim() ?? '';

                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: icolor.teal, width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          Icons.home,
                                          color: icolor.teal,
                                        ),
                                        title: Text(
                                          "${unit.floor} ${unit.apartmentNumber}, ${unit.squareMeters}qm, ${unit.numberOfRooms} Zimmer",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                )
                              ],
                            );
                          }).toList(),
                        ),
                        // Add the scan document button after the list
                      ],
                    ),
                  ),
                // if (_isnotScan == false)
                //   Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 12),
                //         child: Text(
                //           "Sie können Ihre Objekte automatisch erfassen. "
                //           "Sie scannen einfach ein Dokument – wir lesen die Daten für Sie aus.",
                //           style: TextStyle(fontSize: 16),
                //         ),
                //       ),
                //       Padding(
                //         padding: EdgeInsets.all(12),
                //         child: Container(
                //           decoration: BoxDecoration(
                //             color: Colors.blue.shade50,
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           padding: EdgeInsets.all(12),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "⚠️ Hinweis",
                //                 style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 16,
                //                     color: Colors.blue.shade900),
                //               ),
                //               SizedBox(height: 8),
                //               Text(
                //                 "• Pro Scan kann nur eine Wohneinheit mit einem Mieter an einer Adresse hinzugefügt werden.\n"
                //                 "• Für weitere Einheiten an derselben Adresse müssen die Schritte erneut durchgeführt werden.\n",
                //                 style: TextStyle(fontSize: 15),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       Center(
                //         child: Container(
                //           height: 45,
                //           width: 260,
                //           margin: EdgeInsets.only(bottom: 24),
                //           child: ElevatedButton(
                //             onPressed: () => _scanAndSendDocuments(),
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: icolor.blue,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //             ),
                //             child: const Text(
                //               'Dokumente einscannen',
                //               style:
                //                   TextStyle(fontSize: 16, color: Colors.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //       Center(
                //         child: Container(
                //           height: 45,
                //           width: 260,
                //           margin: EdgeInsets.only(bottom: 24),
                //           child: ElevatedButton(
                //             onPressed: () {
                //               setState(() {
                //                 _isnotScan = true;
                //               });
                //             },
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: icolor.blue,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //             ),
                //             child: const Text(
                //               'Ohne Scan fortsetzen',
                //               style:
                //                   TextStyle(fontSize: 16, color: Colors.white),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                if (objectsc!.isEmpty) _buildTypeCard(),
                Container(
                  child: Column(
                    children: [
                      if (_isSingle &&
                              _continue_afteradress == false &&
                              _continue_after_zusatz == false &&
                              objectsc!.isEmpty ||
                          _isMultiple &&
                              _continue_afteradress == false &&
                              _continue_after_zusatz == false &&
                              objectsc!.isEmpty)
                        _buildAddressCard(),
                      if (_continue_afteradress &&
                              _continue_after_zusatz == false &&
                              abschliessen == false ||
                          _neuehinzufugen &&
                              objectsc!.isNotEmpty &&
                              abschliessen == false)
                        _buildBasicInfoCard(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard() {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Immobilientyp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _buildTypeSelectionCard(
                title: 'Etagen Wohnung',
                icon: Icons.apartment,
                isSelected: _isMultiple,
                onTap: () {
                  print('touch');
                  if (_isMultiple && _isSingle == false) {
                    print('go');
                    setState(() {
                      _isMultiple = false;
                      _isSingle = false;
                    });
                  } else {
                    print('no');
                    setState(() {
                      _isMultiple = true;
                      _isSingle = false;
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTypeSelectionCard(
                title: 'Ein- und Mehrfamilienhaus',
                icon: Icons.home,
                isSelected: _isSingle,
                onTap: () {
                  if (_isSingle && _isMultiple == false) {
                    setState(() {
                      _isSingle = false;
                      _isMultiple = false;
                    });
                  } else {
                    setState(() {
                      _isSingle = true;
                      _isMultiple = false;
                    });
                  }
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          _buildTitle('Adresse'),
          TextField(
            controller: _streetController,
            onChanged: _searchPlace,
            decoration: InputDecoration(
              hintText: 'Adresse',
              hintStyle: TextStyle(color: Colors.black),
              prefixIcon: Icon(
                Icons.location_on,
                color: icolor.teal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: icolor.teal,
                  width: 2.0, // <-- hier dicker gemacht
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: icolor.teal,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: icolor.teal,
                  width: 2.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          ..._suggestions.map((s) => ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: icolor.teal,
                ),
                title: Text(s['description']!),
                onTap: () =>
                    _onSuggestionTap(s['description']!, s['place_id']!),
              )),
          SizedBox(height: 12),
          _buildTextField(
              _houseNumberController, 'Hausnummer', Icons.confirmation_number,
              isNumber: true),
          SizedBox(height: 12),
          _buildTextField(
              _postalCodeController, 'Postleitzahl', Icons.local_post_office),
          SizedBox(height: 12),
          _buildTextField(_cityController, 'Stadt', Icons.location_city),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: icolor.teal, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
                title: Row(
                  children: [
                    Icon(Icons.construction, color: icolor.teal),
                    SizedBox(width: 3),
                    Text(
                      buildYear != null
                          ? 'Baujahr: ${buildYearf.toString()}'
                          : 'Baujahr',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                trailing: Icon(Icons.calendar_today, color: icolor.teal),
                onTap: () => _selectYear(context)),
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            height: 40,
            width: 200,
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(icolor.teal)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Weiter",
                    style: TextStyle(
                        color: icolor.gray, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: icolor.gray,
                  ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _continue_afteradress = true;
                });
              },
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: zwischenstep
            ? Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: objectsc!.map((unit) {
                      //unit
                      print(unit);
                      final address = [
                        object?.street?.trim(),
                        object?.houseNumber?.trim()
                      ]
                          .where((part) => part != null && part.isNotEmpty)
                          .join(' ');

                      final city = object?.city?.trim() ?? '';

                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: icolor.teal, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.home,
                                    color: icolor.teal,
                                  ),
                                  title: Text(
                                    "${unit.floor} ${unit.apartmentNumber}, ${unit.squareMeters}qm, ${unit.numberOfRooms} Zimmer",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                ),
                                if (isvermietern == false &&
                                    isleerstandn == false &&
                                    unit.isOccupied != 'false' &&
                                    unit.isOccupied != 'true')
                                  Row(
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isvermietern = false;
                                              isleerstandn = true;
                                            });
                                          },
                                          child: Text('Leerstand')),
                                      TextButton(
                                        child: Text('Vermietet'),
                                        onPressed: () {
                                          setState(() {
                                            isvermietern = true;
                                            _isactive_bes = true;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                if (isleerstandn &&
                                    unit.isOccupied != 'false' &&
                                    unit.isOccupied != 'true')
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Leerstand",
                                          style: TextStyle(
                                            color: icolor.blue,
                                          )),
                                    ),
                                  ),
                                if (isvermietern == true &&
                                    isleerstandn == false &&
                                    unit.isOccupied != 'false' &&
                                    unit.isOccupied != 'true')
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Vermietet",
                                          style: TextStyle(
                                            color: icolor.blue,
                                          )),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          )
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  if (isvermietern &&
                      _isactive_bes! == true &&
                      _tenantcontinue == false)
                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Mieter Persönliche Angaben',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Anrede',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_3_outlined,
                                  color: icolor.blue,
                                ),
                              ),
                              value: _geschlechtamount,
                              onChanged: (value) =>
                                  setState(() => _geschlechtamount = value!),
                              items: _geschlechterOption
                                  .map((type) => DropdownMenuItem(
                                      value: type, child: Text(type)))
                                  .toList(),
                            ),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(
                                _tenantnameController, 'Vorname', Icons.person),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(_tenantsurnamenameController,
                                'Nachname', Icons.person),
                            SizedBox(height: 12),
                            if (objectsc?[selectedUnitIndex].isCommercialUnit ==
                                'true')
                              Column(
                                children: [
                                  _buildTextFieldTENANT(
                                      _tenantcompanyController,
                                      "Firmenname",
                                      Icons.business),
                                  SizedBox(height: 12),
                                ],
                              ),
                            _buildTextFieldTENANT(_tenantemailController,
                                'E-Mail-Adresse', Icons.email),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(_tenantcontactController,
                                'Telefonnummer', Icons.phone),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(_tenantidNumberController,
                                'Personalausweis-/Passnummer', Icons.badge),
                            SizedBox(height: 12),
                            if (_islocal == false)
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: icolor.blue, width: 2),
                                    borderRadius: BorderRadius.circular(12)),
                                child: SwitchListTile(
                                    activeColor: icolor.blue,
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.family_restroom,
                                          color: icolor.blue,
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text('Verheirated')
                                      ],
                                    ),
                                    value: _isMarried,
                                    onChanged: (val) =>
                                        setState(() => _isMarried = val)),
                              ),
                            SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Anzahl an Personen',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(
                                  Icons.group,
                                  color: icolor.blue,
                                ),
                              ),
                              value: _personenamount,
                              onChanged: (value) =>
                                  setState(() => _personenamount = value!),
                              items: _personenoption
                                  .map((type) => DropdownMenuItem(
                                      value: type, child: Text(type)))
                                  .toList(),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 40,
                              width: 180,
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(icolor.blue)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Weiter",
                                      style: TextStyle(
                                          color: icolor.gray,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: icolor.gray,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _tenantcontinue = true;
                                    _isactive_bes = false;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  if (_tenantcontinue == true)
                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Vertragsdetails',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.gavel,
                                      color: icolor.blue,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                        'Vertragsbeginn: ${_formatDate(_contractStart)}',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                trailing: Icon(Icons.calendar_today,
                                    color: icolor.blue),
                                onTap: () => _selectDate(
                                    context,
                                    _contractStart,
                                    (picked) => setState(
                                        () => _contractStart = picked)),
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel,
                                      color: icolor.blue,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                        'Vertragsende: ${_formatDate(_contractEnd)}',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                trailing: Icon(Icons.calendar_today,
                                    color: icolor.blue),
                                onTap: () => _selectDate(
                                    context,
                                    _contractEnd,
                                    (picked) =>
                                        setState(() => _contractEnd = picked)),
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(_tenantrentAmountController,
                                'Monatliche Kaltmiete (€)', Icons.attach_money),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(
                                _tenantwarmrentAmountController,
                                'Monatliche Nebenkosten (€)',
                                Icons.attach_money),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(
                                _tenantrentwithutensilsController,
                                'Monatliche Warmmiete (€)',
                                Icons.attach_money),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(
                                _tenantdepositAmountController,
                                'Kautionsbetrag (€)',
                                Icons.savings),
                            SizedBox(height: 12),
                            _buildTextFieldTENANT(
                                _tenantrentDueDayController,
                                'Fälligkeitstag der Miete (z. B. 1)',
                                Icons.calendar_view_day),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: icolor.blue, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: SwitchListTile(
                                  activeColor: icolor.blue,
                                  value: _isActive_rentPaid,
                                  title: Text("Miete wurde schon erhöht?"),
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive_rentPaid = value;
                                    });
                                  }),
                            ),
                            SizedBox(height: 16),
                            _isActive_rentPaid
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: icolor.blue, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      title: Text(
                                          'Datum der letzten Mieterhöhung: ${_formatDate(_lastRent)}'),
                                      trailing: const Icon(Icons.calendar_today,
                                          color: icolor.blue),
                                      onTap: () => _selectDate(
                                          context,
                                          _lastRent,
                                          (picked) => setState(
                                              () => _lastRent = picked)),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 150,
                                  child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                icolor.blue)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: icolor.gray,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "Zurück",
                                          style: TextStyle(
                                              color: icolor.gray,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _tenantcontinue_aftercontract = false;
                                        _tenantcontinue = false;
                                        _isactive_bes = true;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Container(
                                  height: 40,
                                  width: 160,
                                  child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                icolor.blue)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Fertig",
                                          style: TextStyle(
                                              color: icolor.gray,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: icolor.gray,
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      final newTenant = Tenants(
                                          name: _tenantnameController.text,
                                          surname:
                                              _tenantsurnamenameController.text,
                                          email: _tenantemailController.text,
                                          phone: _tenantcontactController.text,
                                          idNumber:
                                              _tenantidNumberController.text,
                                          rentAmount:
                                              _tenantrentAmountController.text,
                                          rentWithUtilities:
                                              _tenantrentwithutensilsController
                                                  .text,
                                          depositAmount:
                                              _tenantdepositAmountController
                                                  .text,
                                          costOfUtilities:
                                              _tenantwarmrentAmountController
                                                  .text,
                                          rentDueDay:
                                              _tenantrentDueDayController.text,
                                          isMarried: _isMarried.toString(),
                                          contractStart:
                                              _formatDate(_contractStart),
                                          contractEnd:
                                              _formatDate(_contractEnd),
                                          lastRentIncrease:
                                              _formatDate(_lastRent),
                                          isActive: _isActive.toString(),
                                          geschlecht: _geschlechtamount,
                                          personenAnzahl: _personenamount,
                                          unitNumber:
                                              objectsc![selectedUnitIndex]
                                                  .floor);

                                      setState(() {
                                        print(selectedUnitIndex);
                                        objectsc![selectedUnitIndex].tenants ??=
                                            [];
                                        objectsc![selectedUnitIndex]
                                            .tenants!
                                            .add(newTenant);
                                        objectsc![selectedUnitIndex]
                                            .isOccupied = 'true';

                                        // Controller reset
                                        _tenantnameController.clear();
                                        _tenantsurnamenameController.clear();
                                        _tenantemailController.clear();
                                        _tenantcontactController.clear();
                                        _tenantnationalityController.clear();
                                        _tenantidNumberController.clear();
                                        _tenantrentAmountController.clear();
                                        _tenantwarmrentAmountController.clear();
                                        _tenantdepositAmountController.clear();
                                        _tenantrentDueDayController.clear();
                                        _tenantlevelController.clear();
                                        _tenantunitController.clear();
                                        _tenantcompanyController.clear();

                                        // Date reset
                                        _birthdate = null;
                                        _contractStart = null;
                                        _contractEnd = null;
                                        _lastRent = null;

                                        // Checkbox/booleans reset
                                        _isMarried = false;
                                        _hasPets = false;
                                        _hasbalkon = false;
                                        _hasbad = false;
                                        _isActive = true;
                                        _isActive_rentPaid = false;

                                        // Navigation/Zustand
                                        _tenantcontinue_aftercontract = false;
                                        _tenantcontinue = false;
                                        _isactive_bes = false;
                                        temporary = '';
                                        addsvermieter = false;
                                        mietercomplete = true;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isvermietern == false ||
                      isvermietern == true && mietercomplete == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40,
                              width: 170,
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(icolor.blue)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Nächste Einheit",
                                      style: TextStyle(
                                          color: icolor.gray,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (isleerstandn == true ||
                                      isvermietern == true) {
                                    // Step 2: Create the object (house/building)
                                    objectsc?[selectedUnitIndex].isOccupied =
                                        isleerstandn ? 'false' : 'true';

                                    _levelsController.clear();
                                    _unitsPerLevelController.clear();
                                    _squaremeter.clear();
                                    _hasbalkon = false;
                                    _hasbad = false;
                                    _hasGarden = false;
                                    _hasParking = false;
                                    _hasElevator = false;
                                    _isactive_bes = false;
                                    buildYear = null;
                                    _heatingType = "Fernwärme";
                                    _flooramount = 'Erdgeschoß';
                                    _roomamount = '1';
                                    print(objectsc?[selectedUnitIndex]);
                                    setState(() {
                                      _continue_after_zusatz = false;
                                      _continue_afteradress = false;
                                      selectedUnitIndex = selectedUnitIndex + 1;
                                      _neuehinzufugen = true;
                                      isvermietern = false;
                                      isleerstandn = false;
                                      mietercomplete = false;
                                      _tenantcontinue = false;
                                      zwischenstep = false;
                                    });
                                  } else {
                                    print('wrong');
                                  }
                                },
                              ),
                            ),
                            if (_isSingle)
                              Container(
                                padding: EdgeInsets.only(top: 4),
                                alignment: Alignment.centerLeft,
                                height: 40,
                                width: 170,
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              icolor.blue)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "LaLo hinzufügen",
                                        style: TextStyle(
                                            color: icolor.gray,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    if (isleerstandn == true ||
                                        isvermietern == true) {
                                      // Step 2: Create the object (house/building)
                                      objectsc?[selectedUnitIndex].isOccupied =
                                          isleerstandn ? 'false' : 'true';
                                      objectsc?[selectedUnitIndex]
                                          .isCommercialUnit = 'true';
                                      _levelsController.clear();
                                      _unitsPerLevelController.clear();
                                      _squaremeter.clear();
                                      _hasbalkon = false;
                                      _hasbad = false;
                                      _hasGarden = false;
                                      _hasParking = false;
                                      _hasElevator = false;
                                      _isactive_bes = false;
                                      buildYear = null;
                                      _heatingType = "Fernwärme";
                                      _flooramount = 'Erdgeschoß';
                                      _roomamount = '1';
                                      print(objectsc?[selectedUnitIndex]);
                                      setState(() {
                                        _continue_after_zusatz = false;
                                        _continue_afteradress = false;
                                        isvermietern = false;
                                        mietercomplete = false;
                                        isleerstandn = false;
                                        selectedUnitIndex =
                                            selectedUnitIndex + 1;
                                        _neuehinzufugen = true;
                                        zwischenstep = false;
                                      });
                                    } else {
                                      print('wrong');
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Center(child: Text("oder")),
                        SizedBox(
                          width: 2,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 40,
                          width: 160,
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Text(
                                    "Abschliessen",
                                    style: TextStyle(
                                        color: icolor.gray,
                                        fontWeight: FontWeight.w600),
                                  ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (isleerstandn == true ||
                                        isvermietern == true) {
                                      // Jetzt kannst du das Objekt z.B. speichern oder weitergeben:
                                      print(object!.toJson().toString());
                                      objectsc?[selectedUnitIndex].isOccupied =
                                          isleerstandn ? 'false' : 'true';
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      String token =
                                          prefs.getString('token').toString();
                                      ServerHandler server = ServerHandler(
                                          Request: '/create_full_property',
                                          sendData: {
                                            'token': token,
                                            "property_data": object!.toJson()
                                          });
                                      String response =
                                          await server.uploadObjects();
                                      if (response != 'error') {
                                        showDialog(
                                            context: context,
                                            builder: ((context) => AlertDialog(
                                                  title: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            color: icolor.teal,
                                                          ),
                                                          Text("Erfolgreich")
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )));
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainScreen()),
                                        );
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: ((context) => AlertDialog(
                                                  title: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                          ),
                                                          Text("Fehler")
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )));
                                      }
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  TextButton(
                      onPressed: () {
                        print(object!.toJson().toString());
                      },
                      child: Text("See"))
                ],
              )
            : Column(children: [
                _neuehinzufugen
                    ? Container(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Zusatzinformationen der neuen Einheit",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      )
                    : _buildTitle('Zusätzliche Informationen'),
                DropdownButtonFormField<String>(
                  value: _roomamount,
                  decoration: InputDecoration(
                    labelText: "Anzahl an Zimmer",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(
                      Icons.bed,
                      color: icolor.teal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _roomoptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value + ' Zimmer'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _roomamount = newValue;
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  _squaremeter,
                  'Quadrat Meter',
                  Icons.electric_meter,
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                      activeColor: icolor.teal,
                      title: Row(
                        children: [
                          Icon(
                            Icons.bathroom,
                            color: icolor.teal,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text('Bad'),
                        ],
                      ),
                      value: _hasbad,
                      onChanged: (val) => setState(() => _hasbad = val!)),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                      activeColor: icolor.teal,
                      title: Row(
                        children: [
                          Icon(
                            Icons.balcony,
                            color: icolor.teal,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text('Balkon')
                        ],
                      ),
                      value: _hasbalkon,
                      onChanged: (val) => setState(() => _hasbalkon = val!)),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                      activeColor: icolor.teal,
                      title: Row(
                        children: [
                          Icon(
                            Icons.park,
                            color: icolor.teal,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text('Garten')
                        ],
                      ),
                      value: _hasGarden,
                      onChanged: (val) => setState(() => _hasGarden = val!)),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                      activeColor: icolor.teal,
                      title: Row(
                        children: [
                          Icon(
                            Icons.local_parking,
                            color: icolor.teal,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text('Stellplatz / Garage')
                        ],
                      ),
                      value: _hasParking,
                      onChanged: (val) => setState(() => _hasParking = val!)),
                ),
                SizedBox(
                  height: 12,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Heizungsart',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: icolor.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.fireplace,
                      color: icolor.teal,
                    ),
                  ),
                  value: _heatingType,
                  onChanged: (value) => setState(() => _heatingType = value!),
                  items: _heatingOptions
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _flooramount,
                        decoration: InputDecoration(
                          labelText: "Etage",
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(
                            Icons.layers,
                            color: icolor.teal,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: icolor.teal, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: icolor.teal, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _flooroptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontSize: value == "Erdgeschoß" ? 13 : 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _flooramount = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_tenantunitController, "Wohnung",
                            Icons.meeting_room)),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 40,
                  width: 170,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(icolor.teal)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Fertig",
                          style: TextStyle(
                              color: icolor.gray, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    onPressed: () {
                      final newUnit = Units(
                        unitId: null, // You can use Uuid().v4() if needed
                        numberOfRooms: _roomamount.trim(),
                        squareMeters: _squaremeter.text.trim(),
                        yearBuilt:
                            buildYearf != null ? buildYearf.toString() : null,
                        bathroom: _hasbad ? "true" : "false",
                        balcony: _hasbalkon ? "true" : "false",
                        garden: _hasGarden ? "true" : "false",
                        parking: _hasParking ? "true" : "false",
                        heatingType: _heatingType,
                        floor: _flooramount.trim(),
                        apartmentNumber: _tenantunitController.text.trim(),
                        isOccupied: null,
                        isCommercialUnit: null, // Can be set later if needed
                        tenants: [], // Empty list, ready to be populated
                      );

                      // Step 2: Create the object (house/building)
                      if (objectsc!.isEmpty) {
                        final newObject = Objects(
                          objectId:
                              null, // Optional: Uuid().v4() // e.g., from logged-in user
                          objectType: _isSingle
                              ? "Ein/Mehrfamilienhaus"
                              : (_isMultiple ? "Etagenwohnung" : null),
                          street: _streetController.text.trim(),
                          houseNumber: _houseNumberController.text.trim(),
                          postalCode: _postalCodeController.text.trim(),
                          city: _cityController.text.trim(),
                          units: [newUnit], // Add your unit(s) here
                        );
                        print(newObject.toJson());

                        // Jetzt kannst du das Objekt z.B. speichern oder weitergeben:
                        print(newObject.toJson());
                        setState(() {
                          object = newObject;
                        });
                      } else {
                        setState(() {
                          dynamic unitss = object!.units;
                          unitss.add(newUnit);
                          object!.units = unitss;
                        });
                      }

                      setState(() {
                        _continue_after_zusatz = false;
                        _continue_afteradress = true;
                        objectsc!.add(newUnit);
                        _neuehinzufugen = false;
                        zwischenstep = true;
                      });
                    },
                  ),
                ),
              ]),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          icon,
          color: icolor.teal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.teal,
            width: 2.0, // <-- hier dicker gemacht
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.teal,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.teal,
            width: 2.5,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildTextFieldTENANT(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          icon,
          color: icolor.blue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.blue,
            width: 2.0, // <-- hier dicker gemacht
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.blue,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: icolor.blue,
            width: 2.5,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTypeSelectionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? icolor.teal : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? icolor.teal.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32, color: isSelected ? icolor.teal : Colors.grey[600]),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: isSelected ? icolor.teal : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
