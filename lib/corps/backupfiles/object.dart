class Objects {
  String? objectId;
  String? userId;
  String? objecttype;
  String? street;
  String? houseNumber;
  String? zip;
  String? city;
  String? garden;
  String? parking;
  String? heatingType;
  String? numberOfRooms;
  String? squareMeters;
  String? yearBuilt;
  String? bathroom;
  String? balcony;
  String? floor;
  String? apartmentNumber;
  String? isOccupied;
  String? isCommercialUnit;

  List<Tenants>? tenants;

  Objects({
    this.objectId,
    this.userId,
    this.objecttype,
    this.street,
    this.houseNumber,
    this.zip,
    this.city,
    this.garden,
    this.parking,
    this.heatingType,
    this.numberOfRooms,
    this.squareMeters,
    this.yearBuilt,
    this.bathroom,
    this.balcony,
    this.floor,
    this.apartmentNumber,
    this.isOccupied,
    this.isCommercialUnit,
    this.tenants,
  });

  factory Objects.fromJson(Map<String, dynamic> json) {
    return Objects(
      objectId: json['objectId']?.toString(),
      userId: json['userId']?.toString(),
      objecttype: json['objecttype']?.toString(),
      street: json['street']?.toString(),
      houseNumber: json['houseNumber']?.toString(),
      zip: json['zip']?.toString(),
      city: json['city']?.toString(),
      garden: json['garden']?.toString(),
      parking: json['parking']?.toString(),
      heatingType: json['heatingType']?.toString(),
      numberOfRooms: json['numberOfRooms']?.toString(),
      squareMeters: json['squareMeters']?.toString(),
      yearBuilt: json['yearBuilt']?.toString(),
      bathroom: json['bathroom']?.toString(),
      balcony: json['balcony']?.toString(),
      floor: json['floor']?.toString(),
      apartmentNumber: json['apartmentNumber']?.toString(),
      isOccupied: json['isOccupied']?.toString(),
      isCommercialUnit: json['isCommercialUnit']?.toString(),
      tenants: json['tenants'] != null
          ? (json['tenants'] as List).map((e) => Tenants.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'userId': userId,
      'objecttype': objecttype,
      'street': street,
      'houseNumber': houseNumber,
      'zip': zip,
      'city': city,
      'garden': garden,
      'parking': parking,
      'heatingType': heatingType,
      'numberOfRooms': numberOfRooms,
      'squareMeters': squareMeters,
      'yearBuilt': yearBuilt,
      'bathroom': bathroom,
      'balcony': balcony,
      'floor': floor,
      'apartmentNumber': apartmentNumber,
      'isOccupied': isOccupied,
      'isCommercialUnit': isCommercialUnit,
      'tenants': tenants?.map((e) => e.toJson()).toList(),
    };
  }

  String getHausTyp(List<Objects> objectsn) {
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
}

class Tenants {
  String? tenantId;
  String? name;
  String? surname;
  String? level;
  String? birthday;
  String? nationality;
  String? married;
  String? pets;
  String? rent;

  Tenants({
    this.tenantId,
    this.name,
    this.surname,
    this.level,
    this.birthday,
    this.nationality,
    this.married,
    this.pets,
    this.rent,
  });

  factory Tenants.fromJson(Map<String, dynamic> json) {
    return Tenants(
      tenantId: json['tenantId'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
      birthday: json['birthday'],
      nationality: json['nationality'],
      married: json['married'],
      pets: json['pets'],
      rent: json['rent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'name': name,
      'surname': surname,
      'level': level,
      'birthday': birthday,
      'nationality': nationality,
      'married': married,
      'pets': pets,
      'rent': rent,
    };
  }
}
