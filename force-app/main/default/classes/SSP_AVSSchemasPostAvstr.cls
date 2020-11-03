/*
* Classname     :  SSP_AVSSchemasPostAvstr
* @description  :  This class is a stub class for AVS
* @author       :  Rijia Khatun
* @date         :  02/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/

public class SSP_AVSSchemasPostAvstr {
    public class financialInstitutions_element {
        public String institution;
        public String institutionId;
        private String[] institution_type_info = new String[]{'institution','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] institutionId_type_info = new String[]{'institutionId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'institution','institutionId'};
    }
    public class address_element {
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String state;
        public String zip4;
        public String zip5;
        private String[] addressLine1_type_info = new String[]{'addressLine1','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] addressLine2_type_info = new String[]{'addressLine2','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] city_type_info = new String[]{'city','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] state_type_info = new String[]{'state','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] zip4_type_info = new String[]{'zip4','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] zip5_type_info = new String[]{'zip5','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'addressLine1','addressLine2','city','state','zip4','zip5'};
    }
    public class propertyUse_element {
        public String code;
        public String description;
        private String[] code_type_info = new String[]{'code','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] description_type_info = new String[]{'description','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'code','description'};
    }
    public class error_element {
        public String statusCode;
        public String message;
        public String field;
        private String[] statusCode_type_info = new String[]{'statusCode','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] message_type_info = new String[]{'message','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] field_type_info = new String[]{'field','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'statusCode','message','field'};
    }
    public class reasonCodes_element {
        public String code;
        public String description;
        private String[] code_type_info = new String[]{'code','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] description_type_info = new String[]{'description','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'code','description'};
    }
    public class employmentHistory_element {
        public String employerCode;
        public String employerName;
        public String employerName2;
        public String statusMessage;
        public String lastPayPeriod;
        private String[] employerCode_type_info = new String[]{'employerCode','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] employerName_type_info = new String[]{'employerName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] employerName2_type_info = new String[]{'employerName2','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] statusMessage_type_info = new String[]{'statusMessage','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] lastPayPeriod_type_info = new String[]{'lastPayPeriod','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'employerCode','employerName','employerName2','statusMessage','lastPayPeriod'};
    }
    public class events_element {
        public String eventText;
        public String eventType;
        private String[] eventText_type_info = new String[]{'eventText','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] eventType_type_info = new String[]{'eventType','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'eventText','eventType'};
    }
    public class propertyInformation_element {
        public SSP_AVSSchemasPostAvstr.error_element error;
        public SSP_AVSSchemasPostAvstr.events_element[] events;
        public SSP_AVSSchemasPostAvstr.transactions_element[] transactions;
        private String[] error_type_info = new String[]{'error','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] events_type_info = new String[]{'events','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] transactions_type_info = new String[]{'transactions','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'error','events','transactions'};
    }
    public class customFields_element {
        public String id;
        public String name;
        public String value;
        private String[] id_type_info = new String[]{'id','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] name_type_info = new String[]{'name','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] value_type_info = new String[]{'value','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'id','name','value'};
    }
    public class POST_AVSTransactionResponse_element {
        public String transactionId;
        public SSP_AVSSchemasPostAvstr.identity_element identity;
        public String[] selectedPrograms;
        public SSP_AVSSchemasPostAvstr.identityCheckInformation_element identityCheckInformation;
        public SSP_AVSSchemasPostAvstr.employmentInformation_element employmentInformation;
        public SSP_AVSSchemasPostAvstr.accountInformation_element accountInformation;
        public SSP_AVSSchemasPostAvstr.propertyInformation_element propertyInformation;
        public Boolean simulationEnabled;
        public String datasourceResponses;
        public SSP_AVSSchemasPostAvstr.user_element user_x;
        private String[] transactionId_type_info = new String[]{'transactionId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] identity_type_info = new String[]{'identity','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] selectedPrograms_type_info = new String[]{'selectedPrograms','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] identityCheckInformation_type_info = new String[]{'identityCheckInformation','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] employmentInformation_type_info = new String[]{'employmentInformation','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] accountInformation_type_info = new String[]{'accountInformation','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] propertyInformation_type_info = new String[]{'propertyInformation','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] simulationEnabled_type_info = new String[]{'simulationEnabled','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] datasourceResponses_type_info = new String[]{'datasourceResponses','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] user_x_type_info = new String[]{'user','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'transactionId','identity','selectedPrograms','identityCheckInformation','employmentInformation','accountInformation','propertyInformation','simulationEnabled','datasourceResponses','user_x'};
    }
    public class accountInformation_element {
        public SSP_AVSSchemasPostAvstr.financialInstitutions_element[] financialInstitutions;
        public SSP_AVSSchemasPostAvstr.error_element error;
        private String[] financialInstitutions_type_info = new String[]{'financialInstitutions','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] error_type_info = new String[]{'error','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'financialInstitutions','error'};
    }
    public class identityCheckInformation_element {
        public String decision;
        public SSP_AVSSchemasPostAvstr.reasonCodes_element[] reasonCodes;
        public SSP_AVSSchemasPostAvstr.error_element error;
        private String[] decision_type_info = new String[]{'decision','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] reasonCodes_type_info = new String[]{'reasonCodes','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] error_type_info = new String[]{'error','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'decision','reasonCodes','error'};
    }
    public class employmentInformation_element {
        public SSP_AVSSchemasPostAvstr.employmentHistory_element[] employmentHistory;
        public SSP_AVSSchemasPostAvstr.error_element error;
        private String[] employmentHistory_type_info = new String[]{'employmentHistory','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] error_type_info = new String[]{'error','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'employmentHistory','error'};
    }
    public class user_element {
        public String id;
        public String username;
        public String email;
        public SSP_AVSSchemasPostAvstr.customFields_element[] customFields;
        private String[] id_type_info = new String[]{'id','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] username_type_info = new String[]{'username','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] email_type_info = new String[]{'email','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] customFields_type_info = new String[]{'customFields','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'id','username','email','customFields'};
    }
    public class transactions_element {
        public String marketValue;
        public String parcelNumber;
        public String priceOnTransaction;
        public String transactionDate;
        public String nameOnDeed;
        public SSP_AVSSchemasPostAvstr.address_element address;
        public String transactionType;
        public SSP_AVSSchemasPostAvstr.propertyUse_element propertyUse;
        private String[] marketValue_type_info = new String[]{'marketValue','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] parcelNumber_type_info = new String[]{'parcelNumber','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] priceOnTransaction_type_info = new String[]{'priceOnTransaction','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] transactionDate_type_info = new String[]{'transactionDate','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] nameOnDeed_type_info = new String[]{'nameOnDeed','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] address_type_info = new String[]{'address','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] transactionType_type_info = new String[]{'transactionType','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] propertyUse_type_info = new String[]{'propertyUse','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionResponse','false','false'};
        private String[] field_order_type_info = new String[]{'marketValue','parcelNumber','priceOnTransaction','transactionDate','nameOnDeed','address','transactionType','propertyUse'};
    }
    public class dateOfBirth_element {
        public String year;
        public String month;
        public String date_x;
        private String[] year_type_info = new String[]{'year','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] month_type_info = new String[]{'month','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] date_x_type_info = new String[]{'date','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'year','month','date_x'};
    }
    public class POST_AVSTransactionRequest_element {
        public String[] programs;
        public SSP_AVSSchemasPostAvstr.identity_element identity;
        public String organizationId;
        public String WorkerFirstName;
        public String WorkerLastName;
        public String IsOverride;
        public String TransactionId;
        public String WorkerUserId;
        private String[] programs_type_info = new String[]{'programs','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','-1','false'};
        private String[] identity_type_info = new String[]{'identity','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] organizationId_type_info = new String[]{'organizationId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] WorkerFirstName_type_info = new String[]{'WorkerFirstName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] WorkerLastName_type_info = new String[]{'WorkerLastName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] IsOverride_type_info = new String[]{'IsOverride','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] TransactionId_type_info = new String[]{'TransactionId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] WorkerUserId_type_info = new String[]{'WorkerUserId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'programs','identity','organizationId','WorkerFirstName','WorkerLastName','IsOverride','TransactionId','WorkerUserId'};
    }
    public class addresses_element {
        public String type_x;
        public String city;
        public String state;
        public String zip;
        public String addressLine;
        private String[] type_x_type_info = new String[]{'type','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] city_type_info = new String[]{'city','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] state_type_info = new String[]{'state','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] zip_type_info = new String[]{'zip','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] addressLine_type_info = new String[]{'addressLine','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'type_x','city','state','zip','addressLine'};
    }
    public class phoneNumber_element {
        public String areaCode;
        public String extension;
        public String telephoneNumber;
        private String[] areaCode_type_info = new String[]{'areaCode','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] extension_type_info = new String[]{'extension','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] telephoneNumber_type_info = new String[]{'telephoneNumber','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'areaCode','extension','telephoneNumber'};
    }
    public class name_element {
        public String firstName;
        public String middleName;
        public String lastName;
        public String suffix;
        private String[] firstName_type_info = new String[]{'firstName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] middleName_type_info = new String[]{'middleName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] lastName_type_info = new String[]{'lastName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] suffix_type_info = new String[]{'suffix','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'firstName','middleName','lastName','suffix'};
    }
    public class identity_element {
        public String simulationId;
        public SSP_AVSSchemasPostAvstr.name_element name;
        public SSP_AVSSchemasPostAvstr.addresses_element addresses;
        public SSP_AVSSchemasPostAvstr.dateOfBirth_element dateOfBirth;
        public String socialSecurityNumber;
        public SSP_AVSSchemasPostAvstr.phoneNumber_element phoneNumber;
        public String clientTrackingId;
        public String sourceSystemId;
        public String sourceName;
        public Boolean IsSsnValidated;
        private String[] simulationId_type_info = new String[]{'simulationId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] name_type_info = new String[]{'name','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] addresses_type_info = new String[]{'addresses','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] dateOfBirth_type_info = new String[]{'dateOfBirth','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] socialSecurityNumber_type_info = new String[]{'socialSecurityNumber','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] phoneNumber_type_info = new String[]{'phoneNumber','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] clientTrackingId_type_info = new String[]{'clientTrackingId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] sourceSystemId_type_info = new String[]{'sourceSystemId','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] sourceName_type_info = new String[]{'sourceName','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] IsSsnValidated_type_info = new String[]{'IsSsnValidated','http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://Ky.Sdh.Interfaces.AVS.Schemas.POST_AVSTransactionRequest','false','false'};
        private String[] field_order_type_info = new String[]{'simulationId','name','addresses','dateOfBirth','socialSecurityNumber','phoneNumber','clientTrackingId','sourceSystemId','sourceName','IsSsnValidated'};
    }
}