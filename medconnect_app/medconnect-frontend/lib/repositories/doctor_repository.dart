import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_schedule.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class DoctorRepository {
  static const String keySchedule = 'doctor_schedule';
  static const String keyProfile = 'doctor_profile';

  Future<void> saveSchedule(DoctorSchedule schedule) async {
    // 1. Save Locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySchedule, json.encode(schedule.toJson()));
    
    // 2. Sync with Backend
    // Need token. Typically passed or stored. 
    // Assuming we can get token from SharedPreferences 'auth_token' if available, 
    // or passed in. Repository usually doesn't hold token.
    // However, for this fix, let's try to retrieve token from prefs (ApiService usually manages it).
    // Or we update the method signature? Updating signature requires updating ViewModel.
    
    // Let's check where saveSchedule is called. DoctorProfileViewModel.
    // VM has access to nothing? It needs token.
    
    // Alternative: Retrieve token from SharedPreferences 'auth_token' 
    // (AuthService saves it? Let's assume standard 'auth_token' key).
    
    final token = prefs.getString('auth_token');
    if (token != null) {
        final url = Uri.parse('${ApiService.apiPrefix}/doctors/update_schedule/');
        try {
            final response = await http.post(
                url,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $token',
                },
                body: json.encode(schedule.toJson()),
            );
            
            if (response.statusCode != 200) {
                print("Erreur sync backend: ${response.body}");
            } else {
                print("Horaires synchronisés avec le backend !");
            }
        } catch (e) {
            print("Erreur réseau sync: $e");
        }
    } else {
        print("Token non trouvé, sauvegarde locale uniquement.");
    }
  }

  Future<DoctorSchedule> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to fetch from backend if we have a token
    final token = prefs.getString('auth_token');
    if (token != null) {
      final url = Uri.parse('${ApiService.apiPrefix}/doctors/get_schedule/');
      try {
        final response = await http.get(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token',
            },
        );
        
        if (response.statusCode == 200) {
            // Save locally and return
            final data = json.decode(response.body);
            final schedule = DoctorSchedule.fromJson(data);
            await prefs.setString(keySchedule, json.encode(schedule.toJson()));
            return schedule;
        } else {
            print("Erreur fetch schedule: ${response.body}");
        }
      } catch(e) {
          print("Erreur réseau fetch schedule: $e");
      }
    }

    // Fallback to local
    final String? scheduleString = prefs.getString(keySchedule);
    if (scheduleString != null) {
      return DoctorSchedule.fromJson(json.decode(scheduleString));
    }
    // Return default empty schedule
    return DoctorSchedule();
  }

  // Save profile to backend and locally
  Future<void> saveProfile(Map<String, dynamic> profileData) async {
     final prefs = await SharedPreferences.getInstance();
     
     // 1. Sync with Backend
     final token = prefs.getString('auth_token');
     if (token != null) {
        final url = Uri.parse('${ApiService.apiPrefix}/doctors/update_profile/');
        // Mapping: Frontend keys might be 'fee'/'bio', backend expects 'consultation_fee'/'bio'
        // Let's assume the ViewModel sends backend-compatible keys OR we map them here.
        // ViewModel sends 'fee' (double) and 'bio' (string). Backend expects 'consultation_fee'.
        
        final backendData = {
            'bio': profileData['bio'],
            'consultation_fee': profileData['fee'],
            // Add other fields if necessary
        };

        try {
            final response = await http.post(
                url,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Token $token',
                },
                body: json.encode(backendData),
            );
            
            if (response.statusCode != 200) {
                 print("Erreur sync profile: ${response.body}");
            }
        } catch (e) {
            print("Erreur réseau sync profile: $e");
        }
     }

     // 2. Save Locally
     await prefs.setString(keyProfile, json.encode(profileData));
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Try to fetch from backend
    final token = prefs.getString('auth_token');
    if (token != null) {
       final url = Uri.parse('${ApiService.apiPrefix}/doctors/profile/');
       try {
         final response = await http.get(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Token $token',
            },
         );
         
         if (response.statusCode == 200) {
             final data = json.decode(response.body);
             // Map backend 'consultation_fee' to frontend 'fee'
             final profileData = {
                 'bio': data['bio'],
                 'fee': data['consultation_fee'] != null ? double.tryParse(data['consultation_fee'].toString()) : 0.0,
                 // Add others?
             };
             
             // Update local storage
             await prefs.setString(keyProfile, json.encode(profileData));
             return profileData;
         }
       } catch (e) {
           print("Erreur fetch profile: $e");
       }
    }

    // 2. Fallback to local
    final String? profileString = prefs.getString(keyProfile);
    if (profileString != null) {
      return json.decode(profileString);
    }
    return null;
  }
}
