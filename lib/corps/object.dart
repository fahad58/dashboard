class Objects {
  String? objectId;
  String? objectType;
  String? street;
  String? houseNumber;
  String? postalCode;
  String? city;

  List<Units>? units;

  Objects({
    this.objectId,
    this.objectType,
    this.street,
    this.houseNumber,
    this.postalCode,
    this.city,
    this.units,
  });

  factory Objects.fromJson(Map<String, dynamic> json) {
    return Objects(
      objectId: json['object_id']?.toString(),
      objectType: json['object_type']?.toString(),
      street: json['street']?.toString(),
      houseNumber: json['house_number']?.toString(),
      postalCode: json['postal_code']?.toString(),
      city: json['city']?.toString(),
      units: json['units'] != null
          ? (json['units'] as List).map((e) => Units.fromJson(e)).toList()
          : [],
    );
  }

  String getHausTyp(List<Units> objectsn) {
    switch (objectsn.length) {
      case 1:
        return "Einfamilienhaus";
      case 2:
        return "Zweifamilienhaus";
      case 3:
        return "Dreifamilienhaus";
      default:
        return "${objectsn.length}-Familienhaus";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'object_id': objectId,
      'object_type': objectType,
      'street': street,
      'house_number': houseNumber,
      'postal_code': postalCode,
      'city': city,
      'units': units?.map((e) => e.toJson()).toList(),
    };
  }
}

class Abrechnungs {
  String? abrechnungId;
  String? objectId;
  int? year;
  Map<String, dynamic>? kosten;

  Abrechnungs({
    this.abrechnungId,
    this.objectId,
    this.year,
    this.kosten,
  });

  factory Abrechnungs.fromJson(Map<String, dynamic> json) {
    return Abrechnungs(
      abrechnungId: json['abrechnung_id']?.toString(),
      objectId: json['objectid']?.toString(),
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? ''),
      kosten: json['kosten'] != null
          ? Map<String, dynamic>.from(json['kosten'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'abrechnung_id': abrechnungId,
      'objectid': objectId,
      'year': year,
      'kosten': kosten,
    };
  }
}

class Units {
  String? unitId;
  String? numberOfRooms;
  String? squareMeters;
  String? yearBuilt;
  String? bathroom;
  String? balcony;
  String? garden;
  String? parking;
  String? heatingType;
  String? floor;
  String? apartmentNumber;
  String? isOccupied;
  String? isCommercialUnit;

  List<Tenants>? tenants;

  Units({
    this.unitId,
    this.numberOfRooms,
    this.squareMeters,
    this.yearBuilt,
    this.bathroom,
    this.balcony,
    this.garden,
    this.parking,
    this.heatingType,
    this.floor,
    this.apartmentNumber,
    this.isOccupied,
    this.isCommercialUnit,
    this.tenants,
  });

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
      unitId: json['unit_id']?.toString(),
      numberOfRooms: json['number_of_rooms']?.toString(),
      squareMeters: json['square_meters']?.toString(),
      yearBuilt: json['year_built']?.toString(),
      bathroom: json['bathroom']?.toString(),
      balcony: json['balcony']?.toString(),
      garden: json['garden']?.toString(),
      parking: json['parking']?.toString(),
      heatingType: json['heating_type']?.toString(),
      floor: json['floor']?.toString(),
      apartmentNumber: json['apartment_number']?.toString(),
      isOccupied: json['is_occupied']?.toString(),
      isCommercialUnit: json['is_commercial_unit']?.toString(),
      tenants: json['tenants'] != null
          ? (json['tenants'] as List).map((e) => Tenants.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'number_of_rooms': numberOfRooms,
      'square_meters': squareMeters,
      'year_built': yearBuilt,
      'bathroom': bathroom,
      'balcony': balcony,
      'garden': garden,
      'parking': parking,
      'heating_type': heatingType,
      'floor': floor,
      'apartment_number': apartmentNumber,
      'is_occupied': isOccupied,
      'is_commercial_unit': isCommercialUnit,
      'tenants': tenants?.map((e) => e.toJson()).toList(),
    };
  }
}

class Tenants {
  String? tenantId;
  String? unitId;
  String? unitNumber;
  String? surname;
  String? name;
  String? email;
  String? phone;
  String? isMarried;
  String? idNumber;
  String? contractStart;
  String? contractEnd;
  String? rentAmount;
  String? rentWithUtilities;
  String? costOfUtilities;
  String? depositAmount;
  String? rentDueDay;
  String? lastRentIncrease;
  String? isActive;
  String? geschlecht;
  String? personenAnzahl;
  RentIncrease? rentIncrease;

  Tenants(
      {this.tenantId,
      this.unitId,
      this.unitNumber,
      this.surname,
      this.name,
      this.email,
      this.phone,
      this.isMarried,
      this.idNumber,
      this.contractStart,
      this.contractEnd,
      this.rentAmount,
      this.rentWithUtilities,
      this.costOfUtilities,
      this.depositAmount,
      this.rentDueDay,
      this.lastRentIncrease,
      this.isActive,
      this.geschlecht,
      this.personenAnzahl,
      this.rentIncrease});

  factory Tenants.fromJson(Map<String, dynamic> json) {
    return Tenants(
        tenantId: json['tenant_id']?.toString(),
        unitId: json['unit_id']?.toString(),
        unitNumber: json['unit_number']?.toString(),
        surname: json['surname']?.toString(),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        isMarried: json['is_married']?.toString(),
        idNumber: json['id_number']?.toString(),
        contractStart: json['contract_start']?.toString(),
        contractEnd: json['contract_end']?.toString(),
        rentAmount: json['rent_amount']?.toString(),
        rentWithUtilities: json['rent_with_utilities']?.toString(),
        costOfUtilities: json['cost_of_utilities']?.toString(),
        depositAmount: json['deposit_amount']?.toString(),
        rentDueDay: json['rent_due_day']?.toString(),
        lastRentIncrease:
            json['lastRlast_rent_increaseentIncrease']?.toString(),
        isActive: json['is_Active']?.toString(),
        geschlecht: json['geschlecht']?.toString(),
        personenAnzahl: json['personenAnzahl']?.toString(),
        rentIncrease: json['rent_increase'] != null
            ? RentIncrease.fromJson(json['rent_increase'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'unit_id': unitId,
      'unit_number': unitNumber,
      'surname': surname,
      'name': name,
      'email': email,
      'phone': phone,
      'is_married': isMarried,
      'id_number': idNumber,
      'contract_start': contractStart,
      'contract_end': contractEnd,
      'rent_amount': rentAmount,
      'rent_with_utilities': rentWithUtilities,
      'cost_of_utilities': costOfUtilities,
      'deposit_amount': depositAmount,
      'rent_due_day': rentDueDay,
      'last_rent_increase': lastRentIncrease,
      'is_Active': isActive,
      'geschlecht': geschlecht,
      'personenAnzahl': personenAnzahl,
      'rent_increase': rentIncrease?.toJson(),
    };
  }
}

class RentIncrease {
  String? tenantId;
  String? oldRent;
  String? newRent1;
  String? newRent2;
  String? effectiveDate1;
  String? effectiveDate2;
  String? dateToSendOut1;
  String? dateToSendOut2;
  String? confirm;
  String? noNotification;
  bool? immediate;
  bool? garden;
  bool? automatic;

  RentIncrease(
      {this.tenantId,
      this.oldRent,
      this.newRent1,
      this.newRent2,
      this.effectiveDate1,
      this.effectiveDate2,
      this.dateToSendOut1,
      this.dateToSendOut2,
      this.confirm,
      this.noNotification,
      this.garden,
      this.automatic,
      this.immediate});

  factory RentIncrease.fromJson(Map<String, dynamic> json) {
    return RentIncrease(
      tenantId: json['tenant_id']?.toString(),
      oldRent: json['old_rent']?.toString(),
      newRent1: json['new_rent_1']?.toString(),
      newRent2: json['new_rent_2']?.toString(),
      effectiveDate1: json['effective_date_1']?.toString(),
      effectiveDate2: json['effective_date_2']?.toString(),
      dateToSendOut1: json['date_to_send_out_1']?.toString(),
      dateToSendOut2: json['date_to_send_out_2']?.toString(),
      confirm: json['confirm']?.toString(),
      noNotification: json['no_notification']?.toString(),
      immediate: json['immediate']?.toString() == 'true' ? true : false,
      automatic: json['automatic']?.toString() == 'true' ? true : false,
      garden: json['garden']?.toString() == 'true' ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'old_rent': oldRent,
      'new_rent_1': newRent1,
      'new_rent_2': newRent2,
      'effective_date_1': effectiveDate1,
      'effective_date_2': effectiveDate2,
      'date_to_send_out_1': dateToSendOut1,
      'date_to_send_out_2': dateToSendOut2,
      'confirm': confirm,
      'no_notification': noNotification,
      'garden': garden,
      'automatic': automatic,
      'immediate': immediate,
    };
  }
}
