final baseUrl = 'https://nadiad-samaj.onrender.com';

final loginEndpoint = '/api/v1/auth/login';
final registerEndpoint = '/api/v1/auth/register';
final sendOtpEndpoint = '/api/v1/auth/sendOtp';
final verifyOtpEndpoint = '/api/v1/auth/verifyOtp';
final refreshTokenEndpoint = '/api/v1/auth/refreshTokens';
final logoutEndpoint = '/api/v1/auth/logout';
final changePasswordEndpoint = '/api/v1/auth/changePassword';
final resetPasswordEndpoint = '/api/v1/auth/resetPassword'; // Used for setting PIN after OTP verification
final forgetPasswordEndpoint = '/api/v1/auth/forgetPassword';
final checkUserEndpoint = '/api/v1/auth/user'; // Check if user exists


final getAllUsersEndpoint = '/api/v1/user';
final updateUserEndpoint = '/api/v1/user/{id}';
final getCurrentUserEndpoint = '/api/v1/user/me';
final getAllUsersWithoutPaginationEndpoint = '/api/v1/user/paginatedRecords?page=1&limit=2';

final addFamilyEndpoint = '/api/v1/dataEntry';