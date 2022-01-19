cmake_minimum_required(VERSION 3.4.1)  # for example

add_library( native_add

    # Sets the library as a shared library.
    SHARED

    # Provides a relative path to your source file(s).
    ../ios/Classes/native_add.cpp
    ../ios/Classes/bsdiff/bsdiff.c
    ../ios/Classes/bsdiff/bspatch.c
    ../ios/Classes/bsdiff/bsdiff.h
    ../ios/Classes/bzip2/blocksort.c
    ../ios/Classes/bzip2/bzip2.c
    ../ios/Classes/bzip2/bzip2.h
    ../ios/Classes/bzip2/bzip2recover.c
    ../ios/Classes/bzip2/bzlib_private.h
    ../ios/Classes/bzip2/bzlib.c
    ../ios/Classes/bzip2/bzlib.h
    ../ios/Classes/bzip2/compress.c
    ../ios/Classes/bzip2/crctable.c
    ../ios/Classes/bzip2/decompress.c
    ../ios/Classes/bzip2/dlltest.c
    ../ios/Classes/bzip2/huffman.c
    ../ios/Classes/bzip2/mk251.c
    ../ios/Classes/bzip2/randtable.c
    ../ios/Classes/bzip2/spewG.c
    ../ios/Classes/bzip2/unzcrash.c )