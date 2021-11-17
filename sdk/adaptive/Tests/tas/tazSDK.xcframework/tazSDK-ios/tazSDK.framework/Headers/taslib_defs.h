#ifndef __taslib_defs_h_included__
#define __taslib_defs_h_included__

#ifdef __cplusplus
#include <string>
#include <map>
extern "C"
{
#endif


#define ADDITIONAL_DATA_MAX_LENGTH 4095
#define RA_RISK_ASSESSMENT_RECOMMENDATION_MAX_LENGTH 256
#define RA_RISK_ASSESSMENT_RESOLUTION_ID_MAX_LENGTH 64
#define RA_RISK_ASSESSMENT_REASON_MAX_LENGTH 1024

#define TAS_API
    
////////////////////////////////////////////// General data types //////////////////////////////////////////////

/**
 *\brief Error codes
 */
typedef int TAS_RESULT;

#define TAS_RESULT_SUCCESS                            0 /**< \brief Success */
#define TAS_RESULT_GENERAL_ERROR                     -1 /**< \brief General Error */
#define TAS_RESULT_INTERNAL_ERROR                    -2 /**< \brief Internal Error */
#define TAS_RESULT_WRONG_ARGUMENTS                   -3 /**< \brief Wrong Arguments */
#define TAS_RESULT_DRA_ITEM_NOT_FOUND                -4 /**< \brief DRA Item Not Found */
#define TAS_RESULT_NO_POLLING                        -5 /**< \brief Tried to use polling when configured to non-polling */
#define TAS_RESULT_TIMEOUT                           -6 /**< \brief Timeout */
#define TAS_RESULT_NOT_INITIALIZED                   -7 /**< \brief A component has not been initialized or configured  */
#define TAS_RESULT_UNAUTHORIZED                      -8 /**< \brief Unauthorized */
#define TAS_RESULT_ALREADY_INITIALIZED               -9 /**< \brief Already initialized */
#define TAS_RESULT_ARCH_NOT_SUPPORTED               -10 /**< \brief Device's architecture is not supported */
#define TAS_RESULT_INTERNAL_EXCEPTION               -11 /**< \brief Internal exception occurred */
#define TAS_RESULT_INCORRECT_SETUP                  -12 /**< \brief Could not initialize: requested operating mode's requirements were not fulfilled */
#define TAS_RESULT_INSUFFICIENT_PERMISSIONS         -13 /**< \brief Could not initialize: required permissions are not granted by the user */
#define TAS_RESULT_MISSING_PERMISSIONS_IN_FOLDER    -14 /**< \brief Could not initialize: missing permissions in the sdk folder */
#define TAS_RESULT_DISABLED_BY_CONFIGURATION        -15 /**< \brief Could not initialize: disabled by configuration */
#define TAS_RESULT_NETWORK_ERROR                    -16 /**< \brief Network Error */
#define TAS_RESULT_CONNECTION_INTERNAL_TIMEOUT      -17 /**< \brief Connection opened but closed because of connection read/write timeout. By default the timeout is 5 seconds. The timeout value can be                                                                set in the configuration file and put under pinpoint_integration.request_timeout_ms*/
#define TAS_RESULT_PINPOINT_CERTIFICATE_PROBLEM     -18 /**< \brief This error occurs when the certificate or certificate password is wrong or if the license expired*/
#define TAS_RESULT_INVALID_CONFIGURATION            -19 /**< \brief Invalid Configuration*/

#define TAS_EXCEPTION_CALLBACK_KEY                    1 /**< \brief Signal exception callback */
#define TAS_OVERLAY_CALLBACK_KEY                      2 /**< \brief Overlay detection callback (Android only) */
#define TAS_EXTERNAL_NET_CALLBACK_KEY                 3 /**< \brief External network communication callback */
#define TAS_ACCESSIBILITY_CALLBACK_KEY                4 /**< \brief Accessibility detection callback (Android only) */

    
////////////////////////////////////////////// Client management //////////////////////////////////////////////
    
/**
 * \brief A TAS object handle.
 * \ingroup ObjectAccess
 */
typedef void *TAS_OBJECT;

/**
 * \defgroup TasManagement TAS Client Management
 */

/**
 * \brief Initialization options for the TAS library.
 *
 * \ingroup TasManagement
 */

typedef int TAS_INIT_OPTIONS;

#define TAS_INIT_NO_OPT                         0  /**< \brief No initialization options */
#define TAS_INIT_DELAYED_BG_OPS                 4  /**< \brief When using Autonomous mode only:
force the background operations to start after the task interval time elapses.
If omitted, operations will start immediately */
#define TAS_INIT_SUPPRESS_LOGS                  8  /**< \brief When set, info log is suppressed */
#define TAS_INIT_AVOID_UPLOAD_IN_MOBILE_DATA   16  /**< \brief When set, avoid upload files to the server in mobile date (load only via wi-fi) */
#define TAS_INIT_EXTRA_DRA_DATA                32  /**< \brief Extra dra items */


/**
 * \brief TAS state options.
 *
 * \ingroup TasManagement
 */

typedef int TAS_STATUS_RESPONSE;
typedef int TAS_STATUS_STATE;

//Responses
#define TAS_RESPONSE_SUCCESS                0
#define TAS_RESPONSE_NONE                   1
#define TAS_RESPONSE_IN_PROGRESS            2
#define TAS_RESPONSE_ERR_INCORRECT_SETUP    3
#define TAS_RESPONSE_ERR_NETWORK            4
#define TAS_RESPONSE_ERR_WRONG_ARGUMENTS    5
#define TAS_RESPONSE_ERR_GENERAL            6
#define TAS_RESPONSE_ERR_CONNECTION_TIMEOUT 7
#define TAS_RESPONSE_ERR_CERTIFICATE        8
#define TAS_RESPONSE_ERR_SSL_PINNING        9

//States
#define TAS_STATE_NOT_UPDATED               10
#define TAS_STATE_PHASE_1_INCOMPLETE        11
#define TAS_STATE_PHASE_1_COMPLETE          12
#define TAS_STATE_ALL_COMPLETE              13


/**
 * \brief Describes a client requesting a session with the TAS API.
 *
 * \ingroup TasManagement
 * \struct TAS_CLIENT_INFO
 */
typedef struct tagTAS_STATUS_INFO {

    TAS_STATUS_RESPONSE lastPinpointResponse;           /**< \brief The last Pinpoint response */
    TAS_STATUS_STATE    state;                          /**< \brief Current Pinpoint updated state */
} TAS_STATUS_INFO;


/**
 * \brief Describes a client requesting a session with the TAS API.
 *
 * \ingroup TasManagement
 * \struct TAS_CLIENT_INFO
 */
typedef struct tagTAS_CLIENT_INFO {
    int size;              /**< \brief Size of the structure */
    
    const char* vendorId;  /**< \brief Pointer to a null-terminated string identifying the client vendor    */
    const char* clientId;  /**< \brief Pointer to a null-terminated string identifying the client product   */
    const char* comment;   /**< \brief Pointer to a null-terminated string specifying a comment to be associated with the session. May be NULL. */
    const char* clientKey; /**< \brief Pointer to a client key block necessary to initialize TAS, obtained from Trusteer. */
} TAS_CLIENT_INFO;

/**
 * \brief Store callback information
 *
 * \ingroup TasManagement
 * \struct TasCallback
 */
typedef struct TasCallback {
    int callbackID;     /**< \brief ID of the callback. Can be one of TAS_..._CALLBACK_KEY values */
    TAS_OBJECT value;   /**< \brief function pointer of the callback */
} TasCallback;


/**
 * \brief Internal exception callback
 *
 * This is a callback for receiving notification whenever and internal exception occurs
 * It allows the app to terminate itself gracefully instead of crashing
 *
 * The callback is called when the code causes an exception signaling when usually causes the
 * app to crash
 *
 * \ingroup TasInitialize
  */
typedef void (*TAS_EXCEPTION_CALLBACK)(
        const char      *message  /**< The exception message */
);


#ifdef __cplusplus
}
#endif

#endif /* __taslib_def_h_included__ */
