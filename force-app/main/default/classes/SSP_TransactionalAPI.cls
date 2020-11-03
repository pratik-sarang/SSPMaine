public class SSP_TransactionalAPI implements Queueable, Database.AllowsCallouts{
    public SSP_TransactionalAPI() {

    }

    private String jsonData;
    public SSP_TransactionalAPI(String payload) {
        this.jsonData = payload;
    }
    //Method to perform a callout and return an httpResponse
    @InvocableMethod
    public static void sendComList(List < CommunicationLog__c > comList) {
        try {
            AppConfig__c config = AppConfig__c.getInstance('SFMC_DEFAULT_EMAIL');
            if(comList != null) {
                List<String> recipients = new List<String>();
                string payload = '{'+
                                    '"definitionKey":"CommNubRealTimeSending",'+
                                    '"recipients":[';
                for(Integer i = 0; i < comList.size(); i++) {
                    CommunicationLog__c comLog = comList[i];
                    string name;
                    string email_subject;
                    string created_by;
                    string email_template;
                    string external_id;
                    string from_email;
                    string last_modified_by;
                    string owner_id;
                    Boolean processed_reminder;
                    string recipient_phone;
                    Boolean send_mail;
                    Boolean send_sms = false;
                    string senders_name;
                    string senders_phone;
                    Datetime sent_date_time;
                    string sms_receivers;
                    string source_system;
                    string status;
                    string template_body;
                    string template_id;
                    string template_name;
                    string to_email;
                    string triggered_record_id;
                    string triggered_record_name;
                
                    if (String.isBlank(comLog.Name)) name = ''; else name = comLog.Name;
                    if (String.isBlank(comLog.EmailSubject__c)) email_subject = ''; else email_subject = comLog.EmailSubject__c;
                    if (String.isBlank(comLog.CreatedById)) created_by = ''; else created_by = comLog.CreatedById;
                    if (String.isBlank(comLog.Email_Template_Name__c)) email_template = ''; else email_template = comLog.Email_Template_Name__c;
                    if (String.isBlank(comLog.ExternalId__c)) external_id = ''; else external_id = comLog.ExternalId__c;
                    if (String.isBlank(comLog.FromEmail__c)) from_email = ''; else from_email = comLog.FromEmail__c;
                    if (String.isBlank(comLog.LastModifiedById)) last_modified_by = ''; else last_modified_by = comLog.LastModifiedById;
                    if (String.isBlank(comLog.OwnerId)) owner_id = ''; else owner_id = comLog.OwnerId;
                    if (comLog.processed_reminder_batch__c == null) processed_reminder = false; else processed_reminder = comLog.processed_reminder_batch__c;
                    if (String.isBlank(comLog.Recipient_Phone_Number__c)) recipient_phone = ''; else recipient_phone = comLog.Recipient_Phone_Number__c;
                    if (comLog.SendMail__c == null) send_mail = false; else send_mail = comLog.SendMail__c;
                    if (comLog.Send_SMS__c == null) send_sms = false; else send_sms = comLog.Send_SMS__c;
                    if (String.isBlank(comLog.SendersName__c)) senders_name = ''; else senders_name = comLog.SendersName__c;
                    if (String.isBlank(comLog.SendersPhone__c)) senders_phone = ''; else senders_phone = comLog.SendersPhone__c;
                    if (comLog.SentDateTime__c == null) sent_date_time = null; else sent_date_time = comLog.SentDateTime__c;
                    if (String.isBlank(comLog.SMSReceivers__c)) sms_receivers = ''; else sms_receivers = comLog.SMSReceivers__c;
                    if (String.isBlank(comLog.SourceSystem__c)) source_system = ''; else source_system = comLog.SourceSystem__c;
                    if (String.isBlank(comLog.Status__c)) status = ''; else status = comLog.Status__c;
                    if (String.isBlank(comLog.TemplateBody__c)) template_body = ''; else template_body = comLog.TemplateBody__c;
                    if (String.isBlank(comLog.TemplateId__c)) template_id = ''; else template_id = comLog.TemplateId__c;
                    if (String.isBlank(comLog.TemplateName__c)) template_name = ''; else template_name = comLog.TemplateName__c;
                    if (String.isBlank(comLog.ToEmail__c)) to_email = ''; else to_email = comLog.ToEmail__c;
                    if (String.isBlank(comLog.TriggeredRecordId__c)) triggered_record_id = ''; else triggered_record_id = comLog.TriggeredRecordId__c;
                    if (String.isBlank(comLog.TriggeredRecordName__c)) triggered_record_name = ''; else triggered_record_name = comLog.TriggeredRecordName__c;
                    
                    // correct formatting for template_body

                    string template_body_modified =    template_body.replace('\"','\\"') ;                          
                    
                    // replace newline of apex
                    template_body_modified = template_body_modified.replace('\r\n','<br/>');
                    template_body_modified = template_body_modified.replace('\n','<br/>');
                    template_body_modified = template_body_modified.replace('\r','<br/>');
                    //For SMS calls removing the HTML tags out of the template body
                    if(send_sms) {
                        template_body_modified = template_body_modified.stripHtmlTags();
                        template_body_modified = template_body_modified.replace('\"','\\"') ;
                        template_body_modified = template_body_modified.replace('\n',' ');
                    }
                    // end correct formatting
                    
                    recipients.add(
                        '{'+
                            '"contactKey":"' + (send_sms==true ? config.Value__c:to_email) + '",'+
                            '"to":"' + (send_sms==true ? config.Value__c:to_email) + '",'+
                            '"attributes":{'+
                                '"Communication Nub Name":"' + name + '",'+
                                '"Email Subject":"' + email_subject + '",'+
                                '"Created By":"' + created_by + '",'+
                                '"Email Template Name":"' + email_template + '",'+
                                '"ExternalId":"' + external_id + '",'+
                                '"From Email":"' + from_email + '",'+
                                '"Last Modified By":"' + last_modified_by + '",'+
                                '"Owner":"' + owner_id + '",'+
                                '"processed_reminder_batch":"' + processed_reminder + '",'+
                                '"Recipient Phone Number":"' + recipient_phone + '",'+
                                '"Send Mail":"' + send_mail + '",'+
                                '"Sender Name":"' + senders_name + '",'+
                                '"Sender Phone":"' + senders_phone + '",'+
                                '"Send SMS":"' + send_sms + '",'+
                                '"SMS Receivers":"' + sms_receivers + '",'+
                                '"SourceSystem":"' + source_system + '",'+
                                '"Status":"' + status + '",'+
                                '"Template Body":"' + template_body_modified + '",'+
                                '"Template Id":"' + template_id + '",'+
                                '"Template Name":"' + template_name + '",'+
                                '"To Email":"' + to_email + '",'+
                                '"Triggered Record Id":"' + triggered_record_id + '",'+
                                '"Triggered Record Name":"' + triggered_record_name + '"'+
                            '}'+
                        '}'
                    );
            }
            payload += String.join(recipients, ',');
            payload += ']'+'}';
            System.enqueueJob(new SSP_TransactionalAPI(payload));
            }
        } catch (Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_TransactionalAPI', 'sendComList', 'Failed to Invoke SFMC service', true); 
        }
    }
    
    /**
     * This method is to invoke the SFMC services
     */
    public void sendComToMC() {
        try {
            // get access token
            String token;
            REIntegrationEndpoints__c endpointObj = REIntegrationEndpoints__c.getInstance('SSP_SFMC');
            SSP_SendComToMC_RequestWrapper request = new SSP_SendComToMC_RequestWrapper();
            request.grant_type = SSP_InterfaceConstants.SSP_SFMC_GRANT_TYPE;
            request.client_id = endpointObj.Client_Id__c; 
            request.client_secret = endpointObj.Client_Secret__c;
            request.account_id = SSP_InterfaceConstants.SSP_SFMC_ACCOUNT_ID;
            List<LOG_LogMessage__c> logMessages = new List<LOG_LogMessage__c>();
            Map<String,object> mapTokenParams = new Map<String,object>();
            mapTokenParams.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(request));    
            List<object> tokenResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_GENERATE_TKN, mapTokenParams);
            if(tokenResponses != null && !tokenResponses.isEmpty()) {
                if(tokenResponses.size() > 1) {
                    logMessages.add((LOG_LogMessage__c)tokenResponses[1]);
                }
                SSP_SendComToMC_ResponseWrapper tokenResponse = (SSP_SendComToMC_ResponseWrapper) tokenResponses[0];
                token = tokenResponse.access_token;
            }
            
            Map<String,object> mapEmailParams = new Map<String,object>();
            mapEmailParams.put('token', token);
            mapEmailParams.put(SSP_InterfaceConstants.JSON_BODY, jsonData); 
            List<object> mailResponse = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_SENDCOMTOMC_EMAIL, mapEmailParams);
            if(mailResponse.size() > 1) {
                logMessages.add((LOG_LogMessage__c)mailResponse[1]);
            }

            if(!logMessages.isEmpty()) {
                insert logMessages;
            }
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_TransactionalAPI', 'sendComToMC', 'Failed to Invoke SFMC service', true);
        }
    }

    /*
     * Method Name          : execute
     * Params               : context - Queable context
     * Description          : Method for enque job
     */
    public void execute(QueueableContext context) {
        sendComToMC();
    }
}