global class SSP_ProgramSelectionServiceMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(Schema.sObjectType.User.isAccessible()){  //Iron Dome - isAccessible Fix
            User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
            
            System.runAs(u){
                System.assertEquals(SSPIntegrationEndpoints__c.getInstance('CreateAccountService').URL__c, req.getEndpoint());
                list<account> accList = new Account[]{new Account(name='test1')};
                    Map<String, Object> reqMap = (Map<String, Object>)JSON.deserializeUntyped(req.getBody());
                
                
                
                String resultJSON = SSP_AccountCreationService.doPost((String)reqMap.get('dataString'),
                                                                    (String)reqMap.get('signatureString'),
                                                                    (String)reqMap.get('accountsJSON'),
                                                                    (String)reqMap.get('contactsJSON'),
                                                                    (String)reqMap.get('sCurrentUserContactId')
                                                                    );
                res.setHeader('Content-Type', 'application/json');
                res.setBody(resultJSON);
                res.setStatusCode(200);
            }
        }
        return res;
    }
}