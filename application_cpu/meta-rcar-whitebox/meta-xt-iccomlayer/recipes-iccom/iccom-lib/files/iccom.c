#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <time.h>
#include <pthread.h>
#include <sys/ioctl.h>
#include "util.h"
#include "iccom_ioctl.h"

#define ICCOM_DEV		"/dev/iccom0"

#define TOTAL_CTA_SIZE		0x4000
#define ICCOM_BUF_MAX_SIZE	(TOTAL_CTA_SIZE/2) // Max size of each transaction (read/write)

static uint8_t tx_buff[ICCOM_BUF_MAX_SIZE];
static uint8_t rx_buff[ICCOM_BUF_MAX_SIZE];
static int fd = -1;

#if defined(USE_IOCTL)
int32_t iccom_read_reply(void* output_buff, size_t size)
{
	int ret;
	struct iccom_ioctl_pkt ioctl_pkt;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Read buffer exceeds max allowed length\n");
		return -1;
	}

	ioctl_pkt.length = size;
	ioctl_pkt.data = output_buff;

	ret = ioctl(fd, ICCOM_IOCTL_READ, &ioctl_pkt);
	if (ret < 0) {
		err_printf("Ioctl failed in reading (%d)\n", ret);
		return ret;
	}

	return 0;
}

int32_t iccom_send_data(void* in_buff, size_t size)
{
	int ret;
	struct iccom_ioctl_pkt ioctl_pkt;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Write buffer exceeds max allowed length\n");
		return -1;
	}

	ioctl_pkt.length = size;
	ioctl_pkt.data = in_buff;

	ret = ioctl(fd, ICCOM_IOCTL_WRITE, &ioctl_pkt);
	if (ret < 0) {
		err_printf("Ioctl failed in writing (%d)\n", ret);
		return ret;
	}

	return 0;
}

#else //USE_IOCTL

int32_t iccom_read_reply(uint64_t timeout_ms,
					void* output_buff, size_t size)
{
	ssize_t read_data = 0;
	int ret;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Read buffer exceeds max allowed length\n");
		return -1;
	}

	read_data = read(fd, output_buff, size);
	if (read_data <= 0) {
		err_printf("No data read\n");
		return -1;
	}

	return 0;
}

int32_t iccom_send_data(void* in_buff, size_t size)
{
	ssize_t written_data = 0;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Write buffer exceeds max allowed length\n");
		return -1;
	}

	written_data = write(fd, in_buff, size);
	if (written_data <= 0) {
		err_printf("No data written\n");
		return -1;
	}
	if (written_data != size) {
		err_printf("Asked to write %lu bytes, but only written %lu\n",
				size, written_data);
		return -1;
	}

	return 0;
}
#endif //USE_IOCTL

int32_t iccom_init()
{
	fd = open(ICCOM_DEV, O_RDWR);
	if (fd < 0) {
		err_printf("Initialization failed: unable to open %s\n", ICCOM_DEV);
		return -1;
	}

	return 0;
}

int32_t iccom_close(void)
{
	if (fd > 0) {
		close(fd);
		fd = -1;
	}

	return 0;
}

int iccom_driver_init( void )
{
	return 0;
}
