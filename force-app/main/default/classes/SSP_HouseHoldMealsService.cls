/***************************************************************************************************************************
*   Type         :   Service Class
*   Name         :   SSP_HouseHoldMealsService
*   Created By   :   Suyash Singhal
*   Created Date :   11/13/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/13/2019        Initial Version
*****************************************************************************************************************************/

public with sharing class SSP_HouseHoldMealsService {
    

     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @description  This method gets all the Household details as an init method
    * @param        sApplicationId
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    public static map<String,Object> fetchHouseHoldData(List<String> lstApplications , String mode){

        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        map<String,Object> objResponse = new map<String,Object>();
        Set<Id> setMemIds = new set<Id>();
        Map<id,SSP_ApplicationIndividual__c> indivVsmemberMap = new Map<id , SSP_ApplicationIndividual__c>();
        List<SSP_HouseHoldMeals.WrapperHHMeals> lstWrapper = new List<SSP_HouseHoldMeals.WrapperHHMeals>();
        String sLabelValue ='';
        String sApplicationId = lstApplications[0]; 

        
        try{
           List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c> ();  
         if(String.IsNotBlank(sApplicationId)){
             
           lstAppIndividuals =  SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','MemberStatus__c' => '!='}, 
                                                                                                                         new Set<String>{'Id','SSP_Member__c', 'SSP_Application__c', 'IsHeadOfHousehold__c','MemberStatus__c'},
                                                                                                                         new Map<String, String>{'limit'=>'100','SSP_Application__c'=> sApplicationId, 'MemberStatus__c'=> 'Removed'});
             


            for(SSP_ApplicationIndividual__c objAppIndiv : lstAppIndividuals){
                if(objAppIndiv.IsHeadOfHousehold__c || !mode.endsWithIgnoreCase('addRemoveMember') || (mode.endsWithIgnoreCase('addRemoveMember') && objAppIndiv.MemberStatus__c=='New' )){
                setMemIds.add(objAppIndiv.SSP_Member__c);
                indivVsmemberMap.put(objAppIndiv.SSP_Member__c ,objAppIndiv);
                }
            }     
         }

         if(!setMemIds.isEmpty()){
            
             lstMembers =  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                                              new Set<String>{'Id','Name', 'FirstName__c','LastName__c','BirthDate__c', 'CanBuyCookWithHOH__c','SponsoredIndividual__c', 'InternalAlienSponsor__c','ExternalAlienSponsor__c'}, 
                                                                              new Map<String, String>{'Id'=> String.join(new List<Id>(setMemIds), ',')}); 


          //   lstMembers = [select Id,Name,BirthDate__c,CanBuyCookWithHOH__c,SponsoredIndividual__c, InternalAlienSponsor__c,ExternalAlienSponsor__c from SSP_Member__c where id =:setMemIds];
             for(SSP_Member__c objMem : lstMembers){ SSP_HouseHoldMeals.WrapperHHMeals objWrapper = new SSP_HouseHoldMeals.WrapperHHMeals();
                objWrapper.sMemberName = objMem.FirstName__c+' '+objMem.LastName__c; 
                objWrapper.sMemberId = objMem.Id;
                objWrapper.bCanBuyCookWithHOH = objMem.CanBuyCookWithHOH__c;
                objWrapper.sMemberStatus = (indivVsmemberMap != null && indivVsmemberMap.containsKey(objMem.id)) ? indivVsmemberMap.get(objMem.id).MemberStatus__c : null;
               if(null!=indivVsmemberMap.get(objMem.id) && indivVsmemberMap.get(objMem.id).IsHeadOfHousehold__c){
                   objWrapper.bHOH = indivVsmemberMap.get(objMem.id).IsHeadOfHousehold__c;
                    objResponse.put('headOfHousehold',String.valueOf(JSON.serialize(objWrapper)));
                    sLabelValue = system.Label.sspMemberWhoBuysAndCooks + ' ' +  objMem.FirstName__c+' '+objMem.LastName__c ;
                    objResponse.put('sLabel',sLabelValue + ' ?');
                }
               lstWrapper.add(objWrapper);
            }
            

         }

        

       
         objResponse.put('bIsSuccess',true) ; 
         objResponse.put('Result',String.valueOf(JSON.serialize(lstWrapper)));
         objResponse.put('lstMembers',lstMembers);
        }
        catch(Exception ex) {
             objResponse.put('bIsSuccess',false) ;
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldMealsService', 'fetchHouseHoldData', ex.getMessage() , true);
        }        

        return objResponse;
        
    }

    
     /********************************************************************************************
    * @author       Suyash Singhal
    * @date         11/13/2019
    * @description  This method save the member data from component
    * @param        String sMemberIds,String sAppId
    * @return       SSP_LightningResponse
    ********************************************************************************************/
    public static map<String,Object> saveData(String sMemberIds,String sAppId , String mode){

        map<String,Object> objResponse = new map<String,Object>();

        try{
            List<String> lstMemberIds = new List<String>();
            if(String.isNotBlank(sMemberIds)){
                if(sMemberIds.contains(',')){
                lstMemberIds = sMemberIds.split(',');
                }
                else{
                    lstMemberIds.add(sMemberIds);

                }

            }
            
           
            List<SSP_Member__c> lstMembers = (List<SSP_Member__c> )fetchHouseHoldData(new List<String>{sAppId} , mode ).get('lstMembers');
            List<SSP_Member__c> lstMembersToUpdate = new List<SSP_Member__c>();

         
            for(SSP_Member__c objMember : lstMembers){
                if(lstMemberIds.contains(objMember.id)){
               
                    objMember.CanBuyCookWithHOH__c = true;
                }
                else{
                    objMember.CanBuyCookWithHOH__c = false;
                }
                lstMembersToUpdate.add(objMember);
            }
         
            objResponse.put('bIsSuccess',true) ; 
           
            
            ESAPI.accessController().updateAsUser(new Map<ID,SSP_Member__c>(lstMembersToUpdate), new List<String>(SSP_Utility.getFieldsNamesList(lstMembersToUpdate)));
            

        }catch(Exception ex) {
            objResponse.put('bIsSuccess',false) ; 
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldMealsService', 'saveData', ex.getMessage() , true);
        }        

        return objResponse;
    }

}