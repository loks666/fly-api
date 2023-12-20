package common

var UsingSQLite = false
var UsingPostgreSQL = false

var SQLitePath = "fly-api.db"
var SQLiteBusyTimeout = GetOrDefault("SQLITE_BUSY_TIMEOUT", 3000)
