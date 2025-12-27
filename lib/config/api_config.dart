class ApiConfig {
  static const String baseUrl = 'https://dab.yeet.su/api';
  
  // SESSION COOKIE CONFIGURATION
  // Replace this JWT token with your actual session token
  // This cookie is required for all authenticated endpoints (search)
  // The streaming endpoint does NOT require this cookie
  static const String sessionToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NTE2NjMsImlhdCI6MTc2NjQ4NjY0NSwiZXhwIjoxNzY3MDkxNDQ1fQ.mlbsqeOD18oA_wnyBLuOR39oOyAuTDDDA5q0T-pTB_M';
  
  static const String cookieName = 'session';
}
