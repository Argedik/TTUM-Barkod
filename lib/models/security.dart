class Security{
  int? id;
  int? imei;
  String? bluetooth_printer;
  int? confirmation;
  Security({
   this.id,
   this.imei,
   this.bluetooth_printer,
   this.confirmation,
});
  Security.fromJson(Map<String, dynamic> json){
    id= json["id"];
    imei= json["imei"];
    bluetooth_printer= json["bluetooth_printer"];
    confirmation= json["confirmation"];
  }
  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"]= this.id;
    data["imei"]= this.imei;
    data["bluetooth_printer"]= this.bluetooth_printer;
    data["confirmation"]= this.confirmation;
      return data;
  }
}