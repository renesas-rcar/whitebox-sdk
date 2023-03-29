#ifndef _ICCOM_H_
#define _ICCOM_H_

#include <stdint.h>

int32_t iccom_init(void);
int32_t iccom_close(void);
int32_t iccom_send_data(void* in_buff, size_t size);
int32_t iccom_read_reply(void* output_buff, size_t size);

#endif //_ICCOM_H_
