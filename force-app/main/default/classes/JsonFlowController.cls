/***************************************************************************************************************************
*   Type         :   
*   Name         :   JsonFlowController
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   05/25/2020
*   Description  :   Controller class which provides Flow and Page data for jsonFlowContainer Component
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*    Narapa Naidu Pulipati      06/09/2020      Initial Version
*    Narapa Naidu Pulipati      07/13/2020      Added IronDome Fixes in storeObjectData Method
*****************************************************************************************************************************/
public with sharing class JsonFlowController {

    /*Name: getFlowInitData
    * Description: Method to obtain information about the Navigation flow Detail Metadata record, 
                   and its childs(Navigation Flow Page Configuration) Page Info Meta data record based on
                   Navigation Flow detail developer name.
    * Params     : String of Navigation Flow detail developer name
    * returnType : JsonPageResponse object whose pageConfdata attribute contains information about Navigation Flow Detail
                   and Page info meta data records       
    */

    @AuraEnabled(cacheable=true)
    public static JsonPageResponse getFlowInitData(String recordId, String flowName){
        JsonPageResponse resp = new JsonPageResponse();
        resp.pageConfData = new JsonPageResponse.PageConfData();
        resp.pageConfData.navFlowDetail = retrieveFlowDetail(flowName);
        if(null != resp.pageConfData.navFlowDetail){
            //Passing null(curPageId) as parameter to getPageToLoadId method helps in obtaining 
            //Page info about Navigation Flow Page Configuration record which is first in the sequence under Navigation flow detail record
            String pageConfigId = getPageToLoadId(resp.pageConfData.navFlowDetail, null, 'next');
            if(null != pageConfigId){
                resp.pageConfData.pageInf = new JsonPageResponse.PageInfo(retrievePageInfo(pageConfigId));
            }
        }
        return resp;
    }

    /*Name: retrieveFlowDetail
    * Description: Method to obtain information about the Navigation Flow Detail Meta data Record and 
    *              its child Navigation Flow Page Configuration Records based on the Navigation Flow detail
    *              developer name. 
    *              
    * Params     : Developer Name of the Navigation flow detail that is being configured on jsonFlowContainer
    * returnType : Navigatio Flow detail meta data record with details about its child Navigation Flow Page Configuration        
    */

    private static NavFlowDetail__mdt retrieveFlowDetail(String flowName){
        List<NavFlowDetail__mdt> jsonMetaList = [ SELECT Id, FlowDisplayName__c, FlowName__c, NextActionGoToPage__c, JsonObjectSchema__c, 
                                                    (SELECT Id, NavigationFlowDetail__c, PageInfo__c, SectionGroupName__c, IsFinalSummaryPage__c, IsExcludedInProgress__c, SequenceNumber__c, toLabel(PageInfo__r.Page_Display_Name_View__c)
                                                    FROM Navigation_Flow_Page_Configuration__r 
                                                    WHERE IsActive__c = true 
                                                    ORDER BY SequenceNumber__c)
                                                FROM NavFlowDetail__mdt
                                                WHERE DeveloperName =: flowName];
        return (null != jsonMetaList && jsonMetaList.size() > 0) ? jsonMetaList[0] : null;
    }

    /*Name: retrieveFlowDetailById
    * Description: Method to obtain information about the Navigation Flow Detail Meta data Record and 
    *              its child Navigation Flow Page Configuration Records based on the Navigation Flow detail Record Id
    *              
    * Params     : Developer Name of the Navigation flow detail that is being configured on jsonFlowContainer
    * returnType : Navigation Flow detail meta data record with details about its child Navigation Flow Page Configuration        
    */
    private static NavFlowDetail__mdt retrieveFlowDetailById(String flowId){
        List<NavFlowDetail__mdt> jsonMetaList = [ SELECT Id, FlowDisplayName__c, FlowName__c, NextActionGoToPage__c, JsonObjectSchema__c, 
                                                    (SELECT Id, NavigationFlowDetail__c, PageInfo__c, SectionGroupName__c, IsFinalSummaryPage__c, IsExcludedInProgress__c, SequenceNumber__c, toLabel(PageInfo__r.Page_Display_Name_View__c)
                                                    FROM Navigation_Flow_Page_Configuration__r 
                                                    WHERE IsActive__c = true 
                                                    ORDER BY SequenceNumber__c)
                                                FROM NavFlowDetail__mdt
                                                WHERE Id =: flowId];
        return (null != jsonMetaList && jsonMetaList.size() > 0) ? jsonMetaList[0] : null;
    }

    /*Name: retrievePageInfo
    * Description: Method to obtain Navigation Flow Page Configuration Metadata record information based on the record Id        
    * Params: Record ID of Navigation Flow Page Configuration whose information is being obtained
    * returnType: A record of Navigation Flow Page Configuration record which has information about its parent Page Info Custom meta data record      
    */

    private static NavFlowPageConfig__mdt retrievePageInfo(String pageConfigId){
        NavFlowPageConfig__mdt jsonMeta = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, 
                                                        PageInfo__c, IsFinalSummaryPage__c , IsExcludedInProgress__c, toLabel(Page_Config_Display_Name_View__c), PageInfo__r.PageName__c, 
                                                        toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.JsonLayoutSchema__c, SectionGroupName__c, 
                                                        SequenceNumber__c, PageInfo__r.PageDisplayName__c 
                                                    FROM NavFlowPageConfig__mdt 
                                                    WHERE Id =: pageConfigId
                                                        AND IsActive__c = true];
        return jsonMeta;
    }

    /*Name: getPageToLoadId
    * Description: Method to obtain page which must be loaded in the jsonFlowContainer Component        
    * Params: Navigation Flow Detail metadata record, Page Id of the page that needs to be loaded, Action
    * returnType: A string containing the record ID of a child Navigation Flow Page Configuration record of Navigation Flow Detail 
    *             Record.       
    */
     @TestVisible 
    private static String getPageToLoadId(NavFlowDetail__mdt flowMetaList, String curPageId, String action){
        String pageToLoadId = null;
        if(null != flowMetaList.Navigation_Flow_Page_Configuration__r && flowMetaList.Navigation_Flow_Page_Configuration__r.size() > 0){
            if(null == curPageId){
                // return the first page in the flow
                pageToLoadId = flowMetaList.Navigation_Flow_Page_Configuration__r[0].Id;
            }
        }
        return pageToLoadId;
    }

    @AuraEnabled(cacheable=true)
    public static JsonPageResponse getPageInfo(String recordId, String pageConfigId){
        JsonPageResponse resp = new JsonPageResponse();
        resp.pageConfData = new JsonPageResponse.PageConfData();
        resp.pageConfData.pageInf = new JsonPageResponse.PageInfo(retrievePageInfo(pageConfigId));
        return resp;
    }


    //n
    @AuraEnabled(cacheable=true)
    public static JsonPageResponse getPageInfoInitData(String recordId, String pageName){
        JsonPageResponse resp = new JsonPageResponse();
        resp.pageConfData = new JsonPageResponse.PageConfData();
        resp.pageConfData.pageInf = new JsonPageResponse.PageInfo(retrievePageInfoDetail(pageName));
        return resp;
    }



    private static PageInfo__mdt retrievePageInfoDetail(String pageName){
        List<PageInfo__mdt> jsonMetaList = [ SELECT Id, PageName__c, toLabel(Page_Display_Name_View__c),JsonLayoutSchema__c, PageDisplayName__c
                                             FROM PageInfo__mdt
                                             WHERE DeveloperName =: pageName];
        return (null != jsonMetaList && jsonMetaList.size() > 0) ? jsonMetaList[0] : null;
    }
    //n


    /*Name: exec
    * Description: Method to perform the operation like taking to next page or saving the data utilizing the Controller 
                   specific to the Naviagtion Flow Detail      
    * Params:  Action to be performed like Next,Back,Submit, RecordId, Data Collected on the LWC, Name of the Page Info Metadata Record
               on which button is clicked and server side call is being made, Navigation Flow detail Meta data record Id, Navigation Flow Page Configuration record Id,
               All Navigation Page Configurtion IDs belonging to the Navigation Flow Detail Metadata Record
    * returnType: JsonPageResponse        
    */
    
    @AuraEnabled
    public static JsonPageResponse exec(String action,String recordId, Object data, String pageName, String flowId, String pageConfigId, List<String> allPageConfigIds){
        JsonPageResponse resp = null;
        try{
            boolean hasErr = false;
            String flowCtrlCls;
            boolean isSaveOnSubmit;
            NavFlowDetail__mdt flowMdt = retrieveFlowDetailById(flowId);
            JsonPageResponse.ObjectSchema objSchema;
            if(flowMdt.JsonObjectSchema__c != null){
                objSchema =(JsonPageResponse.ObjectSchema)System.JSON.deserialize(flowMdt.JsonObjectSchema__c, JsonPageResponse.ObjectSchema.class);
                flowCtrlCls = objSchema.controller; //Getting the controller of the Navigation Flow Detail from the Object Schema
                isSaveOnSubmit = objSchema.isSaveOnSubmit; //Getting isSaveonSubmit attribute from Navigation Flow Detail
            }
            if(String.isNotEmpty(flowCtrlCls)){
                // page has a controller so call its next method
                JsonPageController ctrl = getPageController(flowCtrlCls);
                if(action=='next'){
                    resp = ctrl.next(pageName, data, null, flowId, pageConfigId);
                }
                else if(action=='back'){
                    resp = ctrl.back(pageName, data, null, flowId, pageConfigId);
                }
                else {
                    resp = ctrl.exec(action, pageName, data, null, flowId, pageConfigId);
                }
                
                if(null != resp && null != resp.vMessages && resp.vMessages.size() > 0){
                    // page has validation messages. So just return them.
                    hasErr = true;
                }
            }
            if(!hasErr){
                if(action == 'submit' && isSaveOnSubmit){
                    resp.sObj = storeObjectData(objSchema, resp.pageObjectData); 
                }
                if(null == allPageConfigIds){
                    // TODO fetch all page config IDs from metadata
                }
                if(null == resp){
                    resp = new JsonPageResponse();
                }
                String pageToLoadId = getPageToLoadId('next', pageConfigId, allPageConfigIds);
                if(null != pageToLoadId){
                    resp.pageConfData = new JsonPageResponse.PageConfData();
                    resp.pageConfData.pageInf = new JsonPageResponse.PageInfo(retrievePageInfo(pageToLoadId));
                }
            }
        }
        catch(Exception e){
            throw new JsonPageResponse.JsonPageException('ERR001', 'Error Occurred', e);
        }
        return resp;
    }

    /*Name: storeObjectData
    * Description: Method to store the data of the Form in the Object
    * Params:  Schema of the Object from Navigation Flow Detail, Object Data
    * returnType: Sobject record that is inserted with the data obtained from the Page       
    */
    private static Sobject storeObjectData(JsonPageResponse.ObjectSchema objSchema, Object data){
            Sobject sobj;
            String objectName = objSchema.sobjectInfo.objectName;
            String recordTypeName = objSchema.sobjectInfo.recordTypeName;
            if(String.isNotEmpty(objectName)){
                sobj = Schema.getGlobalDescribe().get(objectName).newSObject();
                    if(String.isNotEmpty(recordTypeName)){
                        sobj.put('RecordTypeId',Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId());
                     }
                     sobj.put(objSchema.sobjectInfo.fieldName, Json.serializePretty(data));
                     //TODO : Fix Mandatory Field in the Objects
                     //Temporary fix for Log Message Object
                     if(objectName == 'LOG_LogMessage__c'){
                     sobj.put('LOG_Source__c','Prescreening');
                     }
            }
            //inserting  Sobject
            if(sobj!=null){
                sobj = ESAPI.accessController().insertAsUser(new List<Sobject>{sobj}, SSP_Utility.getFieldsNamesList (new List<Sobject>{sobj})).getInsertedObjects()[0];  
            }
            return sobj;
    }

    /*Name: getPageToLoadId
    * Description: Method to obtain page which must be loaded in the jsonFlowContainer Component        
    * Params: Action like next and back, Id of Navigation Page Flow Configuration, List of all Navigation Flow Page Congiguration of a Nav Flow Detail record
    * returnType: A string containing the record ID of a child Navigation Flow Page Configuration record of Navigation Flow Detail 
    *             Record.       
    */
    private static String getPageToLoadId(String action, String pageConfigId, List<String> allPageConfigIds){
        String pageToLoadId = null;
        Integer pageIndex = getPageIndex(pageConfigId, allPageConfigIds);
        if('next'.equals(action)){
            if(pageIndex == allPageConfigIds.size()-1){
                // last page, so stay in current page hence return null
                pageToLoadId = null;
            }
            else {
                pageIndex++;
                pageToLoadId = allPageConfigIds[pageIndex];
            }
        }
        else 
        if('back' == action){
            if(pageIndex == 0){
                // first page,  so stay in current page hence return null
                pageToLoadId = null;
            }
            else {
                pageIndex--;
                pageToLoadId = allPageConfigIds[pageIndex];
            }
        }
        return pageToLoadId;
    }

    /*Name: getPageIndex
    * Description: Method to get the required Navigation Page Flow Configuration
                   from the list of Navigation Page Flow Configuration Ids       
    * Params: Action like next and back, Id of Navigation Page Flow Configuration, List of all Navigation Flow Page Congiguration of a Nav Flow Detail record
    * returnType: A string containing the record ID of a child Navigation Flow Page Configuration record of Navigation Flow Detail 
    *             Record.       
    */
    private static Integer getPageIndex(String pageConfigId, List<String> allPageConfigIds){
        Integer idx = -1;
        Integer cnt = 0;
        for(String itrPageConfId : allPageConfigIds){
            if(pageConfigId.equals(itrPageConfId)){
                idx = cnt;
                break;
            }
            cnt++;
        }
        return idx;
    }

    /*Name: getPageController
    * Description: Method to get the Page Cntroller of the Navigation flow detail    
    * Params:  Name of the Page Controller
    * returnType: JsonPageController        
    */
	private static JsonPageController getPageController(String clsName){ 
		JsonPageController ctrl = null;
		try{
			ctrl = (JsonPageController) getClassType(clsName).newInstance();
		}
		catch(Exception e){ 
			//throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Could not create ViewProcessor object using the class name [' + clsName + ']. \n' + CustomException.toString(e), 'ERR_CLS_NOT_FOUND');
            throw e;
        }
		return ctrl;
    }
    
    /**
	 * Returns Apex Class Type for the given class name.
	 * @param clsName String Class name
	 * @return Type Apex Class type.
	 */
	public static Type getClassType(String clsName){
		Type typ = Type.forName(clsName);
		if(null == typ){
			//throw new CustomException('CustomException.EXCEPTION_TYP.SYS', 'Could not find Apex class [' + clsName + '] in the org. \n', 'ERR_CLS_NOT_FOUND');
		}
		return typ;
    }  
}