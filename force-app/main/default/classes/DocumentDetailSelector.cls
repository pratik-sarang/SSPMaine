/*
* classname     :  DocumentDetailSelector
* @description  :  Selector class for DocumentDetail__c
* @author       :  Ashwin Kasture 
* @date         :  1/05/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public with sharing class DocumentDetailSelector {
    /*
    * method        : downloadDocumentMethod
    * @description  : This method is use to query data of DocumentDetail__c object.
    * @author       : Ashwin Kasture
    * @param        : String sDocumentData - Contains DocumentMetaDataId Or Content Document Id.
    * @return       : SSP_LightningResponse    * */
    public static List<DocumentDetail__c> queryDocumentDetailData(Set<String> setUniqueIdentifier,String sspDocumentRecTypeId){

        /*  
            lstUniqueIdentifier.addAll(setUniqueIdentifier);
            Map<String, String> mapDocDetailObj = new Map<String, String> {'objectName' => 'DocumentDetail__c'};
            Set<String> setDocDetailFields = new Set<String> {'Id','Name','IndividualId__c','CaseNumber__c','UniqueIdentifier__c','Extension__c','ContentDocumentId__c','ReceivedDate__c','DocumentMetadataId__c','MimeType__c'};
            Map<String, String> mapDocDetailCondition = new Map<String, String> {'RecordTypeId' => sspDocumentRecTypeId,'UniqueIdentifier__c'=>String.join(lstUniqueIdentifier, ',')};
			List<DocumentDetail__c> lstDocumentDetail = new List<DocumentDetail__c>();
            lstDocumentDetail = (List<DocumentDetail__c>)SSP_Utility.fetchRecords(mapDetails, setFields, mapConditions);
            return lstDocumentDetail;
        */
        List<DocumentDetail__c> lstDocDetails = new List<DocumentDetail__c>();
        lstDocDetails = [Select Id,Name,IndividualId__c,CaseNumber__c,UniqueIdentifier__c,Extension__c,ContentDocumentId__c,ReceivedDate__c,DocumentMetadataId__c,MimeType__c
                            FROM DocumentDetail__c 
                            WHERE UniqueIdentifier__c IN: setUniqueIdentifier AND RecordTypeId =:sspDocumentRecTypeId];//Removed UniqueIdentifier__c != null AND  for Perf fix
        return lstDocDetails;
    }
}