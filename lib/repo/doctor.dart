import 'package:dio/dio.dart';

import '../helper/Global_variables.dart';
import '../model/doctor.dart';

class DoctorRepo {

   static Future<List<Doctor_model>> getAllDoctors() async {
    final res = await Dio().get(
      '${globalvariables().apiString}/doctors/',
    );
    return (res.data as List).map((e) => Doctor_model.fromJson(e)).toList();
  }
}