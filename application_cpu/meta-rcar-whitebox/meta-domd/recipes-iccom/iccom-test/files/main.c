/*
 * SPDX-License-Identifier: MIT
 *
 * iccom-test application(main.c)
 *
 * Copyright (c) 2023 Renesas Electronics Corporation
 *
 * Benchmark scheme
 * ------------------------------------------------------------------------------
 *
 *                     Cortex-A55                                     G4MH
 *   +----------------+         +----------------+             +----------------+
 *   | iccom-test     |         | ICCOM driver   |             | ICCOM driver   |
 *   +----------------+         +----------------+             +----------------+
 *           |                          |                               |
 *           +--+                       |                               |
 *           |  | Start Timer           |                               |
 *           |<-+                       |                               |
 *           |                          |                               |
 *       +-->|                          |                               |
 *       |   | Write Request            |                               |
 *       |   +------------------------->|                               |
 *       |   |                          | Send packet                   |
 *       |   |                          |------------------------------>|
 *       |   |                          |                               |--+
 *  Loop |   |                          |                               |  | Read Packet
 *       |   |                          |                               |<-+
 *       |   |                          |                      Send ACK |
 *       |   |                          |<------------------------------|
 *       |   |              Send Result |                               |
 *       |   |<-------------------------|                               |
 *       +---|                          |                               |
 *           |--+                       |                               |
 *           |  | Stop TImer            |                               |
 *           |<--                       |                               |
 *           |                          |                               |
 *           v                          v                               v
 *
 * Throughput: = (Packet Size * LoopNum) / elappsed_time
 * ------------------------------------------------------------------------------
 */

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
#define OS_SIZE		10

static int iteration_count_flag = 1;
static int size_flag = 1;
static int bench_flag = 0;
static int cpu_type = 0;
static int os_type = 0;
struct cpu_name_t {
	uint8_t cpu_name[10];
};

void print_help(int argc, char **argv)
{
	printf("Usage: %s [-s|-c|-b|-r|-v|-h]\n", argv[0]);
	printf("	-b: enable benchmark mode(default is test mode)\n");
	printf("	-c: number of iterations to test\n");
	printf("	-s: size of each iteration\n");
	printf("	-r: enable iccom channel CR-52(default is G4MH) \n");
	printf("        -v: check OS type\n");
	printf("	-h: show this help\n");
}

static int parse_input_args(int argc, char **argv)
{
	int c;
	
	while ((c = getopt(argc, argv, "c:s:brvh")) != -1) {
		switch (c) {
		case 'r':
			cpu_type = 1;
			break;
		case 'c':
			iteration_count_flag = strtoul(optarg, NULL, 10);
			break;
		case 's':
			size_flag = strtoul(optarg, NULL, 10);
			break;
		case 'b':
			bench_flag = 1;
			break;
		case 'v':
			os_type = 1;
			break;
		case 'h':
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
	struct cpu_name_t cpu[2] = {
		{"G4MH"},
		{"Cortex-R52"}
	};
	struct echo_reply reply;
	size_t pkt_size;
	struct timespec start_time, end_time;
	uint64_t elapsed_ms;
	uint64_t transferred_data;
	int err_cnt = 0;
	st_iccom_send_param_t send_param;
	st_iccom_recive_param_t recive_param;

	ret = parse_input_args(argc, argv);
	if (ret) {
		return ret;
	}

	ret = R_ICCOM_Init(NULL, cpu_type, NULL, NULL, NULL);
	if (ret != 0 ) {
                printf("%s is not running or doesn't reply message...\n",cpu[cpu_type].cpu_name);
		return ret;
	}

	if (os_type) { // get OS mode
		cmd.cmd_id = OS;
                // always take "cmd_id" into account for the size
                pkt_size = OS_SIZE + sizeof(uint8_t);

                send_param.send_buf = (uint8_t *)&cmd;
                send_param.send_size = pkt_size;
                ret = R_ICCOM_Send(&send_param);
                if (ret < 0) {
                        err_printf("R_ICCOM_Send failed at iteration %d\n", curr_iter + 1);
                        R_ICCOM_Close();
                        return ret;
                }
                recive_param.recive_buf = (uint8_t *)&reply;
                recive_param.recive_size = pkt_size;
                ret = R_ICCOM_Recive(&recive_param);
                if (ret < 0) {
                        err_printf("R_ICCOM_Recive failed at iteration %d\n", curr_iter + 1);
                        R_ICCOM_Close();
                        return ret;
                }
		printf("%s OS is running on %s\n", (uint8_t *)&reply, cpu[cpu_type].cpu_name);
	} else if (!bench_flag) { // Test mode(echo back mode)
		cmd.cmd_id = ECHO;
		for (curr_iter = 0; curr_iter < iteration_count_flag; curr_iter++) {
			// set all the data to the save value (and change it for
			// every iteration
			memset(cmd.data, (curr_iter & 0xFF), size_flag);
			// always take "cmd_id" into account for the size
			pkt_size = size_flag + sizeof(uint8_t);
	
			send_param.send_buf = (uint8_t *)&cmd;
			send_param.send_size = pkt_size;
			ret = R_ICCOM_Send(&send_param);
			if (ret < 0) {
				err_printf("R_ICCOM_Send failed at iteration %d\n", curr_iter + 1);
				R_ICCOM_Close();
				return ret;
			}
			recive_param.recive_buf = (uint8_t *)&reply;
			recive_param.recive_size = pkt_size;
			ret = R_ICCOM_Recive(&recive_param);
			if (ret < 0) {
				err_printf("R_ICCOM_Recive failed at iteration %d\n", curr_iter + 1);
				R_ICCOM_Close();
				return ret;
			}
			if (memcmp(&cmd, &reply, pkt_size) != 0) {
				err_printf("memcmp failed at iteration %d\n", curr_iter + 1);
				R_ICCOM_Close();
				return ret;
			}
		}
		printf("ICCOM test is OK\n");
	} else { // benchmark
		cmd.cmd_id = NONE;
		ret = clock_gettime(CLOCK_MONOTONIC, &start_time);
		if (ret < 0) {
			err_printf("clock_gettime failed at start\n");
			return ret;
		}

		for (curr_iter = 0; curr_iter < iteration_count_flag; curr_iter++) {
			// set all the data to the save value (and change it for
			// every iteration
			memset(cmd.data, (curr_iter & 0xFF), size_flag);
			// always take "cmd_id" into account for the size
			pkt_size = size_flag + sizeof(uint8_t);

			do{
				send_param.send_buf = (uint8_t *)&cmd;
				send_param.send_size = pkt_size;
				ret = R_ICCOM_Send(&send_param);
				if (ret < 0) {
					//err_printf("R_ICCOM_Send failed at iteration %d\n", curr_iter + 1);
					// return ret;
					err_cnt++;
				}
				//usleep(1);
			}while(ret < 0);
		}

		ret = clock_gettime(CLOCK_MONOTONIC, &end_time);
		if (ret < 0) {
			err_printf("clock_gettime failed at end\n");
			return ret;
		}

		if (end_time.tv_sec > start_time.tv_sec) {
			elapsed_ms = (NS_IN_S + end_time.tv_nsec - start_time.tv_nsec) / NS_IN_MS;
			end_time.tv_sec--;
		} else {
			elapsed_ms = (end_time.tv_nsec - start_time.tv_nsec) / NS_IN_MS;
		}
		elapsed_ms += (end_time.tv_sec - start_time.tv_sec) * MS_IN_S;
		transferred_data = (1+size_flag) * iteration_count_flag; // packet contains command-part(1byte)
	
		fprintf(stdout, "Elapsed time [ms]: %ld\n", elapsed_ms);
		fprintf(stdout, "Data transfered: %ld\n", transferred_data);
		fprintf(stdout, "Throughput: %ld bytes/s\n", (transferred_data * 1000)/(elapsed_ms));
		fprintf(stdout, "Throughput: %1.2f MB/s\n", (transferred_data * 1000)/(elapsed_ms)/1024.0/1024.0);
		fprintf(stdout, "Error count: %d\n", (err_cnt));
	}

	R_ICCOM_Close();

	return ret;
}
