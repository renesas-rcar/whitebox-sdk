#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <time.h>

#include "iccom.h"
#include "iccom_commands.h"
#include "util.h"

#define NS_IN_MS	(1000*1000)
#define MS_IN_S		1000
#define NS_IN_S		(NS_IN_MS * MS_IN_S)

static int iteration_count_flag = 1;
static int size_flag = 1;

void print_help(int argc, char **argv)
{
	printf("Usage: %s [-s|-c]\n", argv[0]);
	printf("	-c: number of iterations to test\n");
	printf("	-s: size of each iteration (command + reply)\n");
}

static int parse_input_args(int argc, char **argv)
{
	int c;
	
	while ((c = getopt(argc, argv, "c:s:")) != -1) {
		switch (c) {
		case 'c':
			iteration_count_flag = strtoul(optarg, NULL, 10);
			break;
		case 's':
			size_flag = strtoul(optarg, NULL, 10);
			break;
		case '?':
			print_help(argc, argv);
			return -1;
		}
	}

	if ( iteration_count_flag < 1 ) {
		err_printf("iteration count cannot (%d) be less than 1\n", iteration_count_flag);
		return -1;
	}
	if ((size_flag < 1) || (size_flag > MAX_ECHO_DATA_SIZE)) {
		err_printf("invalid size %d; values must be in range %d - %ld\n",
				size_flag, 1, MAX_ECHO_DATA_SIZE);
		return -1;
	}
	
	return 0;
}

int main(int argc, char **argv)
{
	int ret = 0;
	int curr_iter;
	struct echo_command cmd = {
		.cmd_id = ECHO,
	};
	struct echo_reply reply;
	size_t pkt_size;
	struct timespec start_time, end_time;
	uint64_t elapsed_ms;
	uint64_t transferred_data;
	

	ret = parse_input_args(argc, argv);
	if (ret) {
		return ret;
	}

	ret = iccom_init();
	if (ret != 0 ) {
		err_printf("iccom_init error\n");
		return ret;
	}

	ret = clock_gettime(CLOCK_MONOTONIC, &start_time);
	if (ret < 0) {
		err_printf("clock_gettime failed at start\n");
		return ret;
	}

	cmd.cmd_id = ECHO;
	for (curr_iter = 0; curr_iter < iteration_count_flag; curr_iter++) {
		// set all the data to the save value (and change it for
		// every iteration
		memset(cmd.data, (curr_iter & 0xFF), size_flag);
		// always take "cmd_id" into account for the size
		pkt_size = size_flag + sizeof(uint8_t);

		ret = iccom_send_data(&cmd, pkt_size);
		if (ret < 0) {
			err_printf("iccom_send_data failed at iteration %d\n", curr_iter + 1);
			return ret;
		}
		ret = iccom_read_reply(&reply, pkt_size);
		if (ret < 0) {
			err_printf("iccom_wait_for_reply_with_timeout failed at iteration %d\n", curr_iter + 1);
			return ret;
		}
		if (memcmp(&cmd, &reply, pkt_size) != 0) {
			err_printf("memcmp failed at iteration %d\n", curr_iter + 1);
			return ret;
		}
	}

	ret = clock_gettime(CLOCK_MONOTONIC, &end_time);
	if (ret < 0) {
		err_printf("clock_gettime failed at end\n");
		return ret;
	}

	iccom_close();

	if (end_time.tv_nsec >= start_time.tv_nsec) {
		elapsed_ms = (end_time.tv_nsec - start_time.tv_nsec) / NS_IN_MS;
	} else {
		elapsed_ms = (NS_IN_S + start_time.tv_nsec - end_time.tv_nsec) / NS_IN_MS;
	}
	elapsed_ms += (end_time.tv_sec - start_time.tv_sec) * MS_IN_S;
	transferred_data = size_flag * iteration_count_flag;

	fprintf(stdout, "Elapsed time [ms]: %ld\n", elapsed_ms);
	fprintf(stdout, "Data transfered: %ld\n", transferred_data);
	fprintf(stdout, "Throughput: %ld bytes/s\n", (transferred_data * 1000)/(elapsed_ms));

	return ret;
}
