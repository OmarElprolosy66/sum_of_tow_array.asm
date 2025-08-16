# Array Sum with Threads (x64 Assembly)

This project demonstrates parallel array summation using x64 assembly language and Windows threads. It creates two arrays, fills them with random numbers, and calculates their sums using separate threads.

## Features

- Random number generation for array initialization
- Parallel processing using Windows threads
- Array manipulation in x64 assembly
- Structured output formatting

## Program Flow

1. **Initialization**
   - Creates two arrays of size 10
   - Fills arrays with random numbers (0-9)
   - Displays the contents of both arrays

2. **Threading**
   - Creates two threads, each responsible for summing one array
   - Uses Windows thread API (CreateThread, WaitForSingleObject)
   - Thread parameters passed using custom structure

3. **Results**
   - Displays sum of first array
   - Displays sum of second array
   - Shows total sum of both arrays

## Prerequisites

- Windows operating system
- ML64 assembler (part of Visual Studio)
- Required Windows libraries:
  - kernel32.lib
  - user32.lib
  - msvcrt.lib
  - ucrt.lib
  - vcruntime.lib
  - legacy_stdio_definitions.lib

## Building

1. Open Developer Command Prompt for VS (this is important as it sets up the correct environment variables)
2. Navigate to project directory
3. Assemble and link with ML64:
   ```batch
   ml64 /c main.asm
   link main.obj /ENTRY:main /SUBSYSTEM:CONSOLE ^
   /LIBPATH:"%VCINSTALLDIR%\lib\x64" ^
   /LIBPATH:"%WindowsSdkDir%lib\%WindowsSDKVersion%\ucrt\x64" ^
   /LIBPATH:"%WindowsSdkDir%lib\%WindowsSDKVersion%\um\x64" ^
   kernel32.lib user32.lib msvcrt.lib ucrt.lib vcruntime.lib legacy_stdio_definitions.lib
   ```

Note: The Visual Studio Developer Command Prompt automatically sets up the required environment variables:
- `%VCINSTALLDIR%` - Points to Visual Studio C++ installation
- `%WindowsSdkDir%` - Points to Windows SDK installation
- `%WindowsSDKVersion%` - Windows SDK version

## Structure

- `threadParameter`: Structure for passing data to threads
- Main procedures:
  - `main`: Program entry point
  - `getRand`: Random number generator
  - `fillArray`: Array initialization
  - `printArray`: Array output formatting
  - `sumArrThread`: Thread procedure