/***************************************************************************************************************************
*   Type         :   Interface
*   Name         :   JsonPageController
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   05/27/2020
*   Description  :   Interface containing the methods which needs to be implemented by the controller of Navigation Flow Detail
*                    which is being used in the jsonFlowContainer
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Narapa Naidu Pulipati      05/27/2020      Initial Version
*****************************************************************************************************************************/
public interface JsonPageController {
    
    JsonPageResponse exec(String action, String pageName, Object data, String pageInfoId, String flowId, String pageConfigId);

    JsonPageResponse back(String pageName, Object data, String pageInfoId, String flowId, String pageConfigId);

    JsonPageResponse next(String pageName, Object data, String pageInfoId, String flowId, String pageConfigId);
}