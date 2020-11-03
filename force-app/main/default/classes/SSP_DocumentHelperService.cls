/*
* classname 		: SSP_DocumentHelperService
* @description 		: This class is controller for Document Ceter.
* @author 			: Aniket Shinde
* @date 			: 10/04/2019
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public with sharing class SSP_DocumentHelperService { 
    /*
    * method        : getRFIInformation
    * @description  : This method is use to get RFI and Sumitted Document Information from service.
    * @author       : Ashwin Kasture
    * @param        : User objUser - Contains the User data.
    * @return       : List<String, Object>
    * */    
    public static Map<String, Object> getRFIInformation(User objUser, String userRole) {       
        
        String sspDocumentRecTypeId = Schema.SObjectType.DocumentDetail__c.getRecordTypeInfosByDeveloperName().get('SSP_Document').getRecordTypeId();        
        Map<String,String> mapTypeOfProof = SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'TypeOfProof__c', null);
        Map<String,String> mapDocumentType = SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'DocumentType__c', null);
        Map<String, Object> mapIndividualInfo = new Map<String, Object>();
        Map<String, List<SSP_DocumentCenterCtrl.RFIInformationWrapper>> mapIndividualVsRFIInformation = new Map<String, List<SSP_DocumentCenterCtrl.RFIInformationWrapper>>();
        Map<String, List<SSP_DocumentCenterCtrl.DocumentMetaDataWrapper>> mapIndividualVsDocument = new Map<String, List<SSP_DocumentCenterCtrl.DocumentMetaDataWrapper>>();        
        List<SSP_DocumentCenterCtrl.CaseInformationWrapper> caseInfoWrapLst = new List<SSP_DocumentCenterCtrl.CaseInformationWrapper>();
        List<DocumentDetail__c> lstDocDetails = new List<DocumentDetail__c>();
        Set<String> setUniqueIdentifier = new Set<String>();
        List<String> lstUniqueIdentifier = new List<String>();
        Set<String> setTypeOfProofRefCode = new Set<String>();
        map<String,String> renewalMap = new map<String,String>();
        
        try{ 
            List<Object> serviceResponses = getRFIPayloadServiceData(objUser, userRole);            
            
            //get available programs  
            Set<String> availablePrograms = SSP_Utility.getAvailableProgramsByRole();
            for(Object objResponse: serviceResponses) {
                RSSP_DC_Wrapper objCaseWrap = (RSSP_DC_Wrapper) objResponse;
                // case wrapper parsingobjCaseWrap.RFIInformationPayload.CaseInformation
                if(objCaseWrap.RFIInformationPayload != null && objCaseWrap.RFIInformationPayload.CaseInformation != null && !objCaseWrap.RFIInformationPayload.CaseInformation.isEmpty()) {                   
                    Map<Integer,List<SSP_DocumentCenterCtrl.individualInfoWrapper>> caseToIndMap = new Map<Integer,List<SSP_DocumentCenterCtrl.individualInfoWrapper>>();
                                      
                    for(SSP_RFIInformationPayloadWrapper.CaseInformationWrapper objCaseInfo: objCaseWrap.RFIInformationPayload.CaseInformation){
                        // program access check for non citizen - fix for 371164 
                        //if a case includes multiple programs
                        List<String> lstCasePrograms = new List<String>();                       
                        Boolean isProgramAvailable = false;
                        if(objCaseInfo.ProgramCode!=null && objCaseInfo.ProgramCode.contains(';')){
                            lstCasePrograms = objCaseInfo.ProgramCode.split(';');
                        }
                        else{
                            lstCasePrograms.add(objCaseInfo.ProgramCode);
                        }
                        
                        for(String program : lstCasePrograms){
                            if(availablePrograms != null && availablePrograms.contains(program)){
                                isProgramAvailable = true;
                            }  
                            
                        }
                        if( userRole == SSP_GlobalConstants.CITIZEN_ROLE ||
                           isProgramAvailable
                          ){
                              SSP_DocumentCenterCtrl.individualInfoWrapper indWrap = new SSP_DocumentCenterCtrl.individualInfoWrapper();
                              indWrap.value = objCaseInfo.IndividualId;
                              indWrap.label = objCaseInfo.FullName;
                              indWrap.programs= objCaseInfo.ProgramCode;
                              indWrap.isEligibleForRenewal = objCaseInfo.IsEligibleforRenewal;
                              if(indWrap.isEligibleForRenewal==null)
                              {
                                  indWrap.isEligibleForRenewal = 'N';
                              }
                              renewalMap.put(objCaseInfo.CaseNumber+''+objCaseInfo.IndividualId,indWrap.isEligibleForRenewal);
                              if(caseToIndMap.containskey(objCaseInfo.CaseNumber)){
                                  List<SSP_DocumentCenterCtrl.individualInfoWrapper> wrapLst= caseToIndMap.get(objCaseInfo.CaseNumber);
                                  wrapLst.add(indWrap);
                              }
                              else {
                                  caseToIndMap.put(objCaseInfo.CaseNumber,new list<SSP_DocumentCenterCtrl.individualInfoWrapper>{indWrap});
                              }
                          }
                        
                        
                    }
                    for(Integer caseNumber : caseToIndMap.keySet()){
                        SSP_DocumentCenterCtrl.CaseInformationWrapper caseWrap = new SSP_DocumentCenterCtrl.CaseInformationWrapper();
                        caseWrap.caseNumber = caseNumber;
                        caseWrap.indLst = caseToIndMap.get(caseNumber);
                        caseInfoWrapLst.add(caseWrap);
                    }
                }
                // Get/Set RFI Information - RFI List for home screen & wizard
                if(objCaseWrap.RFIInformationPayload != null && objCaseWrap.RFIInformationPayload.RFIInformation != null) {
                    for(SSP_RFIInformationPayloadWrapper.SSP_RFIInformationWrapper objRFIInfo: objCaseWrap.RFIInformationPayload.RFIInformation) {
                        if( userRole == SSP_GlobalConstants.CITIZEN_ROLE ||
                          (availablePrograms != null && availablePrograms.contains(objRFIInfo.ProgramCode)) )
                        {
                        if(mapTypeOfProof.get(objRFIInfo.TypeOfProofRefCode) == null) {
                            continue;
                        }
                        if(mapIndividualVsRFIInformation.containsKey(objRFIInfo.IndividualId+','+objRFIInfo.FullName)) {
                            SSP_DocumentCenterCtrl.RFIInformationWrapper objData = new SSP_DocumentCenterCtrl.RFIInformationWrapper();
                            objData.iIndividualId = objRFIInfo.IndividualId;
                            objData.sFullName = objRFIInfo.FullName;
                            objData.iCaseNumber = objRFIInfo.CaseNumber;
                            objData.sProgramCode = objRFIInfo.ProgramCode;
                            objData.sDueDate = objRFIInfo.DueDate;
                            objData.sTypeOfProof = mapTypeOfProof.get(objRFIInfo.TypeOfProofRefCode) != null ? mapTypeOfProof.get(objRFIInfo.TypeOfProofRefCode) : ''; //objRFIInfo.TypeOfProof; // To add TypeOfProof picklist API name
                            objData.sTypeOfProofRefCode = objRFIInfo.TypeOfProofRefCode;
                            objData.sUniqueIdentifier = objRFIInfo.UniqueIdentifier;
                            objData.sRecordIdentifier = objRFIInfo.RecordIdentifier;
                            if(renewalMap.get(objData.iCaseNumber+''+objRFIInfo.IndividualId)!=null)
                            {
                                objData.isEligibleForRenewal = renewalMap.get(objData.iCaseNumber+''+objRFIInfo.IndividualId);
                            }
                            else{
                                objData.isEligibleForRenewal = 'N';
                            }
                            List<SSP_DocumentCenterCtrl.RFIInformationWrapper> lstRFIInfo = mapIndividualVsRFIInformation.get(objRFIInfo.IndividualId+','+objRFIInfo.FullName);
                            lstRFIInfo.add(objData);
                            mapIndividualVsRFIInformation.put(objRFIInfo.IndividualId+','+objRFIInfo.FullName, lstRFIInfo);
                        } else {
                            SSP_DocumentCenterCtrl.RFIInformationWrapper objData = new SSP_DocumentCenterCtrl.RFIInformationWrapper();
                            objData.iIndividualId = objRFIInfo.IndividualId;
                            objData.sFullName = objRFIInfo.FullName;
                            objData.iCaseNumber = objRFIInfo.CaseNumber;
                            objData.sProgramCode = objRFIInfo.ProgramCode;
                            objData.sDueDate = objRFIInfo.DueDate;
                            objData.sTypeOfProof = mapTypeOfProof.get(objRFIInfo.TypeOfProofRefCode) != null ? mapTypeOfProof.get(objRFIInfo.TypeOfProofRefCode) : ''; //objRFIInfo.TypeOfProof; // To add TypeOfProof picklist API name
                            objData.sTypeOfProofRefCode = objRFIInfo.TypeOfProofRefCode;
                            objData.sUniqueIdentifier = objRFIInfo.UniqueIdentifier;
                            objData.sRecordIdentifier = objRFIInfo.RecordIdentifier; 
                            if(renewalMap.get(objData.iCaseNumber+''+objRFIInfo.IndividualId)!=null)
                            {
                                objData.isEligibleForRenewal = renewalMap.get(objData.iCaseNumber+''+objRFIInfo.IndividualId);
                            }
                            else{
                                objData.isEligibleForRenewal = 'N';
                            }
                            mapIndividualVsRFIInformation.put(objRFIInfo.IndividualId+','+objRFIInfo.FullName, new List<SSP_DocumentCenterCtrl.RFIInformationWrapper>{objData});
                        }
                        if(objRFIInfo.UniqueIdentifier!=null)
                            setUniqueIdentifier.add(objRFIInfo.UniqueIdentifier);
                        setTypeOfProofRefCode.add(objRFIInfo.TypeOfProofRefCode);
                        }
                    }
                }
                // Get/Set Document Meta Data Information - Document List for home screen
                if(objCaseWrap.RFIInformationPayload != null && objCaseWrap.RFIInformationPayload.DocumentMetaData != null) {
                    for(SSP_RFIInformationPayloadWrapper.DocumentMetaDataWrapper objDoc: objCaseWrap.RFIInformationPayload.DocumentMetaData) {
                        if(mapIndividualVsDocument.containsKey(objDoc.IndividualId+','+objDoc.IndividualName)) {
                            SSP_DocumentCenterCtrl.DocumentMetaDataWrapper objData = new SSP_DocumentCenterCtrl.DocumentMetaDataWrapper();
                            objData.iIndividualId = objDoc.IndividualId;
                            objData.sIndividualName = objDoc.IndividualName;
                            objData.iCaseNumber = objDoc.CaseNumber;
                            objData.sSubmittedDate = objDoc.SubmittedDate;
                            objData.sDocumentMetadataId = objDoc.DocumentMetaDataId;
                            objData.sDocumentName = objDoc.DocumentName;
                            objData.sDocumentType = mapDocumentType.get(objDoc.DocumentType) != null ? mapDocumentType.get(objDoc.DocumentType) : ''; // To add TypeOfProof picklist API name
                            if(objDoc.DocumentType == 'DT090'){
                                objData.sDocumentType = 'Other';
                            }
                            objData.sExtension = objDoc.Extension;
                            objData.sStatuscode = objDoc.Statuscode;
                            objData.isAccepted = objDoc.Statuscode == SSP_GlobalConstants.Document_STATUS_Code_Valid ? true: false;
                            List<SSP_DocumentCenterCtrl.DocumentMetaDataWrapper> lstRFIInfo = mapIndividualVsDocument.get(objDoc.IndividualId+','+objDoc.IndividualName);
                            lstRFIInfo.add(objData);
                            mapIndividualVsDocument.put(objDoc.IndividualId+','+objDoc.IndividualName, lstRFIInfo);
                        } else {
                            SSP_DocumentCenterCtrl.DocumentMetaDataWrapper objData = new SSP_DocumentCenterCtrl.DocumentMetaDataWrapper();
                            objData.iIndividualId = objDoc.IndividualId;
                            objData.sIndividualName = objDoc.IndividualName;
                            objData.iCaseNumber = objDoc.CaseNumber;
                            objData.sSubmittedDate = objDoc.SubmittedDate;
                            objData.sDocumentMetadataId = objDoc.DocumentMetaDataId;
                            objData.sDocumentName = objDoc.DocumentName;
                            objData.sDocumentType = mapDocumentType.get(objDoc.DocumentType) != null ? mapDocumentType.get(objDoc.DocumentType) : ''; // To add TypeOfProof picklist API name
                            if(objDoc.DocumentType == 'DT090'){
                                objData.sDocumentType = 'Other';
                            }
                            objData.sExtension = objDoc.Extension;
                            objData.sStatuscode = objDoc.Statuscode;
                            objData.isAccepted = objDoc.Statuscode == SSP_GlobalConstants.Document_STATUS_Code_Valid ? true: false;
                            mapIndividualVsDocument.put(objDoc.IndividualId+','+objDoc.IndividualName, new List<SSP_DocumentCenterCtrl.DocumentMetaDataWrapper>{objData});
                        }
                    }
                }
            }
            //without sharing query
            lstDocDetails = DocumentDetailSelector.queryDocumentDetailData(setUniqueIdentifier,sspDocumentRecTypeId);
            List<SSP_TypeOfProof__mdt> lstTypeOfProofMetaData = [SELECT Id, DocumentType__c, IsRecommended__c, K_Hipp_Proof__c, TypeOfProof__c 
                                                                 FROM SSP_TypeOfProof__mdt
                                                                 WHERE TypeOfProof__c IN: setTypeOfProofRefCode AND K_Hipp_Proof__c = true];
           	mapIndividualInfo.put('rfiInformation', mapIndividualVsRFIInformation);
        	mapIndividualInfo.put('documentMetaData', mapIndividualVsDocument);
            mapIndividualInfo.put('documentDetailList',lstDocDetails);
            mapIndividualInfo.put('typeOfProofMetaDataList', lstTypeOfProofMetaData);            
            mapIndividualInfo.put('caseInformationList',caseInfoWrapLst);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentHelperService', 'getRFIInformation', ex.getMessage() , true);
            mapIndividualInfo.put('ERROR',lstLogMessages);
        }                    
        return mapIndividualInfo;
    }
   
    /*
    * method        : getDmsServiceData
    * @description  : This method is use to get Document base64 data from Service based on DocumentMetaDataId.
    * @author       : Ashwin Kasture
    * @param        : String sDocumentMetaDataId - DMS Id i.e. DocumentMetaDataId.
    * @return       : List<Object>
    * */
    public static List<Object> getDmsServiceData(String sDocumentMetaDataId) {               
        Map<String, Object> objReqParam = new Map<string, Object>();
        objReqParam.put('MappingId','');
        objReqParam.put('DocumentId',sDocumentMetaDataId);
        List<Object> lstResponse = IntegrationFactory.invokeCallout('SSP_DocumentDownload',objReqParam);        
        return lstResponse;
    }
    
    /*
    * method        : getContentDocumentData
    * @description  : This method is use to get Document data from ContentVersion object.
    * @author       : Ashwin Kasture
    * @param        : String sContentDocumentId - Content Document Id.
    * @return       : List<ContentVersion>
    * */
    public static List<ContentVersion> getContentDocumentData(String sContentDocumentId) {
        Map<String, String> detailMap = new Map<String, String> {'objectName'=>'ContentVersion'};
        Set<String> fieldSet = new set<String> {'Id','VersionData','ContentDocumentId','Title'};
        Map<String, String> conditionMap = new Map<String, String> {'ContentDocumentId' => sContentDocumentId};
		List<ContentVersion> lstContentVersion = SSP_SharingBypassFetcher.fetchRecords (detailMap, fieldSet, conditionMap);
        return lstContentVersion;
    }
    
    /*
    * method        : getRFIPayloadServiceData
    * @description  : Method use to call RFI Payload service.
    * @author       : Ashwin Kasture
    * @param 		: objUser - Contains the User data.
    * @return       : List<Object>
    * */
    public static List<Object> getRFIPayloadServiceData(User objUser, String userRole) {
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.RFI_DETAILS;
        

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
        reqWrapper.primaryApplicationIndividualId = SSP_Utility.getCurrentUserAllIndividualIds();

        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        List<Object> lstServiceResponses = new list<Object>();
        lstServiceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);        
		return lstServiceResponses;        
    }
}