module render.gdi;

import core.sys.windows.windows;
import std.algorithm      : moveEmplaceSome;
import std.stdio          : writeln;
import std.stdio          : writefln;
import ui.window          : Window;
import performancecounter : getPerformanceCounter;
import performancecounter : getPerformanceFrequency;
import dg2d.misc          : max;
import std.utf            : toUTF16;
import ui.tools           : instance;
import tester             : Tester;


class GDIWindow : Window 
{
    wchar       theChar = 'A';
    RECT        outRect = { 0, 0, 20, 20 };
    float[ 25 ] timings = 0;
    float       fps     = 0;
    UINT_PTR    timer;
    HDC         canvas;
    Font        font    = { "Arial", 20 };


    this( int x, int y, int w, int h )
    {
        super( "GDIWindow", x, y, w, h );
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
        // Create an off-screen DC for double-buffering
        auto winWidth  = rect.right;
        auto winHeight = rect.bottom;

        canvas = CreateCompatibleDC( hdc );
        HDC hbmMem = CreateCompatibleBitmap( hdc, winWidth, winHeight );

        auto hOld = SelectObject( canvas, hbmMem );

        //
        paintMeter();

        // Transfer the off-screen DC to the screen
        BitBlt( hdc, 0, 0, winWidth, winHeight, canvas, 0, 0, SRCCOPY );

        // Free-up the off-screen DC
        SelectObject( canvas, hOld );

        DeleteObject( hbmMem );
        DeleteDC ( canvas );
    }


    void paintMeter()
    {
        auto hfont = toWindowsFont( canvas, font );
        SelectObject( canvas, hfont );

        FillRect( canvas, &rect, cast( HBRUSH ) ( COLOR_WINDOW + 1 ) ); // Clear

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


    void paint( HDC hdc )
    {
        // Glyph
        TextOut(
            hdc,
            outRect.left,
            outRect.top,
            cast( LPCWSTR ) &theChar,
            1
        );        
    }

    override 
    void onTimer()
    {
        repaint();
    }
}


struct Font
{
    string  face        = "Arial";
    uint    height      = 15;
    uint    orientation = 0;
    uint    weight      = 400; // FW_NORMAL
    bool    italic      = false;
    bool    underline   = false;
    bool    strikeout   = false;
}


HFONT toWindowsFont( HDC hdc, Font font ) 
{
    LOGFONT lf = {
                    lfEscapement      : 0,
                    lfOrientation     : font.orientation,
                    lfWeight          : font.weight ,
                    lfItalic          : font.italic,
                    lfUnderline       : font.underline,
                    lfStrikeOut       : font.strikeout,
                    lfCharSet         : DEFAULT_CHARSET,
                    lfOutPrecision    : OUT_DEFAULT_PRECIS,
                    lfClipPrecision   : CLIP_DEFAULT_PRECIS,
                    lfQuality         : DEFAULT_QUALITY,
                    lfPitchAndFamily  : FF_DONTCARE
                };

    lf.lfFaceName[ 0 .. font.face.length ] = font.face.toUTF16;        

    static const 
    int points_per_inch = 96; // for Windows
    int pixels_per_inch = GetDeviceCaps( hdc, LOGPIXELSY );

    lf.lfHeight = - ( font.height  * pixels_per_inch / points_per_inch );

    return CreateFontIndirect( &lf );
}
