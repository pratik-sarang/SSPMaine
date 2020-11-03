@isTest
public class AsyncSSP_AddressVerificationWSDLTest {
	@isTest
    public static void testMethod1(){
        AsyncSSP_AddressVerificationWSDLService.AsyncCOT_USAC_County_svcPort dat = new AsyncSSP_AddressVerificationWSDLService.AsyncCOT_USAC_County_svcPort();
   		AsyncSSP_AddressVerificationWSDLService.COT_USAC_County_op1ResponseFuture data1 = new AsyncSSP_AddressVerificationWSDLService.COT_USAC_County_op1ResponseFuture();
        //data1.getValue();
        System.Continuation cont=new system.Continuation(120);
        dat.beginCOT_USAC_County_op1(cont,'rextd','line1','line2','city','state','34567');
    }
    
}