#ifndef __taslib_h_included__
#define __taslib_h_included__

#include "taslib_shared.h"

#ifdef __cplusplus
#include <string>
#include <map>
extern "C"
{
#endif

TAS_RESULT TAS_API TasStart(
        TAS_CLIENT_INFO *ClientInfo,        /**< Information on the client requesting the session. */
        int              InitFlags,         /**< Initialization flags -- use TAS_INIT_OPTIONS constants. */
        TasCallback     *callbackArray,     /**< Array of callbacks can be NULL*/
        int             callbackArraySize,  /**< Size of the array of callbacks */
        const char      *BankSessionId    /**< [in] session ID string */
);
    
    
TAS_RESULT TAS_API TasResetSession(
    const char      *BankSessionId    /**< [in] session ID string */
);
  
TAS_RESULT TAS_API TasStop(void);

#ifdef __cplusplus
}
#endif

#endif /* __taslib_def_h_included__ */
