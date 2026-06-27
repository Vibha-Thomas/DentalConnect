/// API constants for DentConnect backend
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2:8080/api/v1'; // Android emulator → localhost
  static const String baseUrlIos = 'http://localhost:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Dentist
  static const String dentistProfile = '/dentists/me';
  static const String dentistResume = '/dentists/me/resume';

  // Clinic
  static const String clinicProfile = '/clinics/me';
  static const String clinicStaff = '/clinics/me/staff';

  // Jobs
  static const String jobs = '/jobs';
  static String jobDetail(String id) => '/jobs/$id';
  static String applyJob(String id) => '/jobs/$id/apply';
  static const String savedJobs = '/jobs/saved';

  // Applications
  static const String applications = '/applications';
  static String applicationDetail(String id) => '/applications/$id';

  // Notifications
  static const String notifications = '/notifications';

  // WhatsApp
  static const String whatsappLink = '/whatsapp/link';

  // Skills
  static const String skills = '/skills';
}
