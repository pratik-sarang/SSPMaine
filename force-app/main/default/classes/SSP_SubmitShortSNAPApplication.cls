/* Classname 		:  SSP_SubmitShortSNAPApplication
* @description 		:  Class to submit application for Short SNAP.
* @author 			:  Shivam Tiwari
* @date 			:  APR-22-2020
* MODIFICATION LOG	:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      		MM/DD/YYYY	      			A Brief Description about the Change
**/

public class SSP_SubmitShortSNAPApplication {
    
    /***************************************************************************************************
    * @author       Shivam Tiwari
    * @date         APR-22-2020
    * @methodname   submitApplication
    * @description  This method is used to submit Short SNAP application.
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse submitApplication (String application) {
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            if(String.isNotBlank(application)){
                SSP_Application__c applicationRecord = (SSP_Application__c)JSON.deserialize(application, SSP_Application__c.class);
                // start - 367964 
                if(applicationRecord.ShortSnapMailingAddressLine1__c!=null)
                    applicationRecord.ShortSnapMailingAddressLine1__c = (applicationRecord.ShortSnapMailingAddressLine1__c).toUpperCase();
                if(applicationRecord.ShortSnapMailingAddressLine2__c!=null)
                    applicationRecord.ShortSnapMailingAddressLine2__c = (applicationRecord.ShortSnapMailingAddressLine2__c).toUpperCase();
                if(applicationRecord.ShortSnapPhysicalCity__c!=null)
                    applicationRecord.ShortSnapPhysicalCity__c = (applicationRecord.ShortSnapPhysicalCity__c).toUpperCase();
                if(applicationRecord.ShortSnapPhysicalAddressLine1__c!=null)
                    applicationRecord.ShortSnapPhysicalAddressLine1__c = (applicationRecord.ShortSnapPhysicalAddressLine1__c).toUpperCase();
                if(applicationRecord.ShortSnapPhysicalAddressLine2__c!=null)
                    applicationRecord.ShortSnapPhysicalAddressLine2__c = (applicationRecord.ShortSnapPhysicalAddressLine2__c).toUpperCase();
                if(applicationRecord.ShortSnapMailingCity__c!=null)
                    applicationRecord.ShortSnapMailingCity__c = (applicationRecord.ShortSnapMailingCity__c).toUpperCase();
                if(applicationRecord.ShortSnapFirstName__c!=null)
                    applicationRecord.ShortSnapFirstName__c = (applicationRecord.ShortSnapFirstName__c).toUpperCase();
                if(applicationRecord.ShortSnapLastName__c!=null)
                    applicationRecord.ShortSnapLastName__c = (applicationRecord.ShortSnapLastName__c).toUpperCase();
                if(applicationRecord.ShortSnapMiddleInitial__c!=null)
                    applicationRecord.ShortSnapMiddleInitial__c = (applicationRecord.ShortSnapMiddleInitial__c).toUpperCase();    
                // end - 367964 
                SSP_ShortSnapWrapper objRequest = new SSP_ShortSnapWrapper();
                objRequest.SSP_Application = applicationRecord;
                objRequest.SubmitType = SSP_GlobalConstants.SNAP_FULL;
                Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest) };
                objResponse.put(SSP_InterfaceConstants.SUBMIT_TYPE, SSP_GlobalConstants.SNAP_FULL);
                List<Object> lstData = IntegrationFactory.invokeCallout(SSP_GlobalConstants.SSP_DCSNAP, objResponse);
                
                if(lstData != null){
                    HttpResponse objRes = (HttpResponse) lstData[0];
                    if(objRes != null && objRes.getStatusCode() == 200 && String.isNotBlank(objRes.getbody())){
                        String body = objRes.getbody();
                        SSP_UpdateAgentAssisterResWrapper wrap = (SSP_UpdateAgentAssisterResWrapper) JSON.deserialize(body, SSP_UpdateAgentAssisterResWrapper.class);
                        if(wrap.AckResponse.Success == true){
                            toSend.put('bIsSuccess', true);
                            toSend.put('applicationNumber', wrap.AckResponse.ApplicationNumber);
                        }
                        else{
                            toSend.put('bIsSuccess', false);
                            //Check for .NET or BT error
                            if(wrap.AckResponse.Error != null){
                                if(wrap.AckResponse.Error.CHFSExceptionId != null){
                                    toSend.put('errorName', wrap.AckResponse.Error.CHFSExceptionId);
                                }
                                if(wrap.AckResponse.Error.ErrorCode != null){
                                    toSend.put('errorName', wrap.AckResponse.Error.ErrorCode);
                                    //toSend.put('ErrorDecsription', wrap.AckResponse.Error.ErrorDecsription);
                                }
                            }
                        }
                    }
                    else{
                        //Handle Integration side exception
                        if(lstData.size() > 1){
                            String logMessage = (String) lstData[1];
                            toSend.put('bIsSuccess', false);
                            toSend.put('errorName', logMessage);
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            toSend.put('bIsSuccess', false);
            //Insert LOG record
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SubmitShortSNAPApplication', 'submitApplication', ex.getMessage() , true);
            if(Schema.sObjectType.LOG_LogMessage__c.fields.Name.isAccessible()){
            	toSend.put('errorName', [SELECT Name FROM LOG_LogMessage__c WHERE id =: lstLogMessages[0].id].Name);
            }
        }
        return toSend;
    }    

}