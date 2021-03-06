MOD V1.0   T      а   Ї   t  h   B                                                                                                                               L   This module shows how you can implement persistent containers with APS/NWNX.aps_include         ┘  aps_onload         ┌  aps_onload         ┘  area001            ▄  area001            ■  area001            ч  creaturepalcus     ю  demo_createtable   ┌  demo_createtable   ┘  doorpalcus      	   ю  encounterpalcus 
   ю  go                 щ  h                  щ  itempalcus         ю  m                  щ  misc               щ  module             ▐  p                  щ  pcont_disturbed    ┌  pcont_disturbed    ┘  pcont_used         ┌  pcont_used         ┘  placeablepalcus    ю  Repute             Ў  soundpalcus        ю  storepalcus        ю  triggerpalcus      ю  waypointpalcus     ю                                                                                                                                                                                                                                  T  ▒D  J  д  йK  t  M  )2  F    `Б  ╦  +Р  °  #Ь    вЭ  ▄  ~б  м  *д  и  ╥ж  ├  Хй  └  Uм  ╧  $╜  └  ф┐  ╔  н┬  А  -╩  Ё  ╬  у   █  ├  ├щ  щ  мя  ╠  xЇ  №  t∙  a  ╒  ╪  н ш  Х l  	 ш  // Name     : Avlis Persistence System include
// Purpose  : Various APS/NWNX2 related functions
// Authors  : Ingmar Stieger, Adam Colon, Josh Simon
// Modified : February 16, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Return codes                     */
/************************************/

int SQL_ERROR = 0;
int SQL_SUCCESS = 1;

/************************************/
/* Function prototypes              */
/************************************/

// Setup placeholders for ODBC requests and responses
void SQLInit();

// Execute statement in sSQL
void SQLExecDirect(string sSQL);

// Position cursor on next row of the resultset
// Call this before using SQLGetData().
// returns: SQL_SUCCESS if there is a row
//          SQL_ERROR if there are no more rows
int SQLFetch();

// * deprecated. Use SQLFetch instead.
// Position cursor on first row of the resultset and name it sResultSetName
// Call this before using SQLNextRow() and SQLGetData().
// returns: SQL_SUCCESS if result set is not empty
//          SQL_ERROR is result set is empty
int SQLFirstRow();

// * deprecated. Use SQLFetch instead.
// Position cursor on next row of the result set sResultSetName
// returns: SQL_SUCCESS if cursor could be advanced to next row
//          SQL_ERROR if there was no next row
int SQLNextRow();

// Return value of column iCol in the current row of result set sResultSetName
string SQLGetData(int iCol);

// Return a string value when given a location
string LocationToString(location lLocation);

// Return a location value when given the string form of the location
location StringToLocation(string sLocation);

// Return a string value when given a vector
string VectorToString(vector vVector);

// Return a vector value when given the string form of the vector
vector StringToVector(string sVector);

// Set oObject's persistent string variable sVarName to sValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentString(object oObject, string sVarName, string sValue, int iExpiration=0, string sTable="pwdata");

// Set oObject's persistent integer variable sVarName to iValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentInt(object oObject, string sVarName, int iValue, int iExpiration=0, string sTable="pwdata");

// Set oObject's persistent float variable sVarName to fValue
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
void SetPersistentFloat(object oObject, string sVarName, float fValue, int iExpiration=0, string sTable="pwdata");

// Set oObject's persistent location variable sVarName to lLocation
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
//   This function converts location to a string for storage in the database.
void SetPersistentLocation(object oObject, string sVarName, location lLocation, int iExpiration=0, string sTable="pwdata");

// Set oObject's persistent vector variable sVarName to vVector
// Optional parameters:
//   iExpiration: Number of days the persistent variable should be kept in database (default: 0=forever)
//   sTable: Name of the table where variable should be stored (default: pwdata)
//   This function converts vector to a string for storage in the database.
void SetPersistentVector(object oObject, string sVarName, vector vVector, int iExpiration=0, string sTable ="pwdata");

// Get oObject's persistent string variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: ""
string GetPersistentString(object oObject, string sVarName, string sTable="pwdata");

// Get oObject's persistent integer variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
int GetPersistentInt(object oObject, string sVarName, string sTable="pwdata");

// Get oObject's persistent float variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
float GetPersistentFloat(object oObject, string sVarName, string sTable="pwdata");

// Get oObject's persistent location variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
location GetPersistentLocation(object oObject, string sVarname, string sTable="pwdata");

// Get oObject's persistent vector variable sVarName
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
// * Return value on error: 0
vector GetPersistentVector(object oObject, string sVarName, string sTable = "pwdata");

// Delete persistent variable sVarName stored on oObject
// Optional parameters:
//   sTable: Name of the table where variable is stored (default: pwdata)
void DeletePersistentVariable(object oObject, string sVarName, string sTable="pwdata");

// (private function) Replace special character ' with ~
string SQLEncodeSpecialChars(string sString);

// (private function)Replace special character ' with ~
string SQLDecodeSpecialChars(string sString);

/************************************/
/* Implementation                   */
/************************************/

// Functions for initializing APS and working with result sets

void SQLInit()
{
    int i;
    object oMod = GetModule();

    // Placeholder for ODBC persistence
    string sMemory;

    for (i = 0; i < 8; i++) // reserve 8*128 bytes
        sMemory += "................................................................................................................................";

    SetLocalString(oMod, "NWNX!INIT", "1");
    SetLocalString(oMod, "NWNX!ODBC!SPACER", sMemory);
}

void SQLExecDirect(string sSQL)
{
    SetLocalString(GetModule(), "NWNX!ODBC!EXEC", sSQL);
}

int SQLFetch()
{
    string sRow;
    object oModule = GetModule();
    SetLocalString(oModule, "NWNX!ODBC!FETCH", GetLocalString(oModule, "NWNX!ODBC!SPACER"));
    sRow = GetLocalString(oModule, "NWNX!ODBC!FETCH");
    if (GetStringLength(sRow) > 0)
    {
        SetLocalString(oModule, "NWNX_ODBC_CurrentRow", sRow);
        return SQL_SUCCESS;
    }
    else
    {
        SetLocalString(oModule, "NWNX_ODBC_CurrentRow", "");
        return SQL_ERROR;
    }
}

// deprecated. use SQLFetch().
int SQLFirstRow()
{
    return SQLFetch();
}

// deprecated. use SQLFetch().
int SQLNextRow()
{
    return SQLFetch();
}

string SQLGetData(int iCol)
{
    int iPos;
    string sResultSet = GetLocalString(GetModule(), "NWNX_ODBC_CurrentRow");

    // find column in current row
    int iCount = 0;
    string sColValue = "";

    iPos = FindSubString(sResultSet, "м");
    if ((iPos == -1) && (iCol == 1))
    {
        // only one column, return value immediately
        sColValue = sResultSet;
    }
    else if (iPos == -1)
    {
        // only one column but requested column > 1
        sColValue = "";
    }
    else
    {
        // loop through columns until found
        while (iCount != iCol)
        {
            iCount++;
            if (iCount == iCol)
                sColValue = GetStringLeft(sResultSet, iPos);
            else
            {
                sResultSet = GetStringRight(sResultSet,GetStringLength(sResultSet) - iPos - 1);
                iPos = FindSubString(sResultSet, "м");
            }

            // special case: last column in row
            if (iPos == -1)
                iPos = GetStringLength(sResultSet);
        }
    }

    return sColValue;
}

// These functions deal with various data types. Ultimately, all information
// must be stored in the database as strings, and converted back to the proper
// form when retrieved.

string VectorToString(vector vVector)
{
    return "#POSITION_X#" + FloatToString(vVector.x) + "#POSITION_Y#" + FloatToString(vVector.y) + "#POSITION_Z#" + FloatToString(vVector.z) + "#END#";
}

vector StringToVector(string sVector)
{
    float fX, fY, fZ;
    int iPos, iCount;
    int iLen = GetStringLength(sVector);

    if (iLen > 0)
    {
        iPos = FindSubString(sVector, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sVector, iPos, iCount));

        iPos = FindSubString(sVector, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sVector, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sVector, iPos, iCount));
    }

    return Vector(fX, fY, fZ);
}

string LocationToString(location lLocation)
{
    object oArea = GetAreaFromLocation(lLocation);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fOrientation = GetFacingFromLocation(lLocation);
    string sReturnValue;

    if (GetIsObjectValid(oArea))
        sReturnValue = "#AREA#" + GetTag(oArea) + "#POSITION_X#" + FloatToString(vPosition.x) + "#POSITION_Y#" + FloatToString(vPosition.y) + "#POSITION_Z#" + FloatToString(vPosition.z) + "#ORIENTATION#" + FloatToString(fOrientation) + "#END#";

    return sReturnValue;
}

location StringToLocation(string sLocation)
{
    location lReturnValue;
    object oArea;
    vector vPosition;
    float fOrientation, fX, fY, fZ;

    int iPos, iCount;
    int iLen = GetStringLength(sLocation);

    if (iLen > 0)
    {
        iPos = FindSubString(sLocation, "#AREA#") + 6;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        oArea = GetObjectByTag(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_X#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fX = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Y#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fY = StringToFloat(GetSubString(sLocation, iPos, iCount));

        iPos = FindSubString(sLocation, "#POSITION_Z#") + 12;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fZ = StringToFloat(GetSubString(sLocation, iPos, iCount));

        vPosition = Vector(fX, fY, fZ);

        iPos = FindSubString(sLocation, "#ORIENTATION#") + 13;
        iCount = FindSubString(GetSubString(sLocation, iPos, iLen - iPos), "#");
        fOrientation = StringToFloat(GetSubString(sLocation, iPos, iCount));

        lReturnValue = Location(oArea, vPosition, fOrientation);
    }

    return lReturnValue;
}

// These functions are responsible for transporting the various data types back
// and forth to the database.

void SetPersistentString(object oObject, string sVarName, string sValue, int iExpiration=0, string sTable="pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);
    sValue = SQLEncodeSpecialChars(sValue);

    string sSQL = "SELECT player FROM " + sTable + " WHERE player='" + sPlayer +
                  "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);

    if (SQLFetch() == SQL_SUCCESS)
    {
        // row exists
        sSQL = "UPDATE " + sTable + " SET val='" + sValue +
               "',expire=" + IntToString(iExpiration) + " WHERE player='"+ sPlayer +
               "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
        SQLExecDirect(sSQL);
    }
    else
    {
        // row doesn't exist
        sSQL = "INSERT INTO " + sTable + " (player,tag,name,val,expire) VALUES" +
               "('" + sPlayer + "','" + sTag + "','" + sVarName + "','" +
               sValue + "'," + IntToString(iExpiration) + ")";
        SQLExecDirect(sSQL);
    }
}

string GetPersistentString(object oObject, string sVarName, string sTable="pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);

    string sSQL = "SELECT val FROM " + sTable + " WHERE player='" + sPlayer +
               "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);

    if (SQLFetch() == SQL_SUCCESS)
        return SQLDecodeSpecialChars(SQLGetData(1));
    else
    {
        return "";
        // If you want to convert your existing persistent data to APS, this
        // would be the place to do it. The requested variable was not found
        // in the database, you should
        // 1) query it's value using your existing persistence functions
        // 2) save the value to the database using SetPersistentString()
        // 3) return the string value here.
    }
}

void SetPersistentInt(object oObject, string sVarName, int iValue, int iExpiration=0, string sTable="pwdata")
{
    SetPersistentString(oObject, sVarName, IntToString(iValue), iExpiration, sTable);
}

int GetPersistentInt(object oObject, string sVarName, string sTable="pwdata")
{
    return StringToInt(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentFloat(object oObject, string sVarName, float fValue, int iExpiration=0, string sTable="pwdata")
{
    SetPersistentString(oObject, sVarName, FloatToString(fValue), iExpiration, sTable);
}

float GetPersistentFloat(object oObject, string sVarName, string sTable="pwdata")
{
    return StringToFloat(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentLocation(object oObject, string sVarName, location lLocation, int iExpiration=0, string sTable="pwdata")
{
    SetPersistentString(oObject, sVarName, LocationToString(lLocation), iExpiration, sTable);
}

location GetPersistentLocation(object oObject, string sVarName, string sTable="pwdata")
{
    return StringToLocation(GetPersistentString(oObject, sVarName, sTable));
}

void SetPersistentVector(object oObject, string sVarName, vector vVector, int iExpiration=0, string sTable ="pwdata")
{
    SetPersistentString(oObject, sVarName, VectorToString(vVector), iExpiration, sTable);
}

vector GetPersistentVector(object oObject, string sVarName, string sTable = "pwdata")
{
    return StringToVector(GetPersistentString(oObject, sVarName, sTable));
}

void DeletePersistentVariable(object oObject, string sVarName, string sTable="pwdata")
{
    string sPlayer;
    string sTag;

    if (GetIsPC(oObject))
    {
        sPlayer = SQLEncodeSpecialChars(GetPCPlayerName(oObject));
        sTag = SQLEncodeSpecialChars(GetName(oObject));
    }
    else
    {
        sPlayer = "~";
        sTag = GetTag(oObject);
    }

    sVarName = SQLEncodeSpecialChars(sVarName);
    string sSQL = "DELETE FROM " + sTable + " WHERE player='" + sPlayer +
                  "' AND tag='" + sTag + "' AND name='" + sVarName + "'";
    SQLExecDirect(sSQL);
}

// Problems can arise with SQL commands if variables or values have single quotes
// in their names. These functions are a replace these quote with the tilde character

string SQLEncodeSpecialChars(string sString)
{
    if (FindSubString(sString, "'") == -1) // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;

    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "'")
            sReturn += "~";
        else
            sReturn += sChar;
    }
    return sReturn;
}

string SQLDecodeSpecialChars(string sString)
{
    if (FindSubString(sString, "~") == -1) // not found
        return sString;

    int i;
    string sReturn = "";
    string sChar;

    // Loop over every character and replace special characters
    for (i = 0; i < GetStringLength(sString); i++)
    {
        sChar = GetSubString(sString, i, 1);
        if (sChar == "~")
            sReturn += "'";
        else
            sReturn += sChar;
    }
    return sReturn;
}
NCS V1.0B  д             °     №      °     №*     +     °          Є    °     №       Ё     №   Ї         ╝   №  А................................................................................................................................#   °     №   Ї $   Ё    №    : 1 	NWNX!INIT   Ё   9   №  NWNX!ODBC!SPACER   Ё   9    Ї  // Name     : Avlis Persistence System OnModuleLoad
// Purpose  : Initialize APS on module load event
// Authors  : Ingmar Stieger
// Modified : January 27, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

void main()
{
    // Init placeholders for ODBC gateway
    SQLInit();
}

ARE V3.28   A   D  и  $#  2   D&  =   Б&  а
  !1            (      а   
      ╚   
      Ё   
        
      @  
      h  
      Р  
      ╕  
      р  
        
      0  
      X  
      А  
      и  
      ╨  
      °  
         
      H  
      p  
      Ш  
      └  
      ш  
        
      8  
      `  
      И  
      ░  
      ╪  
         
      (  
      P  
      x  
      а  
      ╚  
      Ё  
        
      @  
      h  
      Р  
      ╕  
      р  
        
      0  
      X  
      А  
      и  
      ╨  
      °  
         
      H  
      p  
      Ш  
      └  
      ш  
      	  
      8	  
      `	  
      И	  
      ░	  
      ╪	  
       
  
      (
  
      P
  
      x
  
                                 
                         '   
      /                         	          
                       dd╚                  22d                 22d                            h~С                                        2                                                                                                 !         "   3      #   4      $   5      %   6      &   7      '         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1         (         )          *           +           ,           -           .           /          0          1         (         )         *           +           ,           -           .           /          0          1      ID              Creator_ID      Version         Tag             Name            ResRef          Comments        Expansion_List  Flags           ModSpotCheck    ModListenCheck  MoonAmbientColorMoonDiffuseColorMoonFogAmount   MoonFogColor    MoonShadows     SunAmbientColor SunDiffuseColor SunFogAmount    SunFogColor     SunShadows      IsNight         LightingScheme  ShadowOpacity   DayNightCycle   ChanceRain      ChanceSnow      ChanceLightning WindPower       LoadScreenID    PlayerVsPlayer  NoRest          Width           Height          OnEnter         OnExit          OnHeartbeat     OnUserDefined   Tileset         Tile_List       Tile_ID         Tile_OrientationTile_Height     Tile_MainLight1 Tile_MainLight2 Tile_SrcLight1  Tile_SrcLight2  Tile_AnimLoop1  Tile_AnimLoop2  Tile_AnimLoop3     Area001                 Area 001area001        tms01                            	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      А   Б   В   Г   Д   Е   Ж   З   И   Й   К   Л   М   Н   О   П   Р   С   Т   У   Ф   Х   Ц   Ч   Ш   Щ   Ъ   Ы   Ь   Э   Ю   Я   а   б   в   г   д   е   ж   з   и   й   к   л   м   н   о   п   ░   ▒   ▓   │   ┤   ╡   ╢   ╖   ╕   ╣   ║   ╗   ╝   ╜   ╛   ┐   └   ┴   ┬   ├   ─   ┼   ╞   ╟   ╚   ╔   ╩   ╦   ╠   ═   ╬   ╧   ╨   ╤   ╥   ╙   ╘   ╒   ╓   ╫   ╪   ┘   ┌   █   ▄   ▌   ▐   ▀   р   с   т   у   ф   х   ц   ч   ш   щ   ъ   ы   ь   э   ю   я   Ё   ё   Є   є   Ї   ї   Ў   ў   °   ∙   ·   √   №   ¤   ■                          	  
                                               !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~    А  Б  В  Г  Д  Е  Ж  З  И  Й  К  Л  М  Н  О  П  Р  С  Т  У  Ф  Х  Ц  Ч  Ш  Щ  Ъ  Ы  Ь  Э  Ю  Я  а  б  в  г  д  е  ж  з  и  й  к  л  м  н  о  п  ░  ▒  ▓  │  ┤  ╡  ╢  ╖  ╕  ╣  ║  ╗  ╝  ╜  ╛  ┐  └  ┴  ┬  ├  ─  ┼  ╞  ╟  ╚  ╔  ╩  ╦  ╠  ═  ╬  ╧  ╨  ╤  ╥  ╙  ╘  ╒  ╓  ╫  ╪  ┘  ┌  █  ▄  ▌  ▐  ▀  р  с  т  у  ф  х  ц  ч  ш  щ  ъ  ы  ь  э  ю  я  Ё  ё  Є  є  Ї  ї  Ў  ў  °  ∙  ·  √  №  ¤  ■                        	  
                                               !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~    А  Б  В  Г  Д  Е  Ж  З  И  Й  К  Л  М  Н  О  П  Р  С  Т  У  Ф  Х  Ц  Ч  Ш  Щ  Ъ  Ы  Ь  Э  Ю  Я  а  б  в  г  д  е  ж  з      @                           	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   GIC V3.28      \      р   
   А  J   ╩  $   ю  ,           	   	   	      	   
                                                                                          
   	       
   	   #   Creature List   Door List       Encounter List  List            SoundList       StoreList       TriggerList     WaypointList    Placeable List  Comment            Chest - 1 (Low treasure script)#   Freestanding Merchant's Placard - 1                                                                     GIT V3.28      h      \  I   ь
  ╖  г  №  Я  ,       $   
   d       	   	   L   6   	   $  6                                                                   "                        	   Р_    
                                                                                
                         -         й                               ┤                                                                                !   m      "          #           $          %          &           '          (       
   )   ╡       *          +         ,         -          .          /          0           1          2   ╣      3   ║      4   ╗      5   ╝      6   ╜      7   ╛      8   ┐      9   └      :   ┴      ;   ┬      <   ├      =   ─       >          ?           @           A           B         C   ┼      D   ╒      E   │'B   F   0E+B   G      7   H      А
      р                 7        З                              Ф                                                                               !   щ      "          #           $          %          &           '          (       
   )   Х      *          +   Г      ,         -          .          /          0           1          2   Щ     3   Ъ     4   Ы     5   Ь     6   Э     7   Ю     8   Я     9   а     :   б     ;   в     <   г     =   д      >           ?           @           A           B         C   е     D   ж     E   я╖B   F   cЬ+B   G      7   H   ╠>AreaProperties  AmbientSndDay   AmbientSndNight AmbientSndDayVolAmbientSndNitVolEnvAudio        MusicBattle     MusicDay        MusicNight      MusicDelay      Creature List   Door List       Encounter List  List            SoundList       StoreList       TriggerList     WaypointList    Placeable List  Tag             LocName         Description     TemplateResRef  AutoRemoveKey   CloseLockDC     Conversation    Interruptable   Faction         Plot            KeyRequired     Lockable        Locked          OpenLockDC      PortraitId      TrapDetectable  TrapDetectDC    TrapDisarmable  DisarmDC        TrapFlag        TrapOneShot     TrapType        KeyName         AnimationState  Appearance      HP              CurrentHP       Hardness        Fort            Ref             Will            OnClosed        OnDamaged       OnDeath         OnDisarm        OnHeartbeat     OnLock          OnMeleeAttacked OnOpen          OnSpellCastAt   OnTrapTriggered OnUnlock        OnUserDefined   HasInventory    BodyBag         Static          Type            Useable         OnInvDisturbed  OnUsed          X               Y               Z               Bearing            PersistentChest1   ф            Chestx   9         h   Bound in iron and with a heavy lock, this heavy chest was obviously meant to protect something of value.
plc_chest1                 pcont_disturbed
pcont_used   FreestandingMerchantsPlacard22   `9         "   Create database table "containers"L   _9         <   A carefully constructed marker denoting a point of interest.plc_placard1                  demo_createtable                        	       
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~                                            ITP V3.28   =     y   └      	       	  р  р
                                                                       (          0          8          @          H          P          X          `          h          p          x          А          И          Р          Ш          а          и          ░          ╕          └          ╚          ╨          ╪          р          ш          Ё          °                                                         (         0         8         @         H         P         X         `         h         p         x         А         И         Р         Ш         а         и         ░         ╕         └         ╚         ╨         ╪                      %                 ў         0         &        L         '                  (                  )                  *                  ╔          	         8                  9                  :                          d         G         "         H         #         I         $         J         %         1        x         2                  3                  4                  5                  6                                    ╔          2         ,        Ш         -         
         .                  ў         1         8                  ;        д         <                  =                  >                  +         /         ?                  /                  #        ╝         
                  B                  ╔                   D                  C                  k                   E         !         K        ▄                   &                   '                   (                   *                   )         !          +         #          ,         ╔          -                                              !                  "                  #                  $                  L         .   MAIN            STRREF          LIST            ID                                      	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x         -   6   <            	   
                        $   %                                                                               !   "   #      &   '   (   )   *   +   ,      .   /   0   1   2   3   4   5      7   8   9   :   ;   NCS V1.0B               °     №      °     №*     +     °   DROP TABLE containers    ч Table 'containers' deleted. J  v CREATE TABLE containers ( container VARCHAR(64),# item VARCHAR(64),# count SMALLINT UNSIGNED,# identified TINYINT)#    1 Table 'containers' created. J  v     №  NWNX!ODBC!EXEC  Є   9    №  // Name     : Demo create table
// Purpose  : Create database table "containers"
// Authors  : Ingmar Stieger
// Modified : January 30, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

void main()
{

    SQLExecDirect("DROP TABLE containers");
    SendMessageToPC(GetLastUsedBy(), "Table 'containers' deleted.");

    // For Access
    /*
    SQLExecDirect("CREATE TABLE containers (" +
                    "container text(64)," +
                    "item text(64)," +
                    "count number," +
                    "identified number)");
    */
    // For MySQL

    SQLExecDirect("CREATE TABLE containers (" +
                    "container VARCHAR(64)," +
                    "item VARCHAR(64)," +
                    "count SMALLINT UNSIGNED," +
                    "identified TINYINT)");

    SendMessageToPC(GetLastUsedBy(), "Table 'containers' created.");
}
ITP V3.28      ╚      ▄             X   t  8                                                                      (          0          8          @          H          P                                                            !                  "                  #                  $                  N                  O        (         P                  Q                  R            MAIN            STRREF          LIST            ID                                      	   
                                                                        	   
      ITP V3.28      ╚      ▄             X   t  4                                                                      (          0          8          @          H          P                       к                  л         	         ╤                  й                                                       !                  "                  #                  $                  з            MAIN            STRREF          ID              LIST                                    	   
                                                                        	   
   UTI V3.28      D           <  ;   w  H   ┐                                 L                           %   
      1                                      	   P├      
                                                                    
      7   TemplateResRef  BaseItem        LocalizedName   Description     DescIdentified  Tag             Charges         Cost            Stolen          StackSize       Plot            AddCost         Identified      Cursed          ModelPart1      PropertiesList  PaletteID       Comment         go                 go                         go                                	   
                            UTI V3.28      D           <  8   t  H   ╝                                                            #   
      /                                     	          
                                                                    
      4   TemplateResRef  BaseItem        LocalizedName   Description     DescIdentified  Tag             Charges         Cost            Stolen          StackSize       Plot            AddCost         Identified      Cursed          ModelPart1      PropertiesList  PaletteID       Comment         h                 h                         h                                	   
                            ITP V3.28   T   (  й        t  +   Я  а  ?  Р                                                          $          ,          4          <          D          L          T          \          d          l          t          |          Д          М          Ф          Ь          д          м          ┤          ╝          ─          ╠          ╘          ▄          ф          ь          Ї          №                                              $         ,         4         <         D         L         X         `         h         p         x         А         И         Р         Ш         а         и         ░         ╕         └         ╚         ╨         ╪         р         ш         Ё         °                                                        (         0         8         @         H         P         X         `         h         p         x         А         И         Р         Ш                      O                  ║                   @   
                   
      	            
                  
                        ╥                  S         	         ╧                                    Э         :         T        T         ж                  U         
         V                  W        d         Ъ         7         X                  п         ?         Ю         ;         Щ                  Ы         8         8        А         Я         <         ║         и         Y                  Ё                  Z                  [                  ·                  ТF        @         Ь         9         ]        └         ^                  _                  \                  +                  a                  b                  Ш         6                 ╠                             ф   
               &         !                  "                  #                  $                  L         5         Ї        ь         d                e                  f                  g                  ъ        (        j                   h                  i                  k        8        l         !         m         "         n         #         o         $         +         %         p         &         ы        T        q         '         r         (         s         )         t         *         б         =         w         .         x         /         y        l        z         0         {         1         |         2         щ         3         в        |        v         +         г         ,         д         -         е         >         ю         4   MAIN            STRREF          LIST            ID              NAME            RESREF             gogo   hh   mm   pp   miscmisc                        	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      А   Б   В   Г   Д   Е   Ж   З   И   Й   К   Л   М   Н   О   П   Р   С   Т   У   Ф   Х   Ц   Ч   Ш   Щ   Ъ   Ы   Ь   Э   Ю   Я   а   б   в   г   д   е   ж   з   и               (   )   0   1               	   
                                                         	                !   $   %   &   '                        "   #      *   ,   -   .   /      +   
   2   6   :   A   G   H   I   M   N   S      3   4   5      7   8   9      ;   <   =   >   ?   @      B   C   D   E   F      J   K   L      O   P   Q   R   UTI V3.28      D           <  8   t  H   ╝                                                            #   
      /                                      	          
                                                                    
      4   TemplateResRef  BaseItem        LocalizedName   Description     DescIdentified  Tag             Charges         Cost            Stolen          StackSize       Plot            AddCost         Identified      Cursed          ModelPart1      PropertiesList  PaletteID       Comment         m                 m                         m                                	   
                            UTI V3.28      D           <  A   }  H   ┼                                                            )   
      5                                      	          
                                                                     
      =   TemplateResRef  BaseItem        LocalizedName   Description     DescIdentified  Tag             Charges         Cost            Stolen          StackSize       Plot            AddCost         Identified      Cursed          ModelPart1      PropertiesList  PaletteID       Comment         misc                 misc                         misc                                	   
                            IFO V3.28      P   1   Ь  1   м  °   д  └   d             0      .                 
                                              
      ;         E              
   	   е      
   й           B        B                ;·H=      ▒?                                                                            \         
         ▒         ▓         ╜         ╛         ┐         └         ┴          ┬      !   ├      "   ─      #   ╨      $   ▄      %   ▌      &   ▐      '   ь      (   э      )   ю      *   я      +         ,         -         .   Ё      /         0      Mod_ID          Mod_MinGameVer  Mod_Creator_ID  Mod_Version     Expansion_Pack  Mod_Name        Mod_Tag         Mod_Description Mod_IsSaveGame  Mod_CustomTlk   Mod_Entry_Area  Mod_Entry_X     Mod_Entry_Y     Mod_Entry_Z     Mod_Entry_Dir_X Mod_Entry_Dir_Y Mod_Expan_List  Mod_DawnHour    Mod_DuskHour    Mod_MinPerHour  Mod_StartMonth  Mod_StartDay    Mod_StartHour   Mod_StartYear   Mod_XPScale     Mod_OnHeartbeat Mod_OnModLoad   Mod_OnModStart  Mod_OnClientEntrMod_OnClientLeavMod_OnActvtItem Mod_OnAcquirItemMod_OnUsrDefinedMod_OnUnAqreItemMod_OnPlrDeath  Mod_OnPlrDying  Mod_OnPlrEqItm  Mod_OnPlrLvlUp  Mod_OnSpawnBtnDnMod_OnPlrRest   Mod_OnPlrUnEqItmMod_OnCutsnAbortMod_StartMovie  Mod_CutSceneListMod_GVar_List   Mod_Area_list   Area_Name       Mod_HakList     Mod_CacheNSSList   cЬШ!кKзъ*з·пю   1.60                 Pcontainers   MODULE\              L   This module shows how you can implement persistent containers with APS/NWNX.    area001 
aps_onload       nw_o0_deathnw_o0_dying  nw_o0_respawn    area001                            	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   /   0                             UTI V3.28      P      Ф     D  8   |  l   ш                    P                       1                           #   
      /                    Т                	   
       
                                                                                                                                                 d             
      4   TemplateResRef  BaseItem        LocalizedName   Description     DescIdentified  Tag             Charges         Cost            Stolen          StackSize       Plot            AddCost         Identified      Cursed          ModelPart1      ModelPart2      ModelPart3      PropertiesList  PropertyName    Subtype         CostTable       CostValue       Param1          Param1Value     ChanceAppear    PaletteID       Comment         p                 p                         p                                	   
                                                         NCS V1.0B  у             °     №      °     №*     +     °   \    °     №   №   ┘"        №   O     a    °     №   №   *"        °          °          ` "Stackable items are not supported.   Ї  v   °    °   З    °    г     `    №      %    8   №     %    A   №     %    +    D   °       и   ╝    %   °       и   ┐        №    °     °  Н   °     №   №    M    №        №        °    1     №        №        °    '     №        №        °    >     №        №        °    6     №        №        °         №        №        °         №        №        °         №        №        °         №        №        °    ?     №        №        °    ;     №        №        °    L      ,      Ё     °    :    №    (-        Ё     °        №    №    №     Ё  L  \   °     № *SELECT * FROM containers WHERE container='   Ё # ' AND item='#   ь   и# ' AND identified=#   ° #   Ї     №   °    ╣   ▌'   №      ь        ш       °     № UPDATE containers SET count=   °   \#  WHERE container='#   ь # ' AND item='#   ш   и# ' AND identified=#   Ї #   Ё     №   Ї     ╟    №    н-  @INSERT INTO containers (container,item,count,identified) VALUES  ('#   Ё # ','#   ь   и# ',1,#   ° # )#   Ї     №   °         °    °     №  NWNX!ODBC!EXEC  Є   9    №    Є    °     № NWNX!ODBC!SPACER   °   5 NWNX!ODBC!FETCH   Ї   9 NWNX!ODBC!FETCH   °   5   Ї     №   °   ;         [   °  NWNX_ODBC_CurrentRow   Ї   9'   №    Ё     Ї    e    №    S-    NWNX_ODBC_CurrentRow   Ї   9'   °    Ё     Ї        №    °   NWNX_ODBC_CurrentRow  Є   5   °     №       °     №     °     № м   Ё   B   ь     №   Ё        №        ш          "   Ї    °     №   B-    Ё              °     №   -    °    ш      Ў   ° $   Ї    №   °    ш      /   Ё    Ё   ?   °     №    b-    Ї   ;   ь         Ё   >   Ё     № м   Ё   B   ь     №   Ё         '   Ї   ;   ь     №       ■■   №    ф     ь        №    Ё    №     Ё  L  \   °     № *SELECT * FROM containers WHERE container='   Ё # ' AND item='#   ь   и# ' AND identified=#   ° #   Ї     №   °    √Ч   √╗'   №     Р      №ц  ш       °     №   №          Т (DELETE FROM containers WHERE container='   ь # ' AND item='#   ш   и# ' AND identified=#   Ї #   Ё     №    й-  UPDATE containers SET count=   °   \#  WHERE container='#   ь # ' AND item='#   ш   и# ' AND identified=#   Ї #   Ё     №   Ї    ·    №        °    °  // Name     : Persistent containers inventory disturbed
// Purpose  : Called when a player messes with the inventory of a persistent container
// Author   : Ingmar Stieger
// Modified : March 1, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

// Note: The OnDisturbed event doesn't work reliable with stackable items
// so they are not supported in this implementation
int GetIsItemStackable(object oItem)
{
    int iType = GetBaseItemType(oItem);
    if (iType == BASE_ITEM_GEM || iType == BASE_ITEM_POTIONS ||
        iType == BASE_ITEM_HEALERSKIT || iType == BASE_ITEM_THIEVESTOOLS ||
        iType == BASE_ITEM_SCROLL || iType == BASE_ITEM_ARROW ||
        iType == BASE_ITEM_BOLT || iType == BASE_ITEM_BULLET ||
        iType == BASE_ITEM_DART || iType == BASE_ITEM_THROWINGAXE ||
        iType == BASE_ITEM_SHURIKEN || iType == BASE_ITEM_GOLD)
        return TRUE;
    else
        return FALSE;
}

// Add item to the container
void addItem(string sContainerTag, object oItem)
{
    string sSQL;
    string id = IntToString(GetIdentified(oItem));

    // lookup item
    sSQL = "SELECT * FROM containers WHERE container='" + sContainerTag +
           "' AND item='" + GetTag(oItem) + "' AND identified=" + id;
    SQLExecDirect(sSQL);

    if (SQLFetch() == SQL_SUCCESS)
    {
        // existent, increment item counter in existing row
        int iCount = StringToInt(SQLGetData(3)) + 1;
        sSQL = "UPDATE containers SET count=" + IntToString(iCount) +
               " WHERE container='" + sContainerTag + "' AND item='" +
               GetTag(oItem) + "' AND identified=" + id;
        SQLExecDirect(sSQL);
    }
    else
    {
        // not existent, add new row
        sSQL = "INSERT INTO containers (container,item,count,identified) VALUES " +
               "('" + sContainerTag + "','" + GetTag(oItem) + "',1," + id + ")";
        SQLExecDirect(sSQL);
    }
}

// Remove item from container
void removeItem(string sContainerTag, object oItem)
{
    string sSQL;
    string id = IntToString(GetIdentified(oItem));

    // lookup item
    sSQL = "SELECT * FROM containers WHERE container='" + sContainerTag +
           "' AND item='" + GetTag(oItem) + "' AND identified=" + id;
    SQLExecDirect(sSQL);

    if (SQLFetch() == SQL_SUCCESS)
    {
        // existant, decrement item counter in existing row
        int iCount = StringToInt(SQLGetData(3)) - 1;
        if (iCount == 0)
        {
            sSQL = "DELETE FROM containers WHERE container='" +
                   sContainerTag + "' AND item='" + GetTag(oItem) +
                   "' AND identified=" + id;
        }
        else
        {
            sSQL = "UPDATE containers SET count=" + IntToString(iCount) +
                   " WHERE container='" + sContainerTag + "' AND item='" +
                   GetTag(oItem) + "' AND identified=" + id;
        }
        SQLExecDirect(sSQL);
    }
}

void main()
{
    object oPC = GetLastDisturbed();
    if (!GetIsPC(oPC))
        return;

    object oItem = GetInventoryDisturbItem();
    if (!GetIsObjectValid(oItem))
        return;

    // reject stackable items
    if (GetIsItemStackable(oItem))
    {
        SendMessageToPC(oPC, "Stackable items are not supported.");
        ActionGiveItem(oItem, oPC);
        return;
    }

    switch(GetInventoryDisturbType())
    {
        case INVENTORY_DISTURB_TYPE_ADDED:
            addItem(GetTag(OBJECT_SELF), oItem);
        break;

        case INVENTORY_DISTURB_TYPE_REMOVED:
        case INVENTORY_DISTURB_TYPE_STOLEN:
            removeItem(GetTag(OBJECT_SELF), oItem);
        break;
    }
}
NCS V1.0B  щ             °     №      °     №*     +     °       S   °     №   №   *"   п /SELECT item, count, identified FROM containers  WHERE container='#      и# '#   °     №   №    ;   U'   №           В   ш     №      f  ш   °     №      E  ш   Ё     №       Ї     №   °    °      u          ф      ь     №   Ё   *    !   Ї    ь  M       ° $   Ї    №       ■я    ш        №     №  NWNX!ODBC!EXEC  Є   9    №    Є    °     № NWNX!ODBC!SPACER   °   5 NWNX!ODBC!FETCH   Ї   9 NWNX!ODBC!FETCH   °   5   Ї     №   °   ;         [   °  NWNX_ODBC_CurrentRow   Ї   9'   №    Ё     Ї    e    №    S-    NWNX_ODBC_CurrentRow   Ї   9'   °    Ё     Ї        №    °   NWNX_ODBC_CurrentRow  Є   5   °     №       °     №     °     № м   Ё   B   ь     №   Ё        №        ш          "   Ї    °     №   B-    Ё              °     №   -    °    ш      Ў   ° $   Ї    №   °    ш      /   Ё    Ё   ?   °     №    b-    Ї   ;   ь         Ё   >   Ё     № м   Ё   B   ь     №   Ё         '   Ї   ;   ь     №       ■■   №    ф     ь        №    Ё    №  // Name     : Persistent container used
// Purpose  : Called when a player "uses" a persistent container
// Author   : Ingmar Stieger
// Modified : March 1, 2003

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

#include "aps_include"

void main()
{
    object oItem = GetFirstItemInInventory();
    if (!GetIsObjectValid(oItem))
    {
        // container is empty:
        // load inventory from database and put it in container
        string sSQL;
        sSQL = "SELECT item, count, identified FROM containers " +
               "WHERE container='" + GetTag(OBJECT_SELF) + "'";
        SQLExecDirect(sSQL);

        string sItemTag;
        object oItem;
        int id;
        int i, iItemCount;
        while (SQLFetch() == SQL_SUCCESS)
        {
            sItemTag = SQLGetData(1);
            iItemCount = StringToInt(SQLGetData(2));
            id = StringToInt(SQLGetData(3));

            for (i = 0; i < iItemCount; i++)
            {
                oItem = CreateItemOnObject(sItemTag, OBJECT_SELF);
                if (GetIsObjectValid(oItem))
                    SetIdentified(oItem, id);
            }
        }
    }
}
ITP V3.28      X  0   Ш     ╪      ╪  ╝   Ф  h                                                                      (          0          8          @          H          P          X          `          h          p          x          А          М          Ф          Ь          д          м          ┤                                         ~                  А                  8         	         Б         
         В                  Г                  в#                  и#                          8                             !                  "                  #                  $                  Д                  ║                 P         Ї                  ╠                                   Я╧                  <                 }            MAIN            STRREF          ID              LIST                                    	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /                              	   
                                                FAC V3.28      p  M        М  5   ┴  4  ї  l       <                                      $         0          D         P         \         h         t         А         М         Ш         д      	   ░      
   ╝         ╚         ╘         р         ь         °                                 (                          
                             
                            
                            
                            
      )                                                                           2                            2                            2                           d                                                                                                                                           d                           2                           d                                                       2                           d                           d                                                       2                           d                           d   FactionList     FactionParentID FactionName     FactionGlobal   RepList         FactionID1      FactionID2      FactionRep         PC   Hostile   Commoner   Merchant   Defender                        	   
                                                                          !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L                                 	   
                                                ITP V3.28      ╘            @      @  `   а  8                                                                      (          0          8          @          H          P          X                       &                  9ў                  Ї                  Ї                  Ї                                                        !                  "                  #                  $                  Ї            MAIN            STRREF          ID              LIST                                    	   
                                                                              	   
      ITP V3.28      Ш      L     М      М  8   ─  $                                                                      (          0                       Е                                                       !                  "                  #                  $            MAIN            STRREF          ID              LIST                                    	   
                                          ITP V3.28      °      l     м      м  x   $  H                                                                      (          0          8          @          H          P          X          `          h          p                       :                  Ж                  й#                                                       !                  "                  #                  $                  ╗        0         ╜╧                  ╧                  ╨                  ╤                  ╛╧            MAIN            STRREF          ID              LIST                                    	   
                                                                              
                  	                     ITP V3.28      Ш      L     М      М  8   ─  $                                                                      (          0                                                            !                  "                  #                  $                  О            MAIN            STRREF          LIST            ID                                      	   
                                          