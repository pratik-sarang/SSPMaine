/**************************************************************************************
* Apex Class Name:  IIntegrationService
* Version     : 1.0 
* Created Date    : 14 Nov 2019
* Function    : This class is to generate Request and invoke request and process it. 
*
* Modification Log :
* Developer         Date            ModificationId          Description
* ----------------------------------------------------------------------------                 
* Abdulrehman       14 Nov 2019     Version 1.0             This interface will be implemented by functionality specific handler
*************************************************************************************/
public Interface IIntegrationService{

    /*create request JSON to be sent to endpoint in this method's definition*/
    //HttpRequest generateRequest(Map<String, object> mapInputParams);

    /*process the success and failure responses in the method's definition*/
   // List<Object> processResponse(List<Object> lstResponseObject, HttpRequest request, HttpResponse response);

    /*This method will call generate response then invoke the callout using utility methods 
    and at the end will call process response Also, it will return the processed response back to caller*/
    List<Object> invokeCallout(String developerName, Map<String, object> mapInputParams);
}