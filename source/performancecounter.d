/*
  Windows performance timer stuff
*/

long getPerformanceCounter()
{
    import core.sys.windows.windows;
    LARGE_INTEGER t;
    QueryPerformanceCounter(&t);
    return t.QuadPart;
}

long getPerformanceFrequency()
{
    import core.sys.windows.windows;
    LARGE_INTEGER f;
    QueryPerformanceFrequency(&f);
    return f.QuadPart;
}
   
