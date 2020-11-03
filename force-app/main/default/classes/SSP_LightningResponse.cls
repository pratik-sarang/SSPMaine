/*
* classname 		: SSP_LightningResponse
* @description 		: This class is use to get the server information and send response information to LWC UI.
* @author 			: Ashwin Kasture
* @date 			: 13/11/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture 		13/11/2019		Initial Version
*/
public with sharing class SSP_LightningResponse {

    @AuraEnabled public Boolean bIsSuccess{get; set;}
    @AuraEnabled public Map<String, Object> mapResponse{get; set;}
    
    public SSP_LightningResponse() {
        mapResponse = new Map<String, Object>();
    }
    
    /*
	* method 		: put
	* @description  : This method is use to set mapResponse key value pair
	* @author 		: Ashwin Kasture
	* @param 		: String sKey 		- use to set the Key, 
					  Object objValue 	- use to set the value of any type
	* @return 		: void
	* */
    public void put(String sKey, Object objValue) {
        mapResponse.put(sKey, objValue);
    }
    
    /**
	* @author: Ravi Shankar Peri
	* @method: addException
	* @desc Based on the exception it will update the response map
	* @param exception
	* @return void
	* */
    public void addException(Exception exc, String sLogMessageId) {
        bIsSuccess = false;        
        if (exc instanceof DmlException) {            
            DmlException dmlExc = (DmlException) exc;
            String sError = '';
            for (Integer iCount = 0; iCount < dmlExc.getNumDml(); iCount++) {
                sError += '\n' + dmlExc.getDmlMessage(iCount)+' ';
                String strSep=',';
                // Added as part of R4 defect
                if(dmlExc.getDmlFields(iCount)!=null && !dmlExc.getDmlFields(iCount).isEmpty()){
                    List<sObjectField> sObjFields=dmlExc.getDmlFields(iCount);
                    for (Integer iCnt = 0; iCnt < sObjFields.size(); iCnt++) {
                        strSep=iCnt==sObjFields.size()-1?' ':', ';
                        sError+=sObjFields[iCnt].getDescribe().getLabel()+strSep;
                    }
                }
                mapResponse.put('ERROR', sError);
            }
        } else {
            mapResponse.put('ERROR', 'Please contact the support. Your log reference number is: '+sLogMessageId);
        }   
    }
}