enum ServerActionError {
  networkError, // No internet / connectivity issues
  serverError, // 5xx errors from the server
  unauthorized, // 401 or invalid token
  forbidden, // 403
  notFound, // 404
  badRequest, // 400 or invalid request
  timeout, // Request timed out
  cacheExpired, // Local cache expired
  unknown, // Catch-all for unexpected errors
}
