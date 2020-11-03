/* Classname 		:  SSP_UpdateAgentAssisterResWrapper
* @description 	:  This class is the reponse wrapper for Update Agent and Assister
* @author 		:  Rijia Khatun
* @date 		:  21/4/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

public class SSP_UpdateAgentAssisterResWrapper{
    public cls_AckResponse AckResponse;
	public Integer sStatusCode;
	public Boolean isSFFailure = false;
	public class cls_AckResponse {
		public boolean Success;
        public Integer ApplicationNumber;	//Used for Short SNAP Application Number
		public cls_Error Error;
	}
	public class cls_Error {
		public String ErrorCode;	
		public String ErrorDecsription;	
		public String CHFSExceptionId;
	}
	public static SSP_UpdateAgentAssisterResWrapper parse(String json){
		return (SSP_UpdateAgentAssisterResWrapper) System.JSON.deserialize(json, SSP_UpdateAgentAssisterResWrapper.class);
	}
}