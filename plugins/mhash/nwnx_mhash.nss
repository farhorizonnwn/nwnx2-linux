/**
 * Hashes a string with a named algorithm.
 *
 * For a list of supported algorithms, read the mhash manpage of your distro, or have a look
 * into logs.0/nwnx_mhash.txt on the server.
 *
 * Example: mhash_hash("CRC32", "goblin");
 *
 * Returned format is a hex string of variable length (depending on the algorithm).
 *
 * Will return "" on any error, so it is prudent to check for that - especially when hashing
 * sensitive data. Errors are printed to the plugin log.
 */
string mhash_hash(string algorithm, string data);

/**
 * HMACs a string with a given password and named algorithm.
 *
 * For a list of supported algorithms, read the mhash manpage of your distro, or have a look
 * into logs.0/nwnx_mhash.txt on the server.
 *
 * Example: mhash_hmac("SHA256", "sekritpashwurd", "somevalue");
 *
 * Returned format is a hex string of variable length (depending on the algorithm).
 *
 * Will return "" on any error, so it is prudent to check for that - especially when hashing
 * sensitive data. Errors are printed to the plugin log.
 */
string mhash_hmac(string algorithm, string password, string data);


string mhash_hash(string algorithm, string data)
{
	SetLocalString(GetModule(), "NWNX!MHASH!HASH", algorithm + "�" + data);
	string ret = GetLocalString(GetModule(), "NWNX!MHASH!HASH");
	// We delete it to make sure we dont leak anything to other scripts that could read the hash.
	DeleteLocalString(GetModule(), "NWNX!MHASH!HASH");
	return ret;
}

string mhash_hmac(string algorithm, string password, string data)
{
	SetLocalString(GetModule(), "NWNX!MHASH!HMAC", algorithm + "�" + password + "�" + data);
	string ret = GetLocalString(GetModule(), "NWNX!MHASH!HMAC");
	// We delete it to make sure we dont leak anything to other scripts that could read the hash.
	DeleteLocalString(GetModule(), "NWNX!MHASH!HMAC");
	return ret;
}
