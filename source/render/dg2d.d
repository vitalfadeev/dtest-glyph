module render.dg2d;

import core.sys.windows.windows;
import ui.window          : Window;
import dg2d.canvas        : Canvas;
import dg2d.path          : Path;
import dg2d.font          : Font;
import dg2d.rasterizer    : WindingRule;
import dg2d.font          : loadFont;
import dg2d.misc          : max;
import std.conv           : to;
import std.exception      : enforce;
import std.stdio          : writeln;
import std.stdio          : writefln;
import std.algorithm      : moveEmplaceSome;
import performancecounter : getPerformanceCounter;
import performancecounter : getPerformanceFrequency;
import ui.tools           : instance;
import tester             : Tester;


class Dg2dWindow : Window 
{
    char        theChar = 'A';
    RECT        outRect = { 0, 0, 20, 20 };

    Canvas      canvas;
    Path!float  path;
    Font        font;
    float[ 25 ] timings = 0;
    float       fps = 0;
    UINT_PTR    timer;


    this( int x, int y, int w, int h )
    {
        static import rawgfx;
        font = loadFont( rawgfx.rawfont );
        font.setSize( 16 );

        path = buildTextPath( font, theChar );

        canvas = new Canvas( w, h );

        canvas.resetView();
        canvas.setClip( 0, 0, w, h );

        super( "Dg2dWindow", x, y, w, h ); // creating class & window
    }


    override
    void onCreated()
    {
        timer = SetTimer( hwnd, 0, 1000/20, NULL );
    }


    override
    void onClose()
    {
        KillTimer( hwnd, timer );
        instance!Tester.next();
    }


    override
    void onPaint( HDC hdc )
    {
        canvas.resetView();
        canvas.setClip( 0, 0, rect.right, rect.bottom );

        //
        auto state = canvas.getViewState();

        //
        paint( canvas );

        //
        canvas.resetState( state );

        //
        BITMAPINFO info;
        info.bmiHeader.biSize          = info.sizeof;
        info.bmiHeader.biWidth         = canvas.stride;
        info.bmiHeader.biHeight        = -canvas.height;
        info.bmiHeader.biPlanes        = 1;
        info.bmiHeader.biBitCount      = 32;
        info.bmiHeader.biCompression   = BI_RGB;
        info.bmiHeader.biSizeImage     = canvas.stride * canvas.height * 4;
        info.bmiHeader.biXPelsPerMeter = 0;
        info.bmiHeader.biYPelsPerMeter = 0;
        info.bmiHeader.biClrUsed       = 0;
        info.bmiHeader.biClrImportant  = 0;

        SetDIBitsToDevice(
            hdc, 0, 0, canvas.stride, canvas.height, 0, 0, 0,
            canvas.height, canvas.pixels, &info, DIB_RGB_COLORS 
        );
    }


    void paint( Canvas canvas )
    {
        canvas.draw( path, 0xFF000000, WindingRule.NonZero );
    }


    void paintMeter()
    {
        //FillRect( canvas, &rect, cast( HBRUSH ) ( COLOR_WINDOW + 1 ) ); // Clear
        canvas.fill( 0xFFFFFFFF );

        paint( canvas );

        //
        long t = getPerformanceCounter();

        paint( canvas );

        t =  getPerformanceCounter()-t;

        moveEmplaceSome( timings[ 1 .. $ ], timings[ 0 .. $-1 ] );
        timings[ $-1 ] = getPerformanceFrequency() / ( 1.0 * t );

        fps = 0;
        foreach ( f; timings ) 
            fps = max( fps,f );

        writefln( "%s: %,.0f", __MODULE__, fps );
    }


    override 
    void onTimer()
    {
        paintMeter();
        repaint();
    }
}


//
Path!float buildTextPath( Font font, wchar theChar )
{
    Path!float path;
    float      x = 0;
    float      y = font.lineHeight();

    font.addChar( path, x, y, theChar );

    return path;
}


Path!float buildTextPath( Font font, const char[] txt, int rectWidth, int rectHeight )
{
    Path!float path;
    float[]    adv;
    adv.length = txt.length;
    font.getTextSpacing( txt, adv );

    int   i;
    int   paddingLeft = 0;
    int   paddingTop  = 0;
    int   subi        = 0;
    float subx        = paddingLeft;
    float y           = paddingTop + font.lineHeight();
    float pos         = subx;

    for ( i = 0; i < txt.length; i++ )
    {
        if ( ( txt[ i ] == ' ' ) || ( txt[ i ] == '\n' ) )
        {
            for ( int k = subi; k <= i; k++ )
            {
                font.addChar( path, subx, y, txt[ k ] );
                subx += adv[ k ];
            }
            subi = i + 1;
        }

        if ( ( pos > rectWidth ) || ( txt[ i ] == '\n' ) )
        {
            pos  = paddingLeft + pos - subx;
            subx = paddingLeft;
            y   += font.lineHeight();
        }

        if ( y > rectHeight ) return path;

        pos += adv[ i ];
    }

    return path;
}
