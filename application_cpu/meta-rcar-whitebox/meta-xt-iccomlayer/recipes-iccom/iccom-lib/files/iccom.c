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
#include "iccom.h"

#define ICCOM_DEV0		"/dev/iccom0"
#define ICCOM_DEV1		"/dev/iccom1"

#define TOTAL_CTA_SIZE		0x2000
#define ICCOM_BUF_MAX_SIZE	(TOTAL_CTA_SIZE/2) // Max size of each transaction (read/write)

static uint8_t tx_buff[ICCOM_BUF_MAX_SIZE];
static uint8_t rx_buff[ICCOM_BUF_MAX_SIZE];
static int fd = -1;

#if defined(USE_IOCTL)
int32_t R_ICCOM_Recive(
        const st_iccom_recive_param_t *pIccomRecive)
{
	int ret;
	struct iccom_ioctl_pkt ioctl_pkt;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (pIccomRecive->recive_size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Read buffer exceeds max allowed length\n");
		return -1;
	}

	ioctl_pkt.length = pIccomRecive->recive_size;
	ioctl_pkt.data = pIccomRecive->recive_buf;
	ret = ioctl(fd, ICCOM_IOCTL_READ, &ioctl_pkt);
	if (ret < 0) {
		err_printf("Ioctl failed in reading (%d)\n", ret);
		return ret;
	}

	return 0;
}

int32_t R_ICCOM_Send(const st_iccom_send_param_t *pIccomSend)
{
	int ret;
	struct iccom_ioctl_pkt ioctl_pkt;

	if (fd < 0) {
		err_printf("Library not initialized\n");
		return -1;
	}

	if (pIccomSend->send_size > ICCOM_BUF_MAX_SIZE) {
		err_printf("Write buffer exceeds max allowed length\n");
		return -1;
	}

	ioctl_pkt.length = pIccomSend->send_size;
	ioctl_pkt.data = pIccomSend->send_buf;
	ret = ioctl(fd, ICCOM_IOCTL_WRITE, &ioctl_pkt);
	if (ret < 0) {
		err_printf("Ioctl failed in writing (%d)\n", ret);
		return ret;
	}

	return 0;
}

#else //USE_IOCTL

int32_t R_ICCOM_Recive(
        const st_iccom_recive_param_t *pIccomRecive)
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

	read_data = read(fd, pIccomRecive->recive_buf, pIccomRecive->recive_size);
	if (read_data <= 0) {
		err_printf("No data read\n");
		return -1;
	}

	return 0;
}

int32_t R_ICCOM_Send(const st_iccom_send_param_t *pIccomSend)
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

	written_data = write(fd, pIccomSend->send_buf, pIccomSend->send_size);
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

int32_t R_ICCOM_Init(
        const st_iccom_usr_cfg_t* pusr_cfg,
        uint8_t num_of_channel,
        const st_iccom_usr_cfg_ch_t usr_cfg_ch[],
        const st_iccom_dev_settings_t dev_info[],
        Iccom_api_error_callback_t api_error_drv_cb)
{
	if (num_of_channel == 0) {
		fd = open(ICCOM_DEV0, O_RDWR);
		if (fd < 0) {
			err_printf("Initialization failed: unable to open %s\n", ICCOM_DEV0);
			return -1;
		}
	} else if (num_of_channel == 1) {
		fd = open(ICCOM_DEV1, O_RDWR);
		if (fd < 0) {
			err_printf("Initialization failed: unable to open %s\n", ICCOM_DEV1);
			return -1;
		}
	} else {
		return -1;
	}

	return 0;
}

int32_t R_ICCOM_Close(void)
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
