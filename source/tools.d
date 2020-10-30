module ui.tools;

import core.sys.windows.windows;
import std.conv  : to;
import std.stdio : writeln;
import std.stdio : writefln;
import std.range.primitives : isRandomAccessRange, isInputRange;


pragma( inline )
void Writeln( A... )( A a ) nothrow
{
    try {
        writeln( a );
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


pragma( inline )
void Writefln( A... )( A a ) nothrow
{
    try {
        writefln( a );
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


pragma( inline )
auto To( TYPE, VAR )( VAR var ) nothrow
{
    try {
        return var.to!TYPE;
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


template staticCat(T...)
if (T.length)
{
    import std.array;
    enum staticCat = [T].join();
}


pragma( inline )
bool odd(T)(T n) { return n & 1; }


pragma( inline )
bool even(T)(T n) { return !( n & 1 ); }


int max( int a, int b ) nothrow
{
    return ( a > b ) ? a : b;
}


int GET_X_LPARAM( LPARAM lp ) nothrow
{
    return cast( int ) cast( short )LOWORD( lp );
}


int GET_Y_LPARAM( LPARAM lp ) nothrow
{
    return cast( int ) cast( short )HIWORD( lp );
}


/**
*/
T instanceof( T )( Object o ) 
  if ( is( T == class ) ) 
{
    return cast( T ) o;
}

///
unittest
{
    class Base {}
    class A : Base {}
    class B : Base {}
    
    auto obj = new A;
    assert( obj.instanceof!A );
    assert( obj.instanceof!Base );
    assert( !obj.instanceof!B );
}


/**
*/
string baseName( ClassInfo classinfo ) 
{
    import std.array;
    import std.algorithm : countUntil;
    import std.range : retro;

    string qualName = classinfo.name;

    size_t dotIndex = qualName.retro.countUntil('.');

    if ( dotIndex < 0 ) 
    {
        return qualName;
    }

    return qualName[ $ - dotIndex .. $ ];
}


string moduleName( ClassInfo classinfo ) 
{
    import std.array;
    import std.algorithm : countUntil;
    import std.range : retro;

    string qualName = classinfo.name;

    size_t dotIndex = qualName.retro.countUntil('.');

    if ( dotIndex < 0 ) 
    {
        return "";
    }

    return qualName[ 0 .. $ - dotIndex - 1 ];
}


/**
*/
string classBaseName( Object instance ) 
{
    if ( instance is null ) 
    {
        return "null";
    }

    return instance.classinfo.baseName;
}


/**
*/
string classModuleName( Object instance ) 
{
    if ( instance is null ) 
    {
        return "null";
    }

    return instance.classinfo.moduleName;
}


/** */
T instance( T )()
{
    static T _instance;

    if ( !_instance )
    {
        _instance = new T();
    }

    return _instance;
}


/** 
*/
auto frontOrNull( R )( R range )
  if ( isInputRange!R )
{
    import std.range : empty, front;

    return range.empty ? null : range.front;
}

///
unittest
{
    import std.algorithm.searching : find;

    string[] strings;
    strings ~= "one";
    strings ~= "two";
    strings ~= "three";

    string name = "one";
    assert( strings.find!( ( string c ) => ( c == name ) ).frontOrNull == "one" );

    string name2 = "two";
    assert( strings.find!( ( string c ) => ( c == name2 ) ).frontOrNull == "two" );

    string nameOurside = "zero";
    assert( strings.find!( ( string c ) => ( c == nameOurside ) ).frontOrNull is null );
}


/**
*/
auto backOrNull( R )( R range )
  if ( isInputRange!R )
{
    import std.range : empty, back;

    return range.empty ? null : range.back;
}


///
unittest
{
    import std.algorithm.searching : find;

    string[] strings;
    strings ~= "one";
    strings ~= "two";
    strings ~= "three";

    string name = "one";
    assert( strings.find!( ( string c ) => ( c == name ) ).backOrNull == "three" );

    string name2 = "three";
    assert( strings.find!( ( string c ) => ( c == name2 ) ).backOrNull == "three" );

    string nameOurside = "zero";
    assert( strings.find!( ( string c ) => ( c == nameOurside ) ).backOrNull is null );
}


