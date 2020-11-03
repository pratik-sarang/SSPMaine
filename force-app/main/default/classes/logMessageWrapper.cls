/**
 * Classname                   :  logMessageWrapper
 * @description                :  LogMessage Wrapper Class
 * @author                     :  Rajeev Kumar
 * @date                       :  03/24/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName               MM/DD/YYYY                 A Brief Description about the Change
 **/
public with sharing class logMessageWrapper {
    // public attributes
    public Integer startTime;
    public Id logMessageId;
    public Long timeTaken;
    public string endpoint;
    public string message;
    public string source;
    public string sourceFunction;
    public string type;
    public string responseCode;
    public boolean executeDML;
    public string interfaceName;
    public string payload;
    public string responseData;
    public String LogNumber;
    public LOG_LogMessageUtility.LOG_LogLevel logLevel;

    
    /**
     * @description         : Default Constructor
     */    
    public logMessageWrapper() {
        this.executeDML = false;
    }
}