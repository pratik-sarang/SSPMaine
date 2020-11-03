@isTest
global class tempuriOrgMock implements WebServiceMock{
    
    public String abc;
    
    global tempuriOrgMock(final String abc){
        this.abc = abc;
    }
    global void doInvoke(Object stub,
                         Object request,
                         Map<String, Object> response,
                         String endpoint,
                         String soapAction,
                         String requestName,
                         String responseNS,
                         String responseName,
                         String responseType){
                             //KOGWebservice__c objKogIS = [SELECT ID,Name from KOGWebservice__c where name = 'KOG Inquiry Service' LIMIT 1];
                             //KOGWebservice__c objKogCP = [SELECT ID,Name from KOGWebservice__c where name = 'KOG CP Admin' OR name = 'KOG CP Staff' LIMIT 1];
                             //if(){
                             if(abc == 'A'){
                                 response.clear();
                                 tempuriOrg.UserEnrollCheckResponse_element response_x = new tempuriOrg.UserEnrollCheckResponse_element();
                                 response_x.UserEnrollCheckResult = 3;
                                 
                                 response.put('response_x', response_x);
                             }
                             if(abc == 'B'){
                                
                                 response.clear();
                                 tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element response_y = new tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element();
                                 response_y.SaveAddRoleParametersExResult = 'qwertyu';
                                
                                 response.put('response_x', response_y);
                             }
                             //response.put('response_x', response_x);
                             //}
                             /*if(objKogCP.Name == 'KOG CP Admin' || objKogCP.Name == 'KOG CP Admin'){
tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element response_x = new tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element();
response_x.SaveAddRoleParametersExResult = 'qwertyu';

//response.put('response_x', response_x);

}*/
                             
                         }
}