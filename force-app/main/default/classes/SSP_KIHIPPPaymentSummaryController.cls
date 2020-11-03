/*
 * Classname             : SSP_KIHIPPPaymentSummaryController
 * @description          : This is controller class for KIHIPP Payment Summary widget
 * @author               : Anuja Ingole
 * @date                 : 06/17/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_KIHIPPPaymentSummaryController {
    public static Map<String, String> mapMonthAbbrToNumber = new Map<String, String>();
    
    public static List<UserCard> lstMasterCards = new List<UserCard>(); //list to hold usercards for all members
    public static List<UserCard> lstCurrentCards = new List<UserCard>(); //list to hold current usercards as per view more
    public static integer maxCardPerPage = 10;
    
    @AuraEnabled
    public static SSP_LightningResponse fetchPaymentSummary(String individualId){
        SSP_LightningResponse response = new SSP_LightningResponse();
        Map<String, List<SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper>> mapSummary = new Map<String, List<SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper>>();
        Map<String, List<SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper>> mapPremium = new Map<String, List<SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper>>();
        Map<String, List<SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper>> mapAdjustmentDetails = new Map<String, List<SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper>>();
        Map<String, List<String>> mapIndIdToPaymendIds = new Map<String, List<String>>();
        List<SummaryWrapper> lstSummaryWrapper = new List<SummaryWrapper>();
        Map<String, List<UserCard>> mapData = new Map<String, List<UserCard>>();
        boolean showMore = false;
        
        populateMapMonthAbbrToNumber();

        if(individualId != null){
            /** RSSPDC - KHIPP Payment Summary*/
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY;
            reqWrapper.primaryApplicationIndividualId = individualId; //'999015984'; //999016239
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);              
            RSSP_DC_Wrapper dCWrapper = (RSSP_DC_Wrapper) serviceResponses[0];
            SSP_KHIPPPaymentSummaryWrapper KIHIPPWrapper = new SSP_KHIPPPaymentSummaryWrapper();
            KIHIPPWrapper = (SSP_KHIPPPaymentSummaryWrapper) dCWrapper.KHIPPPaymentSummaryPayload;
            
            //Iterate on response to populate respective map for summary
            if(KIHIPPWrapper!= null && KIHIPPWrapper.Summary != null){
                for(SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper summary: KIHIPPWrapper.Summary){
                    if(!mapSummary.isEmpty() && mapSummary.containsKey(summary.KHIPPFinalPaymentId)){
                        List<SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper> lstSummary = mapSummary.get(summary.KHIPPFinalPaymentId);
                        lstSummary.add(summary);
                        mapSummary.put(summary.KHIPPFinalPaymentId,lstSummary);
                    }else{
                        mapSummary.put(summary.KHIPPFinalPaymentId,new List<SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper>{summary});
                    }

                    //populate another map of individual id to payment id to group all payments under each member on summary
                    if(!mapIndIdToPaymendIds.isEmpty() && mapIndIdToPaymendIds.containsKey(summary.IndividualId)){
                        List<String> lstPaymentId = mapIndIdToPaymendIds.get(summary.IndividualId); 
                        lstPaymentId.add(summary.KHIPPFinalPaymentId);
                        mapIndIdToPaymendIds.put(summary.IndividualId, lstPaymentId);
                    }else{
                        mapIndIdToPaymendIds.put(summary.IndividualId, new List<String>{summary.KHIPPFinalPaymentId});
                    }
                }
                
            }

            //Iterate on response to populate respective map for premium
            if(KIHIPPWrapper!= null && KIHIPPWrapper.PremiumDetails != null){
                for(SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper wrapper: KIHIPPWrapper.PremiumDetails){
                    if(!mapPremium.isEmpty() && mapPremium.containsKey(wrapper.KHIPPFinalPaymentId)){
                        List<SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper> lst = mapPremium.get(wrapper.KHIPPFinalPaymentId);
                        lst.add(wrapper);
                        mapPremium.put(wrapper.KHIPPFinalPaymentId,lst);
                    }
                    else{
                        mapPremium.put(wrapper.KHIPPFinalPaymentId,new List<SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper>{wrapper});
                    }
                }
                
            }

            //Iterate on response to populate respective map for adjustments
            if(KIHIPPWrapper!= null && KIHIPPWrapper.AdjustmentDetails != null){
                for(SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper wrapper: KIHIPPWrapper.AdjustmentDetails){
                    if(!mapAdjustmentDetails.isEmpty() && mapAdjustmentDetails.containsKey(wrapper.KHIPPFinalPaymentId)){
                        List<SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper> lst = mapAdjustmentDetails.get(wrapper.KHIPPFinalPaymentId);
                        lst.add(wrapper);
                        mapAdjustmentDetails.put(wrapper.KHIPPFinalPaymentId,lst);
                    }
                    else{
                        mapAdjustmentDetails.put(wrapper.KHIPPFinalPaymentId,new List<SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper>{wrapper});
                    }
                }
                
            }
            
            //for each payment id in summary, iterate on premiums and adjustments and add them in wrapper.
            if(!mapIndIdToPaymendIds.isEmpty()){
                for(String indivId: mapIndIdToPaymendIds.keySet()){
                    SummaryWrapper UIWrapper = new SummaryWrapper();
                        //considering there will only be one entry in summary per payment id
                        SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper summaryWrapper = mapSummary.get(mapIndIdToPaymendIds.get(indivId)[0])[0];
                        UIWrapper.userName =  summaryWrapper.IndividualName;
                        List<UserCard> lstCards = new List<UserCard>();

                    //Iterate to generate each card    
                    for(String paymentId : mapIndIdToPaymendIds.get(indivId)){
                        //each card on screen for each payment id
                        UserCard card = new UserCard();
                        card.userName =  summaryWrapper.IndividualName;
                        SSP_KHIPPPaymentSummaryWrapper.SummaryWrapper summary = mapSummary.get(paymentId)[0];
                       // card.reimbursedDate = summary.ReimbursedDate;
                        // Defect 380144 : Expected Date format MM/DD/YYYY
                         card.reimbursedDate = summary.ReimbursedDate!=null ?(summary.ReimbursedDate.split('-')[1]+'/'+summary.ReimbursedDate.split('-')[2]+'/'+summary.ReimbursedDate.split('-')[0]): null;
                      
                        card.reimbursedAmount = Decimal.valueOf(summary.TotalAmount);
                        card.benefitMonth = summary.ReimbursedMonth_Year;
                        try{
                            if(summary.ReimbursedDate!= null){
                                String year = summary.ReimbursedDate.split('-')[0];
                                String month = summary.ReimbursedDate.split('-')[1];
                                String day = summary.ReimbursedDate.split('-')[2];
                                card.benefitMonth_date = date.valueOf(year+'-'+ month+'-'+day);  
                            }
                        }
                        catch(Exception ex){
                            
                        }
                        card.totalPremium = summary.TotalPremium;
                        card.adjustmentAmount = summary.Adjustment;
                        

                        List<ModalTotalPremium> lstPremiums = new List<ModalTotalPremium>();
                        List<ModalAdjustment> lstAdjustments = new List<ModalAdjustment>();
                        

                        //create wrapper for premiums
                        if(!mapPremium.isEmpty() && mapPremium.containsKey(paymentId)){
                            
                            for(SSP_KHIPPPaymentSummaryWrapper.PremiumDetailsWrapper wrapper: mapPremium.get(paymentId)){
                                ModalTotalPremium premium = new ModalTotalPremium();
                                premium.totalBenefitMonth = wrapper.BenefitMonth_Year;
                                premium.approvedPremium = wrapper.ApprovedPremium;
                                premium.electiveAbortion = wrapper.ElectiveAbortion;
                                lstPremiums.add(premium);
                            }
                            
                        }
    
                        //create a wrapper for adjustments
                        if(!mapAdjustmentDetails.isEmpty() && mapAdjustmentDetails.containsKey(paymentId)){
                            for(SSP_KHIPPPaymentSummaryWrapper.AdjustmentDetailsWrapper wrapper: mapAdjustmentDetails.get(paymentId)){
                                ModalAdjustment adjustment = new ModalAdjustment();
                                adjustment.adjustmentBenefitMonth= wrapper.BenefitMonth_Year;
                                adjustment.reason= wrapper.Reason;
                                adjustment.amount= wrapper.AdjustmentAmount;
                                lstAdjustments.add(adjustment);
                            }
                            
                        }
                        card.modalTotalPremium = lstPremiums;
                        card.modalAdjustment = lstAdjustments;
                        lstCards.add(card);
                    }
                    UIWrapper.userCard = lstCards;
                    lstMasterCards.addAll(lstCards);
                    
                    lstSummaryWrapper.add(UIWrapper);
                }
            }
            if(lstMasterCards != null && lstMasterCards.size()>0){
                lstMasterCards.sort(); //sort descending to show latest benefit month
                if(lstMasterCards.size()>maxCardPerPage){
                    for(integer i=0; i<maxCardPerPage; i++){
                        lstCurrentCards.add(lstMasterCards[i]);
                    }
                    showMore = true;
                }
                else{
                    for(integer i=0; i<lstMasterCards.size(); i++){
                        lstCurrentCards.add(lstMasterCards[i]);
                    }
                    showMore = false;
                }
                
                
                for(integer i=0; i<lstCurrentCards.size(); i++){
                    if(!mapdata.isEmpty() && mapdata.containsKey(lstCurrentCards[i].userName)){
                        List<UserCard> templst = mapData.get(lstCurrentCards[i].userName);
                        templst.add(lstCurrentCards[i]);
                        mapdata.put(lstCurrentCards[i].userName, templst);
                    }else{
                        mapdata.put(lstCurrentCards[i].userName, new List<UserCard> {lstCurrentCards[i]});
                    }
                }
                
                lstSummaryWrapper = new List<SummaryWrapper>();
                for(String key: mapdata.keySet()){
                    SummaryWrapper outputWrapper = new SummaryWrapper();
                     outputWrapper.userName = key;
                     outputWrapper.userCard = mapdata.get(key);
                     lstSummaryWrapper.add(outputWrapper);
                }
                response.put('summaryWrapper',JSON.serialize(lstSummaryWrapper));
                response.put('showMore',showMore);
                response.put('masterCards',JSON.serialize(lstMasterCards));
            }
            
            
        }

        

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
          
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('BEN_KIHIPSUM',selectedRole);
           
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                response.put('showScreen',true);
            }else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
                response.put('showScreen',false);
                
            }
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='ReadOnly'){
                response.put('showScreen',true);
            }

        return response;
    }

    @AuraEnabled
    public static SSP_LightningResponse fetchMoreRecords(String individualId, integer offset, string lstCards){
        List<SummaryWrapper> lstSummaryWrapper = new List<SummaryWrapper>();
        Map<String, List<UserCard>> mapData = new Map<String, List<UserCard>>();
        integer maxx;
        SSP_LightningResponse response = new SSP_LightningResponse();
        lstMasterCards= (List<UserCard>) JSON.deserialize(lstCards, List<UserCard>.class);
        
        integer newCount = offset + maxCardPerPage;
        
        if(newCount <lstMasterCards.size()){
            response.put('showMore',true);
            maxx = newCount;

        }else{
            response.put('showMore',false);
            maxx = lstMasterCards.size();
        }
        
        for(integer i=0; i<maxx; i++){
            if(!mapdata.isEmpty() && mapdata.containsKey(lstMasterCards[i].userName)){
                List<UserCard> templst = mapData.get(lstMasterCards[i].userName);
                templst.add(lstMasterCards[i]);
                mapdata.put(lstMasterCards[i].userName, templst);
            }else{
                mapdata.put(lstMasterCards[i].userName, new List<UserCard> {lstMasterCards[i]});
            }
        }
        
        lstSummaryWrapper = new List<SummaryWrapper>();
        for(String key: mapdata.keySet()){
            SummaryWrapper outputWrapper = new SummaryWrapper();
                outputWrapper.userName = key;
                outputWrapper.userCard = mapdata.get(key);
                lstSummaryWrapper.add(outputWrapper);
        }
        response.put('summaryWrapper',JSON.serialize(lstSummaryWrapper));
        return response;
    }


    //Wrapper for UI
    public class SummaryWrapper{
        String userName;
        List<UserCard> userCard;
    }
    //Wrapper for UI
    public class UserCard implements Comparable{
        String userName;
        String reimbursedDate; //ReimbursedDate
        Decimal reimbursedAmount; //TotalAmount
        String benefitMonth; //ReimbursedMonth_Year
        Date benefitMonth_date;//derived date field for benefit month
        String totalPremium; //TotalPremium
        String adjustmentAmount; //Adjustment
        List<ModalTotalPremium> modalTotalPremium;
        List<ModalAdjustment> modalAdjustment;

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            UserCard card = (UserCard)compareTo;
            if (benefitMonth_date == card.benefitMonth_date) return 0;
            if (benefitMonth_date > card.benefitMonth_date) return -1;
            return 1;        
        }
    }
    //Wrapper for UI
    public class ModalTotalPremium{
        String totalBenefitMonth; //BenefitMonth_Year
        String approvedPremium; //ApprovedPremium
        String electiveAbortion; //ElectiveAbortion
    }
    //Wrapper for UI
    public class ModalAdjustment{
        String adjustmentBenefitMonth; //BenefitMonth_Year
        String reason; //Reason
        String amount; //AdjustmentAmount
    }

    public static void populateMapMonthAbbrToNumber(){
        mapMonthAbbrToNumber.put('Jan','1');
        mapMonthAbbrToNumber.put('Feb','2');
        mapMonthAbbrToNumber.put('Mar','3');
        mapMonthAbbrToNumber.put('Apr','4');
        mapMonthAbbrToNumber.put('May','5');
        mapMonthAbbrToNumber.put('Jun','6');
        mapMonthAbbrToNumber.put('Jul','7');
        mapMonthAbbrToNumber.put('Aug','8');
        mapMonthAbbrToNumber.put('Sep','9');
        mapMonthAbbrToNumber.put('Oct','10');
        mapMonthAbbrToNumber.put('Nov','11');
        mapMonthAbbrToNumber.put('Dec','12');
    }
}