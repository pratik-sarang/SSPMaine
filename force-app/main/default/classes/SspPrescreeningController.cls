/***************************************************************************************************************************
*   Type         :   
*   Name         :   SspPrescreeningController
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   06/1/2020
*   Description  :   Controller for Prescreeening  Navigation Flow Detail
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Narapa Naidu Pulipati      06/01/2020      Initial Version
*****************************************************************************************************************************/
public with sharing class SspPrescreeningController implements JsonPageController {

    /*Name: exec
    * Description: Method to obtain information about the Navigation flow Detail Metadata record, 
                   and its childs(Navigation Flow Page Configuration) Page Info Meta data record based on
                   Navigation Flow detail developer name.
    * Params:  Action to be performed like Next,Back,Submit, RecordId, Data Collected on the LWC, Name of the Page Info Metadata Record
               on which button is clicked and server side call is being made, Navigation Flow detail Meta data record Id, Navigation Flow Page Configuration record Id,
               All Navigation Page Configurtion IDs belonging to the Navigation Flow Detail Metadata Record
    * returnType: JsonPageResponse           
    */
    
    public JsonPageResponse exec(String action, String pageName, Object data, String pageInfoId, String flowId, String pageConfigId){
        JsonPageResponse resp = null;
        if(action=='submit')
        {
            SSP_PreScreeningData psData = null;//new SSP_PreScreeningData();
            String dataJsonString = String.valueof(data);
            //Parse JSON to PrescreeningData
            psData = (SSP_PreScreeningData)System.JSON.deserialize(dataJsonString, SSP_PreScreeningData.class);
            psData =  SSP_PrescreeningService.determineEligibility( psData);
            resp = new JsonPageResponse();
            resp.pageObjectData = psData;
        }
      return resp;
    }
    
    public JsonPageResponse back(String pageName, Object data, String pageInfoId, String flowId, String pageConfigId) {
        return null;
    }

    public JsonPageResponse next(String pageName, Object data, String pageInfoId, String flowId, String pageConfigId) {
        return null;
    }

}