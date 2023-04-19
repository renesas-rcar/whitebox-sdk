#ifndef _UTIL_H_
#define _UTIL_H_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#define ARRAY_SIZE(x)		(sizeof(x)/sizeof(x[0]))

#if defined(DEBUG_PRINT_ENABLED)
	#define dbg_printf(...)		printf(__VA_ARGS__)
#else
	#define dbg_printf(...)
#endif

#define err_printf(...)		fprintf(stderr, "[Error] " __VA_ARGS__)

#endif //_UTIL_H_
