/*
* This is a minimal example which serves only to show how to use FreeType in
* a D program through the DerelictFT binding. It is not intended to be an FreeType
* tutorial, nor is it intended to be a D tutorial. You need not compile this
* example, as it doesn't do anything. It only shows you what you need to do in
* your own applications to make use of DerelictFT.
*
* To compile the example, you will need to make sure that the DerelictFT and
* DerelictUtil import modules are on the import path for your D compiler. If you
* do not know how to do so, please refer to your D compiler's documentation to
* learn how.
*
* To link the example, you will need the DerelictFT and DerelictUtil library
* files on your library path. If you do not know how to do so, please refer to
* your D compiler's documentation to learn how.
*
* It is recommended that you use Derek Parnell's Build Utility to build this
* example. You can refer to build.html in the Derelict documentation to learn
* how to obtain Build if you do not have it already.
*/

// Any module which calls FreeType functions must import derelict.freetype.ft
import derelict.freetype.ft;

// Any module which uses Derelict exceptions must import derelict.util.exception
import derelict.util.exception;

import std.io;		// for writefln()

/* 
* The following pragma statements link with the appropriate Derelict libraries
* for each supported platform. You do not need to use these statements to
* use DerelictFT. You can pass the library names to the command line instead.
* These are inclused in the example to make clear which libraries you need
* to link with to use DerelictFT. Note that these are DMD-specific and may
* not work on other D compilers. If you use a different compiler (such as GDC),
* check the doumentation to see if these pragmas are supported.
*/
version(Windows)
{
	// Using DMD on Windows, we need derelictUtil.lib and derelictFT.lib
	pragma(lib, "derelict.lib");
	//pragma(lib, "derelictFT.lib");
	
} 
else version(linux)
{
	// Using DMD on Windows, we need libderelictUtil.a and libderelictFT.a
	pragma(lib, "libderelictUtil.a");
	pragma(lib, "libderelictFT.a");
}
else
{
	// Other platforms are not currently supported.
	static assert(0);
}

void main()
{
	/*
	* Before you can use any FreeType functions, you *must* load the FreeType
	* shared library via a call to DerelictFT_Load. DerelictFT_Load throws two
	* types of exceptions, both of which extend from DerelictException. This
	* example shows how to catch those exceptions in case you do not want them
	* passing up to the default exception handler. See the DerelictUtil 
	* documentation (docs/util.html) for more details.
	*/
	try
	{		
		
		// Load the DevIL shared library
		DerelictFT.load();
	}
	catch(SharedLibLoadException slle)
	{
		/*
		* This exception indicates that the shared library could not be loaded
		* from disk. The most likely cause is that it is not on the system
		* search path. Normally you would display a message box to the user,
		* informing them what to do about the error. Here, we'll just rethrow
		* the exception since this is just an example.
		*/
		throw slle;
	}
	catch(SharedLibProcLoadException slple)
	{
		/*
		* This exception indicates that a specific symbol (exported function
		* or variable) could not be loaded from the shared library. The library
		* itself exists and was loaded from disk, but it may be corrupt, or
		* an older version, or maybe it was compiled without exporting a specific
		* symbol. In any case, a symbol failed to load. This exception can be
		* selectively thrown by using a MissingProcCallback (see the Derelict
		* documentation for Selective Symbol Exceptions - docs/selective.html).
		* Normally you would display a message box to the user, informing them
		* what do to about the error. Here, we'll just rethrow the exception
		* since this is just an example.
		*/
		throw slple; 
	}
	
	// announce that DevIL was loaded successfully
	writefln("Successfully loaded the FreeType shared library.");
	
	/*
	* From this point on, you may call DevIL functions as normal. When the
	* application exits, DerelictIL will automatically unload the DevIL shared
	* library, so you don't need to worry about it.
	*/
	
}