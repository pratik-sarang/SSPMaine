/* Classname 		:  SSP_OverlapResponseWrapper
* @description 	:  This class is the request wrapper for Overlap service 
* @author 		:  Rijia Khatun
* @date 		:  03/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
  Rijia Khatun        03/07/2020          Initial Version
**/
public class SSP_OverlapResponseWrapper {
    public Integer sStatusCode;
	public boolean IsDateOverLapping;
	public Integer IndividualId;	
	public List<String> EndDate;
	public String Identifier;
	public SSP_AckResponseWRapper AckResponse;	
	public static SSP_OverlapResponseWrapper parseOverlapResponse(String json){
		return (SSP_OverlapResponseWrapper) System.JSON.deserialize(json, SSP_OverlapResponseWrapper.class);
	}
}