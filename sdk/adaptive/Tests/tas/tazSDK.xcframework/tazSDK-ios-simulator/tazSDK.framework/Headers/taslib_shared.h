#ifndef __taslib_shared_h_included__
#define __taslib_shared_h_included__

#include "taslib_defs.h"

#ifdef __cplusplus
#include <string>
#include <map>
extern "C"
{
#endif

/**
* \brief set the user ID.
*
* This function receives the user id string.
*
* The user id is being encrypted by the public key which must be defined in the security manifest.
*
* The function will fail if the relevant section is not configured properly in the security manifest.
 */
TAS_RESULT TAS_API TasSetUserId(
        const char* userId  /**< [in] user ID string. (256 > userID length > 0)*/
);

/**
* \brief RETURNS last Pinpoint response and updated state.
*
* Returns the lat response and updated TAS state.
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 */
TAS_RESULT TAS_API TasRaGetStatus(
        TAS_STATUS_INFO *tasStatusInfo  /**< [out] The last Pinpoint updated status */
);


/**
* \brief Pinpoint risk assessment response structure
* \ingroup RiskAssessment
*/
typedef struct tagTAS_RA_RISK_ASSESSMENT {
    char recommendation[RA_RISK_ASSESSMENT_RECOMMENDATION_MAX_LENGTH+1];/**< The Pinpoint recommendation for the requested activity */
    int  reason_id;                                                     /**< The reason ID for the recommendation */
    char reason[RA_RISK_ASSESSMENT_REASON_MAX_LENGTH+1];                /**< The reason string for the recommendation */
    int  risk_score;                                                    /**< The risk score */
    char resolution_id[RA_RISK_ASSESSMENT_RESOLUTION_ID_MAX_LENGTH+1];  /**< The resolution ID for the recommendation */
} TAS_RA_RISK_ASSESSMENT;

/**
 * \brief Set the PUID
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasSetPUID(
        const char* puid                        /**< [in] permanent user ID string */
);

#ifdef __cplusplus
}
#endif

#endif /* __taslib_h_included__ */
