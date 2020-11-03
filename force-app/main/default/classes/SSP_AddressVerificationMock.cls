/**
* Class Name    : SSP_AddressVerificationMock
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : Mock for  SSP_AddressVerification_IntUtility service
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
@isTest
public class SSP_AddressVerificationMock implements WebServiceMock{
    public boolean isDiffDeliveryCode=false;
    /**
* method        : doInvoke
* @description  : This method is to give the MOCK response
* @author       : Kommana Lova Durga Prasad
* */
    public void doInvoke(
        Object stub,
        Object request,
        Map<String,Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType ){
            SSP_AddressVerificationWSDLService.COT_USAC_County_op1Response  dummy1 = new SSP_AddressVerificationWSDLService.COT_USAC_County_op1Response();
            SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1 maindummy1 = new SSP_AddressVerificationWSDLService.COT_USAC_County_svcOutVar1();
            maindummy1.record_id = '' ;
            maindummy1.line1 =  '301 Versailles Rd';
            maindummy1.line2 =  '' ;
            maindummy1.city = 'Frankfort';
            maindummy1.state = 'KY';
            maindummy1.zip = '40012';
            maindummy1.cass_line1 = '301 VERSAILLES RD';
            maindummy1.cass_line2 = '';
            maindummy1.cass_city = 'FRANKFORT';
            maindummy1.cass_state = 'KY';
            maindummy1.cass_zip5 = '40601';
            maindummy1.cass_zip4 = '3633';
            maindummy1.cass_zip = '40601-363';
            maindummy1.cass_dpv_code1 = 'AA';
            maindummy1.cass_dpv_code2 = 'BB';  
            maindummy1.cass_dpv_code3 = '';
            maindummy1.cass_dpv_match_flag = 'Y';
            maindummy1.cass_dpv_comm_flag = 'N';
            maindummy1.cass_dpvfp_flag = '';
            maindummy1.cass_lac_ind = '';
            maindummy1.cass_lacs_flag = '';
            maindummy1.cass_lacs_return_code = '';
            maindummy1.cass_suite_return_code = '';
            maindummy1.cass_rdi_ind  = '';
            maindummy1.cass_vac_ind  = 'N';
            maindummy1.cass_no_stat_ind = 'N';
            maindummy1.usps_county_name = 'FRANKLIN';
            maindummy1.usps_county_code = '073';
            maindummy1.mixed_case_line1 = '301 Versailles Rd';
            maindummy1.mixed_case_line2 = '';
            maindummy1.mixed_case_city = 'Frankfort';
            maindummy1.mixed_case_county_name = 'Franklin';
            if(isDiffDeliveryCode){
                maindummy1.cot_mail_delivery_code = 'R';
            }else{
                maindummy1.cot_mail_delivery_code = 'G';
            }
           
            dummy1.return_x = maindummy1;
            response.put('response_x',dummy1);     
        }
    
}