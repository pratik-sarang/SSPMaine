/*
* Classname         :  SSP_ClaimPaymentURL
* @description  :  This class is the request wrapper class for ClaimPaymentURL
* @author       :  Rijia Khatun
* @date         :  06/15/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
  Rijia Khatun        06/15/2020          Initial Version
**/
public class SSP_ClaimPaymentURLRequestWrapper {
	public String PaymentSuccessRedirectURI;	
	public String PaymentErrorRedirectURI;
	public cls_CartItems CartItems;
	public String acceptedPaymentType;	
	public String paymentCancelRedirectURI;	
	public class cls_CartItems {
		public cls_CartItem[] CartItem;
	}
	public class cls_CartItem {
		public String Amount;	
		public String Description;	
		public String DisplayOrder;
		public String PAFFree;	
		public String Quantity;
		public String SmartCode;	
		public String Subtotal;	
		public String LocalReferenceId;	
	}
}
