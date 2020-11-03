/***************************************************************************************************************************
*   Type         :   MetaDataService
*   Name         :   ReferenceDataService
*   Created By   :   Abdulrehman
*   Created Date :   06/04/2020
*   Description  :   Service class for ReferenceData__mdt service
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Abdulrehman               06/04/2020   	Initial Version
*****************************************************************************************************************************/
global with sharing class ReferenceDataService{
    
    /********************************************************************************************
    * @author       Abdulrehman
    * @date         06/04/2020 
    * @methodname   fetchReferenceData
    * @description  This method fetches the reference data from ReferenceData__mdt for prescreening rules
    * @param        List<ReferenceData>: List of invocable wrapper class
    * @return       List<ReferenceData__mdt>
    ********************************************************************************************/
    @InvocableMethod
    public static List<ReferenceData__mdt> fetchReferenceData(List<ReferenceData> inputData) {
        
        //Capture inputs in premitive variables
        string type = inputData[0].type;
        string key = inputData[0].key;
        Integer noOfPeople = inputData[0].noOfPeople;
        
        //Create query structure
        String queryStr = 'SELECT Id, Value__c, Number_Of_People__c ';
        queryStr += SSP_GlobalConstants.REFERENCEDATA_FROM_QUERY;//IronDome report : Moved HardCoded String value to SSP Global Constants.
        queryStr += SSP_GlobalConstants.REFERENCEDATA_CONDN_QUERY;//IronDome report : Moved HardCoded String value to SSP Global Constants.
        String finalQuery = queryStr;
        // add household size only if it is provided as input
        if(noOfPeople != null){
            finalQuery += SSP_GlobalConstants.REFERENCEDATA_CONDN_PPL_QUERY;//IronDome report : Moved HardCoded String value to SSP Global Constants.
        }
        
        //query the custom metadata
        List <ReferenceData__mdt> listReferenceData = Database.query(finalQuery) ;
        
        //if the data is not returned for given household and the query is household size based, query for additional member
        if(listReferenceData.isEmpty() && noOfPeople != null){
            
            //order by will make sure 0(additional person) is first element and highest size is last element
            finalQuery = queryStr + SSP_GlobalConstants.REFERENCEDATA_ORDER_BY_QUERY;//IronDome report : Moved HardCoded String value to SSP Global Constants.
            listReferenceData = Database.query(finalQuery); 
			            
            //add additional member value for each additional member
            if(listReferenceData != null && !listReferenceData.isEmpty()){
                Integer size = listReferenceData.size(); //size of the list
                //if list size AND highest size is less than input household size
                Boolean additionalMemberCalculation = false;
                if(size <= noOfPeople && listReferenceData[size-1].Number_Of_People__c < noOfPeople){
                    additionalMemberCalculation = true;
                }
                
                //Add additiona member value to heighest value for each additional member
                if(additionalMemberCalculation){
                    Decimal value = listReferenceData[size-1].value__c;
                    for(Integer i=0; i < (noOfPeople - listReferenceData[size-1].Number_Of_People__c); i++){
                        value = value + listReferenceData[0].value__c;
                    }
                    //assign the final value to first element to be returned
                    listReferenceData[0].value__c = value;
            	}
            }
        }
        if(listReferenceData != null && !listReferenceData.isEmpty())
            return new List<ReferenceData__mdt>{listReferenceData[0]} ;
        else
            return null;
    }
    
    /********************************************************************************************
    * @author       Abdulrehman
    * @date         06/04/2020 
    * @classname   ReferenceData
    * @description  Wrapper class containing Invocable variable to be used by flow
    ********************************************************************************************/
    global class ReferenceData{
        
        @InvocableVariable
        global String type;
        
        @InvocableVariable
        global String key;
        
        @InvocableVariable
        global Integer noOfPeople;
        
    }
}