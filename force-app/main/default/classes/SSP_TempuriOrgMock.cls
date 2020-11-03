@isTest
global class SSP_TempuriOrgMock implements WebServiceMock{
    public String returnParam;
     global SSP_TempuriOrgMock(final String returnParam){
        this.returnParam = returnParam;
    }
     global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType){
         if(returnParam=='SubmitPaymentDetail'){
            SSP_tempuriOrg.SubmitPaymentDetailResponse_element response_x= new SSP_tempuriOrg.SubmitPaymentDetailResponse_element();
            response.put('response_x', response_x);
         }else if(returnParam=='GetTOA'){
            SSP_tempuriOrg.GetTOAExcludedIndividualsForSuspensionResponse_element response_x= new SSP_tempuriOrg.GetTOAExcludedIndividualsForSuspensionResponse_element();
            response.put('response_x', response_x);
         }else if(returnParam=='DeleteGood'){
             SSP_tempuriOrg.DeleteGoodCauseDocumentsResponse_element response_x= new SSP_tempuriOrg.DeleteGoodCauseDocumentsResponse_element();
             response.put('response_x', response_x);
         }else if(returnParam=='GetAptc'){
              SSP_tempuriOrg.GetAptcAndCsrAmountsResponse_element response_x= new  SSP_tempuriOrg.GetAptcAndCsrAmountsResponse_element();
             response.put('response_x', response_x);
         }else if(returnParam=='DiscontinueProgram'){
               SSP_tempuriOrg.RequestToDiscontinueProgramResponse_element response_x= new  SSP_tempuriOrg.RequestToDiscontinueProgramResponse_element();
             response.put('response_x', response_x);
         }else if(returnParam=='SubmitNonPayment'){
              SSP_tempuriOrg.SubmitNonPaymentGoodCauseReasonResponse_element response_x= new SSP_tempuriOrg.SubmitNonPaymentGoodCauseReasonResponse_element();
             response.put('response_x', response_x);
         }else if(returnParam=='SaveOverpayment'){
            SSP_tempuriOrg.SaveOverpaymentDiscrepanciesResponse_element response_x= new SSP_tempuriOrg.SaveOverpaymentDiscrepanciesResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='DeleteNonpayment'){
            SSP_tempuriOrg.DeleteNonpaymentGoodCauseDocumentsResponse_element response_x= new  SSP_tempuriOrg.DeleteNonpaymentGoodCauseDocumentsResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SubmitMedicaid'){
            SSP_tempuriOrg.SubmitMedicaidCardRequestResponse_element response_x= new SSP_tempuriOrg.SubmitMedicaidCardRequestResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='InsertWaiver'){
            SSP_tempuriOrg.InsertWaiverScreeningResponse_element response_x= new SSP_tempuriOrg.InsertWaiverScreeningResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SubmitGood'){
            SSP_tempuriOrg.SubmitGoodCauseDocUploadResponse_element response_x= new SSP_tempuriOrg.SubmitGoodCauseDocUploadResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SaveUnknown'){
            SSP_tempuriOrg.SaveUnknownAddressSuspensionResponse_element response_x= new SSP_tempuriOrg.SaveUnknownAddressSuspensionResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SaveMyreward'){
            SSP_tempuriOrg.SaveMyrewardAssignmentResponse_element response_x= new SSP_tempuriOrg.SaveMyrewardAssignmentResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='UpdateMyContact'){
            SSP_tempuriOrg.UpdateMyContactInformationResponse_element response_x= new SSP_tempuriOrg.UpdateMyContactInformationResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='DeleteMyreward'){
            SSP_tempuriOrg.DeleteMyrewardAssignmentResponse_element response_x= new SSP_tempuriOrg.DeleteMyrewardAssignmentResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SFSubmit'){
            SSP_tempuriOrg.SFSubmitEBTRequestResponse_element response_x= new SSP_tempuriOrg.SFSubmitEBTRequestResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SaveHealth'){
            SSP_tempuriOrg.SaveHealthScreeningDetailsResponse_element response_x= new SSP_tempuriOrg.SaveHealthScreeningDetailsResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='GetPreferredMCO'){
            SSP_TempuriOrg.GetPreferredMCOPlanListResponse_element response_x= new SSP_TempuriOrg.GetPreferredMCOPlanListResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='GetIndividual'){
            SSP_tempuriOrg.GetIndividualAuthRepResponse_element response_x= new SSP_tempuriOrg.GetIndividualAuthRepResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SavePreferredPayment'){
            SSP_TempuriOrg.SavePreferredPaymentDetailsResponse_element  response_x= new SSP_TempuriOrg.SavePreferredPaymentDetailsResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SFSubmitMedicaid'){
            SSP_tempuriOrg.SFSubmitMedicaidCardRequestResponse_element  response_x= new SSP_tempuriOrg.SFSubmitMedicaidCardRequestResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SubmitEBT'){
            SSP_tempuriOrg.SubmitEBTRequestResponse_element response_x= new SSP_tempuriOrg.SubmitEBTRequestResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='RequestCase'){
            SSP_tempuriOrg.RequestCaseWithdrawalResponse_element  response_x= new SSP_tempuriOrg.RequestCaseWithdrawalResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='SaveSuspension'){
            SSP_tempuriOrg.SaveIncarcerationSuspensionResponse_element response_x= new SSP_tempuriOrg.SaveIncarcerationSuspensionResponse_element();
           response.put('response_x', response_x);
         }else if(returnParam=='CitizenHearing'){
            SSP_Hearing_TempPuri.CitizenHearingViewDetailsResponse_element response_x= new SSP_Hearing_TempPuri.CitizenHearingViewDetailsResponse_element();
           response.put('response_x', response_x);
         }
         
     
     }

}