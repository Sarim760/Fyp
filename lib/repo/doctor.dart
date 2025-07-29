import 'package:dio/dio.dart';

import '../helper/global_variables.dart';
import '../model/doctor.dart';

class DoctorRepo {

   static Future<List<Doctor_Model>> getAllDoctors() async {
    final res = await Dio().get(
      '${GlobalVariables().apiString}/doctors/',
    );
    return (res.data as List).map((e) => Doctor_Model.fromJson(e)).toList();
  }
}