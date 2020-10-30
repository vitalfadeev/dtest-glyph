module ui.utf;

import core.sys.windows.winnt   : LPWSTR, LPCWSTR, LPCSTR, LPSTR, LPTSTR, WCHAR;
import core.stdc.wchar_         : wcslen;
import std.conv                 : to;
import std.utf                  : toUTFz, toUTF16z, UTFException;


//
// all Windows applications today Unicode
//


/**
 */
LPWSTR toLPWSTR( string s ) nothrow // wchar_t*
{
    try                        { return toUTFz!( LPWSTR )( s ); }
    catch ( UTFException e )   { wstring err = "ERR"w; return cast( LPWSTR )err.ptr; }
    catch ( Exception e )      { wstring err = "ERR"w; return cast( LPWSTR )err.ptr; }
}
alias toLPWSTR toPWSTR;
alias toLPWSTR toLPOLESTR;
alias toLPWSTR toPOLESTR;

///
unittest
{
    auto a = "string".toLPWSTR();
    assert( is( typeof( a ) == wchar* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPWSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPCWSTR toLPCWSTR( string s ) nothrow // const( wchar )*
{
    try                        { return toUTF16z( s ); }
    catch ( UTFException e )   { return "ERR"w.ptr; }
    catch ( Exception e )      { return "ERR"w.ptr; }
}
alias toLPCWSTR toPCWSTR;


///
unittest
{
    auto a = "string".toPCWSTR();
    assert( is( typeof( a ) == const( wchar )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPWSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPCSTR toLPCSTR( string s ) nothrow // const( char_t )*
{
    try                        { return toUTFz!( LPCSTR )( s ); }
    catch ( UTFException e )   { return "ERR".ptr; }
    catch ( Exception e )      { return "ERR".ptr; }
}
alias toLPCSTR toPCSTR;


///
unittest
{
    auto a = "string".toPCSTR();
    assert( is( typeof( a ) == const( char )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toPCSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPSTR toLPSTR( string s ) nothrow // char_t*
{
    try                        { return toUTFz!( LPSTR )( s ); }
    catch ( UTFException e )   { string err = "ERR"; return cast( LPSTR )err.ptr; }
    catch ( Exception e )      { string err = "ERR"; return cast( LPSTR )err.ptr; }
}
alias toLPSTR toPSTR;


///
unittest
{
    auto a = "string".toLPSTR();
    assert( is( typeof( a ) == char* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPTSTR toLPTSTR( string s ) nothrow // wchar_t*
{
    try                        { return toUTFz!( LPTSTR )( s ); }
    catch ( UTFException e )   { string err = "ERR"; return cast( LPTSTR )err.ptr; }
    catch ( Exception e )      { string err = "ERR"; return cast( LPTSTR )err.ptr; }
}


///
unittest
{
    auto a = "string".toLPTSTR();
    assert( is( typeof( a ) == wchar* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPTSTR();
    assert( ru.to!string == "строка" );
}


/**
 Implementation C macros: TEXT( "x" ) L"x"
 */
LPCWSTR TEXT( const string s )
{
    return toLPCWSTR( s );
}


///
unittest
{
    auto a = "string".TEXT();
    assert( is( typeof( a ) == const( wchar )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".TEXT();
    assert( ru.to!string == "строка" );
}


// alias wchar_t TCHAR;


/**
Example:
--------------------
WCHAR[ WLAN_MAX_NAME_LENGTH ] guidString;
string s;
s = _info.strInterfaceDescription[ 0 .. wcslen( _info.strInterfaceDescription.ptr ) ].to!string;
--------------------
*/ 
string WcharBufToString( WCHAR[] buf )
{
    string s = buf.ptr[ 0 .. wcslen( buf.ptr ) ].to!string;
    
    return s;
}


/**
Example:
--------------------
FormatMessage( ... lpMsgBuf ... )
fromUTF16z( cast( wchar* )lpMsgBuf )
--------------------
*/
wstring fromUTF16z( const wchar* s )
{
    if ( s is null ) return null;

    wchar* ptr;
    for ( ptr = cast( wchar* )s; *ptr; ++ptr ) {}

    return to!wstring( s[ 0 .. ptr - s ] );
}

