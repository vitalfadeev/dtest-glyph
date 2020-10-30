import core.sys.windows.windows;
import render.gdi     : GDIWindow;
import render.dg2d    : Dg2dWindow;
import ui.window      : Window;


class Tester
{
    int        stage;
    GDIWindow  gdiWindow;
    Dg2dWindow dg2dWindow;


    void start()
    {
        next();
        eventLoop();
    }


    void next()
    {
        stage++;

        switch ( stage )
        {
            case 1:
                gdiWindow = new GDIWindow( 0, 0, 400, 300 );
                break;
            case 2:
                dg2dWindow = new Dg2dWindow( 490, 0, 400, 300 );
                break;
            default:
                stop();
        }
    }


    void stop()
    {
        PostQuitMessage( 0 );
    }
}


void eventLoop()
{
    MSG msg;

    while ( GetMessage( &msg, NULL, 0, 0 ) )
    {
        TranslateMessage( &msg );
        DispatchMessage( &msg );
    }
}


