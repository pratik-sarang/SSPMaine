public with sharing class SSP_MedicalEnforcementRule extends BasicNavFlowRule{

     /**
     * Invoked on workflow "next" action. If true is returned then the page will be marked as "required" in the
     * current flow and so it will be queued to be loaded on its turn. If false is returned then the page
     * will be marked as "not required" and hence will not be loaded in the flow.
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */
    public override boolean isRequired(Context ctx, ContextData ctxData){
        
        Boolean result = false;
       
         try{
                if(ctxData.MemberId != null && ctxData.MemberId != ''){

                    string sApplicationId = ctxData.ApplicationId;
                    
	
					
                    List<SSP_ApplicationIndividual__c> lstAppIndividuals =  SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                                                                        new Set<String>{'Id','SSP_Member__c', 'SSP_Application__c','ProgramsApplied__c','MedicaidType__c'}, 
                                                                                                                                        new Map<String, String>{'limit'=>'100','SSP_Application__c'=> sApplicationId,
                                                                                                                                            'SSP_Member__c'=> ctxData.MemberId});

                    

                 
				
             
                if (!lstAppIndividuals.isEmpty() ){                  
                    String sProgramsApplied  = !lstAppIndividuals.isEmpty() ? lstAppIndividuals[0].ProgramsApplied__c : '';
                
                        if((sProgramsApplied.contains('KT')) && lstAppIndividuals[0].MedicaidType__c != null && lstAppIndividuals[0].MedicaidType__c != ''){
                            result = false; 
                        }
                       

                 }
        }
         }
		catch(Exception ex){            
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ChildMedicalEnforcementRule', 'isRequired', ex.getMessage() , true);
        }
        
		return result;
    }
}