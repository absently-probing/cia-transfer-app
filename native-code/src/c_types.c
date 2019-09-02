#include <stddef.h>
#include "c_types.h"

uint64_t get_size_of_size_t(void){
	return sizeof(size_t);
}

uint64_t get_size_of_int(void){
	return sizeof(int);
}

uint64_t get_size_of_unsigned_long_long(void){
	return sizeof(unsigned long long);
}

uint64_t get_size_of_unsigned_char(void){
	return sizeof(unsigned char);
}
