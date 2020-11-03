/**
* Class Name    : SSP_DownloadSNAPCopyController 
* Owner         : DELOITTE
* Created Date  : 4/17/2020
* Description   : Download SNAP copy from Next Steps Page
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          Description                                                         
*  ----------  --------------     ------------------------------------------------------------------
*  17-APR-2020  PrashantPandey        Initial Version
*  
**/
public class SSP_DownloadSNAPCopyController {     
     
     public class DownloadSNAPCopyWrapp {
        @AuraEnabled
        public string fileName{get;set;}
        @AuraEnabled
        public string binaryData{get;set;}    
        public DownloadSNAPCopyWrapp(string fileName,string binaryData) {
            this.fileName = fileName;
            this.binaryData = binaryData;            
        }
    }
    
    /***************************************************************************************************
    * @author       Prashant Pandey
    * @date         APR-17-2020
    * @methodname   downloadCopy
    * @description  This method is used to download copy of Short SNAP application.
    * @return       DownloadSNAPCopyWrapp
    *****************************************************************************************************/
    @AuraEnabled
    public static DownloadSNAPCopyWrapp downloadCopy(String applicationNumber) {
        if(String.isBlank(applicationNumber)){
            return null;
        }
        else{
            List<Object> objCorrespondceRespList = new List<Object>(); 
            SSP_CorrespondenceResponseWrapper objCorrespondceResp;       
            List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper> reqWrapperMiscList = new List<SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper>();
            SSP_CorrespondenceRequestWrapper reqWrapper = new SSP_CorrespondenceRequestWrapper(SSP_GlobalConstants.HBE_055);
            reqWrapper.ApplicationNumber = Integer.valueOf(applicationNumber);
            //reqWrapper.ApplicationNumber = 400141289;
            reqWrapper.CorrespondenceCode = SSP_GlobalConstants.HBE_055;
            reqWrapper.CreatedDate= string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            reqWrapper.CreatedUserId = SSP_GlobalConstants.SF_SSPUser;
            reqWrapper.PrintMode = SSP_GlobalConstants.LP;
            reqWrapper.ProgramCode = SSP_GlobalConstants.SN_CODE;
            reqWrapper.RequestTriggerStatusCode = SSP_GlobalConstants.NEW_CODE;
            reqWrapper.TriggerSourceCode = SSP_GlobalConstants.SF_SSP_SYSTEM_TRG;
            reqWrapper.UpdatedDate = string.valueof(SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            reqWrapper.UpdatedUserId = SSP_GlobalConstants.SF_SSPUser;
            reqWrapper.Reqtype = SSP_GlobalConstants.GenerateCorrespondence;
            SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper reqWrapperMisc = new SSP_CorrespondenceRequestWrapper.MiscellaneousParametersWrapper();
            reqWrapperMisc.ParamName = SSP_GlobalConstants.AnonymousShortSNAP;
            reqWrapperMisc.ParamValue = SSP_GlobalConstants.YES_CODE;
            reqWrapperMiscList.add(reqWrapperMisc);
            reqWrapper.MiscellaneousParametersList = reqWrapperMiscList;
            Map<String,object> objMap = new Map<string,object>();
            objMap.put(SSP_InterfaceConstants.JSON_BODY, JSON.serialize(reqWrapper));
            objCorrespondceRespList = IntegrationFactory.invokeCallout(SSP_GlobalConstants.SSP_Correspondence, objMap);
            objCorrespondceResp = (SSP_CorrespondenceResponseWrapper) System.JSON.deserialize(JSON.serialize(objCorrespondceRespList[0]), SSP_CorrespondenceResponseWrapper.class);
            if(objCorrespondceResp.isSuccess == true) {
                DownloadSNAPCopyWrapp downloadWrap = new DownloadSNAPCopyWrapp(objCorrespondceResp.GenerateCorrName,objCorrespondceResp.GenerateCorrByteString);            
                return downloadWrap;
            } else
                return null;
        }
    }
    
}