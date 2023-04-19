#ifndef _ICCOM_H_
#define _ICCOM_H_

#include <stdint.h>

//int32_t iccom_init(void);
//int32_t iccom_close(void);
//int32_t iccom_send_data(void* in_buff, size_t size);
//int32_t iccom_read_reply(void* output_buff, size_t size);

typedef uint64_t osal_thread_id_t;
typedef uint64_t osal_mutex_id_t;
typedef uint64_t osal_mq_id_t;
typedef int64_t osal_milli_sec_t;
typedef enum e_osal_thread_priority
{
    OSAL_THREAD_PRIORITY_TYPE0   = 0,   /*!< thread priority 0 */
    OSAL_THREAD_PRIORITY_LOWEST  = OSAL_THREAD_PRIORITY_TYPE0,  /*!< Lowest Priority */
    OSAL_THREAD_PRIORITY_TYPE1   = 1,   /*!< thread priority 1 */
    OSAL_THREAD_PRIORITY_TYPE2   = 2,   /*!< thread priority 2 */
    OSAL_THREAD_PRIORITY_TYPE3   = 3,   /*!< thread priority 3 */
    OSAL_THREAD_PRIORITY_TYPE4   = 4,   /*!< thread priority 4 */
    OSAL_THREAD_PRIORITY_TYPE5   = 5,   /*!< thread priority 5 */
    OSAL_THREAD_PRIORITY_TYPE6   = 6,   /*!< thread priority 6 */
    OSAL_THREAD_PRIORITY_TYPE7   = 7,   /*!< thread priority 7 */
    OSAL_THREAD_PRIORITY_TYPE8   = 8,   /*!< thread priority 8 */
    OSAL_THREAD_PRIORITY_TYPE9   = 9,   /*!< thread priority 9 */
    OSAL_THREAD_PRIORITY_TYPE10  = 10,  /*!< thread priority 10 */
    OSAL_THREAD_PRIORITY_TYPE11  = 11,  /*!< thread priority 11 */
    OSAL_THREAD_PRIORITY_TYPE12  = 12,  /*!< thread priority 12 */
    OSAL_THREAD_PRIORITY_TYPE13  = 13,  /*!< thread priority 13 */
    OSAL_THREAD_PRIORITY_TYPE14  = 14,  /*!< thread priority 14 */
    OSAL_THREAD_PRIORITY_HIGHEST = OSAL_THREAD_PRIORITY_TYPE14, /*!< Highest Priority */
} e_osal_thread_priority_t;
typedef enum e_osal_interrupt_priority
{
    OSAL_INTERRUPT_PRIORITY_TYPE0   = 0,  /*!< interrupt priority 0 */
    OSAL_INTERRUPT_PRIORITY_LOWEST  = OSAL_INTERRUPT_PRIORITY_TYPE0,    /*!< Lowest Priority */
    OSAL_INTERRUPT_PRIORITY_TYPE1   = 1,    /*!< interrupt priority 1 */
    OSAL_INTERRUPT_PRIORITY_TYPE2   = 2,    /*!< interrupt priority 2 */
    OSAL_INTERRUPT_PRIORITY_TYPE3   = 3,    /*!< interrupt priority 3 */
    OSAL_INTERRUPT_PRIORITY_TYPE4   = 4,    /*!< interrupt priority 4 */
    OSAL_INTERRUPT_PRIORITY_TYPE5   = 5,    /*!< interrupt priority 5 */
    OSAL_INTERRUPT_PRIORITY_TYPE6   = 6,    /*!< interrupt priority 6 */
    OSAL_INTERRUPT_PRIORITY_TYPE7   = 7,    /*!< interrupt priority 7 */
    OSAL_INTERRUPT_PRIORITY_TYPE8   = 8,    /*!< interrupt priority 8 */
    OSAL_INTERRUPT_PRIORITY_TYPE9   = 9,    /*!< interrupt priority 9 */
    OSAL_INTERRUPT_PRIORITY_TYPE10  = 10,   /*!< interrupt priority 10 */
    OSAL_INTERRUPT_PRIORITY_TYPE11  = 11,   /*!< interrupt priority 11 */
    OSAL_INTERRUPT_PRIORITY_TYPE12  = 12,   /*!< interrupt priority 12 */
    OSAL_INTERRUPT_PRIORITY_TYPE13  = 13,   /*!< interrupt priority 13 */
    OSAL_INTERRUPT_PRIORITY_TYPE14  = 14,   /*!< interrupt priority 14 */
    OSAL_INTERRUPT_PRIORITY_HIGHEST = OSAL_INTERRUPT_PRIORITY_TYPE14,   /*!< Highest Priority */
} e_osal_interrupt_priority_t;

typedef uint64_t address_t;
typedef void (*Iccom_recv_callback_t)(
        uint8_t channel_no,
        uint32_t recv_size,
        const uint8_t *recv_buf);

typedef void (*Iccom_error_callback_t)(
        uint8_t channel_no,
        int32_t error_code);

typedef enum e_iccom_channel_state
{
    ICCOM_CHANNEL_STATE_NOT_READY=0,    /*!< Channel is not ready for communication     */
    ICCOM_CHANNEL_STATE_READY           /*!< Channel is ready for communication         */
}e_iccom_channel_state_t;

typedef struct st_iccom_version {
   uint32_t major;              /*!< major version */
   uint32_t minor;              /*!< minor version */
   uint32_t patch;              /*!< patch version */
} st_iccom_version_t;

typedef struct Iccom_usr_cfg_t
{
    osal_thread_id_t            mgr_task_id;        /*!< thread id for manager task       */
    osal_thread_id_t            timer_task_id;      /*!< thread id for timer task         */
    osal_mutex_id_t             timer_mutex_id;     /*!< mutex id for timer               */
    osal_mutex_id_t             open_mutex_id;      /*!< mutex id for open channel        */
    osal_mq_id_t                mgr_task_mq_id;     /*!< mq id for open channel (Request) */
    osal_mq_id_t                open_mq_id;         /*!< mq id for open channel (Reply)   */
    osal_milli_sec_t            mutex_priod_time;   /*!< lock timeout for all mutexes (Recommendation value: 1000ms)  */
    osal_milli_sec_t            mqsend_wait_time;   /*!< send timeout of message queue (Recommendation value: 100ms)  */
    osal_milli_sec_t            mqrecv_wait_time;   /*!< receive timeout of message queue (Recommendation value: 100ms) */
    e_osal_thread_priority_t    task_priority;      /*!< task priority for all tasks                                  */
    e_osal_interrupt_priority_t irq_priority;       /*!< interrupt priority for all channels                          */
} st_iccom_usr_cfg_t;

typedef struct Iccom_usr_cfg_ch_t
{
    osal_thread_id_t recv_task_id;              /*!< thread id for receive task            */
    osal_thread_id_t read_task_id;              /*!< thread id for read task               */
    osal_thread_id_t send_task_id;              /*!< thread id for send task               */
    osal_mutex_id_t  write_mutex_id;            /*!< mutex id for data sending             */
    osal_mutex_id_t  read_mutex_id;             /*!< mutex id for data receiving           */
    osal_mq_id_t     senddata_upper_mq_id;      /*!< mq id for sending (Reply)             */
    osal_mq_id_t     senddata_bottom_mq_id;     /*!< mq id for sendjng (Reply)             */
    osal_mq_id_t     recvtask_mq_id;            /*!< mq id for receiving (Request)         */
    osal_mq_id_t     sendtask_mq_id;            /*!< mq id for sendjng (Request)           */
    osal_mq_id_t     readtask_mq_id;            /*!< mq id for sendjng and receiving (ISR) */
    osal_mq_id_t     senddata_mq_id;            /*!< mq id for sending (Send Data)         */
    osal_mq_id_t     recvdata_mq_id;            /*!< mq id for receiving (Receive Data)    */
    osal_mq_id_t     sendmsg_ack_mq_id;         /*!< mq id for sending (ACK)               */
    osal_mq_id_t     recvmsg_ack_mq_id;         /*!< mq id for receiving (ACK)             */
} st_iccom_usr_cfg_ch_t;

typedef struct Iccom_dev_settings_t
{
    address_t mfis_base_addr;           /*!< Base address of MFIS register  */
    uint32_t  mfis_iicr_offset;         /*!< Offset of MFISARIICRn register */
    uint32_t  mfis_eicr_offset;         /*!< Offset of MFISAREICRn register */
    uint32_t  mfis_imbr_offset;         /*!< Offset of MFISARIMBRn register */
    uint32_t  mfis_embr_offset;         /*!< Offset of MFISAREMBRn register */
    address_t cta_addr;                 /*!< Top address of CTA buffer      */
    uint32_t  interrupt_number;         /*!< SPI number                     */
    uint32_t  ack_timeout;              /*!< Timeout threshold for acknowledgment (ms)            */
    uint32_t  trigger_timeout;          /*!< Timeout threshold for interrupt trigger clear (ms)   */
    uint32_t  trigger_polling;          /*!< Interval for checking to clear interrupt trigger(us)
                                             Please specify a multiple of 1000.                   */
} st_iccom_dev_settings_t;

typedef void (*Iccom_api_error_callback_t)(
        uint8_t channel_no,
        const  uint8_t *api_name,
        int32_t api_error_code,
        const  uint8_t * func_name,
        uint32_t func_line);

typedef struct Iccom_init_param_t
{
    uint8_t                    channel_no;           /*!< Channel number                                             */
    Iccom_recv_callback_t      recv_cb;              /*!< Callback function pointer for data reception notification  */
    Iccom_error_callback_t     error_cb;             /*!< Callback function pointer for error notification           */
    Iccom_api_error_callback_t api_error_lib_cb;     /*!< Callback function pointer for OSAL API error notification  */
} st_iccom_init_param_t;

typedef void *iccom_channel_t;

typedef enum e_iccom_core
{
    AP_COREMODE,  /*!< ICCOM operates on AP-System Core     */
    RT_COREMODE   /*!< ICCOM operates on Arm Realtime Core  */
}e_iccom_core_t;

typedef struct Iccom_send_param_t
{
    iccom_channel_t channel_handle;  /*!< Channel handle            */
    uint32_t        send_size;       /*!< Send size                 */
    uint8_t         *send_buf;       /*!< Data send buffer pointer  */
} st_iccom_send_param_t;

typedef struct Iccom_recive_param_t
{
    iccom_channel_t channel_handle;  /*!< Channel handle                */
    uint32_t        recive_size;       /*!< Recive size                 */
    uint8_t         *recive_buf;       /*!< Data recive buffer pointer  */
} st_iccom_recive_param_t;


/*======================================================================================================================
Public global functions
======================================================================================================================*/
int32_t R_ICCOM_GetState(uint8_t channel_no, e_iccom_channel_state_t *channel_state);

const st_iccom_version_t* R_ICCOM_GetVersion(void);

int32_t R_ICCOM_Init(
        const st_iccom_usr_cfg_t* pusr_cfg,
        uint8_t num_of_channel,
        const st_iccom_usr_cfg_ch_t usr_cfg_ch[],
        const st_iccom_dev_settings_t dev_info[],
        Iccom_api_error_callback_t api_error_drv_cb);

int32_t R_ICCOM_Open(
        const st_iccom_init_param_t *pIccomInit,
        iccom_channel_t *pChannelHandle);

int32_t R_ICCOM_SelectCoreMode(e_iccom_core_t core_mode);

int32_t R_ICCOM_Send(
        const st_iccom_send_param_t *pIccomSend);

int32_t R_ICCOM_SetBuffSize(
        uint32_t buff_size );

int32_t R_ICCOM_Recive(
        const st_iccom_recive_param_t *pIccomRecive);

int32_t R_ICCOM_Close(void);
#endif //_ICCOM_H_
