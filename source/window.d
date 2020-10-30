module ui.window;
    
import core.sys.windows.windows;
//import cerealed;
import std.path      : dirName, baseName;
import std.format    : format;
import std.conv      : to;
import std.algorithm : find;
import std.algorithm : countUntil;
import std.range     : empty;
import std.string    : isNumeric;
import std.array     : join;
import std.string    : splitLines;
import std.string    : toLower;
import std.stdio     : writeln;
import std.stdio     : writefln;
static import std.file;
import ui.utf        : toLPWSTR;
import ui.tools      : GET_X_LPARAM;
import ui.tools      : GET_Y_LPARAM;
import ui.tools      : classBaseName;
import ui.tools      : frontOrNull;

pragma( lib, "user32.lib" );
pragma( lib, "gdi32.lib" ); 


class Window
{
    HWND     hwnd;
    string   windowName = "ui window";
    WNDCLASS wc;
    RECT     rect;


    this( string windowName, int x, int y, int w, int h )
    {
        this.windowName = windowName;
        rect = RECT( x, y, x + w, y + h );
        _createWindowClass();
        _createWindow();
    }


    void repaint()
    {
        InvalidateRect( hwnd, null, 0 );
    }


    void repaint( int x0, int y0, int x1, int y1 )
    {
        RECT rect;
        rect.left   = x0;
        rect.top    = y0;
        rect.right  = x1;
        rect.bottom = y1;

        InvalidateRect( hwnd, &rect, FALSE );
    }


    // Events
    void onCreated()
    {
        //
    }

    void onClose()
    {
        PostQuitMessage( 0 );
    }

    void onPaint( HDC hdc )
    {
        //
    }

    void onTimer()
    {
        //
    }



private:
    void _createWindowClass()
    {
        auto classname = ( baseName( std.file.thisExePath ) ~ "-" ~ windowName ).toLPWSTR;

        if ( GetClassInfo( GetModuleHandle( NULL ), classname, &wc ) )
        {
            // class exists
            throw new Exception( "Error when window class creation: class exists: " ~ classname.to!string );
        }
        else
        {
            wc.style         = CS_HREDRAW | CS_VREDRAW;
            wc.lpfnWndProc   = &UIWindowProc;
            wc.cbClsExtra    = 0;
            wc.cbWndExtra    = 0;
            wc.hInstance     = GetModuleHandle( NULL );
            wc.hIcon         = LoadIcon( NULL, IDI_APPLICATION );
            wc.hCursor       = LoadCursor( NULL, IDC_ARROW );
            wc.hbrBackground = NULL;
            wc.lpszMenuName  = NULL;
            wc.lpszClassName = classname;

            if ( !RegisterClass( &wc ) )
                throw new Exception( "Error when window class creation" );
        }
    }


    HWND _createWindow()
    {
        enum DWORD STYLE_NORMAL    = ( WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX );
        enum DWORD STYLE_RESIZABLE = ( WS_THICKFRAME | WS_MAXIMIZEBOX );

        DWORD style = STYLE_NORMAL | STYLE_RESIZABLE;
        DWORD styleEx = 0;

        RECT wrect = rect;     // Bordered Rectamgle
        AdjustWindowRectEx( &wrect, style, false, styleEx );

        //
        hwnd = 
            CreateWindowEx( 
                styleEx, 
                wc.lpszClassName,         // window class name
                windowName.toLPWSTR,      // window caption
                style,                    //  0x00000008
                wrect.left,               // initial x position
                wrect.top,                // initial y position
                wrect.right - wrect.left, // initial x size
                wrect.bottom - wrect.top, // initial y size
                NULL,                     // parent window handle
                NULL,                     // window menu handle
                GetModuleHandle( NULL ),  // program instance handle
                NULL
            );

        _rememberWindow( hwnd, this );

        ShowWindow( hwnd, SW_NORMAL );
        UpdateWindow( hwnd );

        onCreated();

        return hwnd;
    }


    // Windows Created by UI
    static Window[ HWND ] windows;

    static
    void _rememberWindow( HWND hwnd, Window window )
    {
        windows[ hwnd ] = window;
    }

    static
    auto _recallWindow( HWND hwnd )
    {
        return hwnd in windows;
    }


    static
    auto _forgetWindow( HWND hwnd )
    {
        windows.remove( hwnd );
    }


    // Default Window Proc
    static extern ( Windows )
    LRESULT UIWindowProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) nothrow
    {
        HDC hdc;
        PAINTSTRUCT ps;

        auto window = _recallWindow( hwnd );
        if ( window )
        {
            switch ( message )
            {
                case WM_DESTROY: {
                    _forgetWindow( hwnd );
                    return 0;
                }
                    
                case WM_PAINT: {
                    version ( DoubleBuffer )
                    {
                        hdc = BeginPaint( hwnd, &ps );

                        // Create an off-screen DC for double-buffering
                        auto winWidth  = window.rect.width;
                        auto winHeight = window.rect.height;

                        HDC hdcMem = CreateCompatibleDC( hdc );
                        HDC hbmMem = CreateCompatibleBitmap( hdc, winWidth, winHeight );

                        auto hOld = SelectObject( hdcMem, hbmMem );


                        // Drawing
                        try {
                            window.onPaint( hdc );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }


                        // Transfer the off-screen DC to the screen
                        BitBlt( hdc, 0, 0, winWidth, winHeight, hdcMem, 0, 0, SRCCOPY );

                        // Free-up the off-screen DC
                        SelectObject( hdcMem, hOld );

                        DeleteObject( hbmMem );
                        DeleteDC ( hdcMem );

                        EndPaint( hwnd, &ps );
                    }
                    else // Single Buffer
                    {
                        hdc = BeginPaint( hwnd, &ps );

                        // Drawing

                        try {
                            window.onPaint( hdc );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }

                        EndPaint( hwnd, &ps );
                    }

                    return 0;
                }
                    
                case WM_KEYDOWN: {
                    try {
                        //
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }

                case WM_TIMER: {
                    try {
                        window.onTimer(); 
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    break;
                }
                    
                case WM_CLOSE: {
                    try {
                        window.onClose(); 
                        DestroyWindow( hwnd );
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }
                    
                default:
            }
        }

        return DefWindowProc( hwnd, message, wParam, lParam );
    }
}


///
unittest
{
    class MyWindow : Window 
    {
        this( int x, int y, int w, int h )
        {
            super( x, y, w, h );
        }


        override
        void onPaint( HDC hdc )
        {
            //
        }
    }

    auto mw = new MyWindow( 0, 0, 800, 600 );
}

