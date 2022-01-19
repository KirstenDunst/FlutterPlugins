/*
 * @Author: Cao Shixin
 * @Date: 2022-01-19 15:04:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-19 15:05:57
 * @Description: 
 */
#include <stdint.h>


extern "C"
{
    #include "bsdiff/bsdiff.h"

    // __attribute__((visibility("default"))) __attribute__((used))
    int32_t native_add(int32_t x, int32_t y) { return x + y; }

    int bsdiff(int argc, char *argv[])
    {
        return Bsdiff_bsdiff(argc, argv);
    };
    int bspatch(int argc, char *argv[])
    {
        return Bsdiff_bspatch(argc, argv);
    };
}