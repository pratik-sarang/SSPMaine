/*
* classname     :  SSP_MedicareCoverageSummary
* @description  :  Class to get medical coverage summary
* @author       :  Varun Kochar   
* @date         :  04/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_MedicareCoverageSummary {
    
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   getMedicalCoverageSummary
* @description  This methods is used to get medical coverage summary
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse getMedicalCoverageSummary(Id memberId){
        try{
            SSP_Utility.isAuthenticatedUser();
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            List<MedicareCoverageSummaryWrapper> wrapper = new List<MedicareCoverageSummaryWrapper>();
            List<SSP_Benefits__c> sspBenefitList = SSP_MedicareCoverageService.getBenefit(new Set<String>{memberId});
            Map<String, String> medicareTypeMap = SSP_MedicareCoverageService.getMedicareTypeMap();
            List<SSP_Member__c> memberList = SSP_MedicareCoverageService.getMember(new Set<String>{memberId});
            String benefitRecordtypeId = Schema.SObjectType.SSP_Benefits__c.getRecordTypeInfosByDeveloperName().get(SSP_GlobalConstants.MEDICAREBENEFIT).getRecordTypeId();
            
            if(!sspBenefitList.isEmpty()){
                for(SSP_Benefits__c benefitObj : sspBenefitList){
                    Boolean displayEdit = String.isNotBlank(benefitObj.MedicareTypeCode__c) || benefitObj.HasMedicareCoverageButNoInfo__c ? true : false;
                    String memberName = benefitObj.SSP_Member__r.FirstName__c + ' ' + benefitObj.SSP_Member__r.LastName__c;
                    String medicareType = String.isNotBlank(benefitObj.MedicareTypeCode__c) ? medicareTypeMap.get(benefitObj.MedicareTypeCode__c) : Label.SSP_MedicareCoverageLabel ;
                    
                    String editButtonAltText = displayEdit ? String.format(Label.SSP_EditCoverageButtonAltText, new List<String>{medicareType}) : Label.SSP_StartCoverageButtonTitle;
                    String removeButtonAltText = String.format(Label.SSP_RemoveCoverageAltText, new List<String>{medicareType});
                    String viewButtonAltText = String.format(Label.SSP_ViewDetails, new List<String>{medicareType});
                    wrapper.add(new MedicareCoverageSummaryWrapper(benefitObj, false, displayEdit, memberName, medicareType, editButtonAltText, removeButtonAltText, '',viewButtonAltText));
                }
            }
            else{
                if(memberList.size()>0 && memberList[0].IsReceivingMedicareBenefitToggle__c== SSP_GlobalConstants.YES){
                SSP_Benefits__c benefitObj = new SSP_Benefits__c(SSP_Member__c = memberList[0].id , RecordtypeId = benefitRecordtypeId);               
                String memberName =memberList[0].FirstName__c + ' ' + memberList[0].LastName__c;
                SSP_MedicareCoverageDetails.saveMedicalCoverageDetail(benefitObj,memberList[0].id);
                String editButtonAltText = Label.SSP_StartCoverageButtonTitle;
                String removeButtonAltText = String.format(Label.SSP_RemoveCoverageAltText, new List<String>{Label.SSP_MedicareCoverageLabel});
                String viewButtonAltText = String.format(Label.SSP_ViewDetails, new List<String>{Label.SSP_MedicareCoverageLabel});
                wrapper.add(new MedicareCoverageSummaryWrapper(benefitObj, false, false, memberName, Label.SSP_MedicareCoverageLabel, editButtonAltText, removeButtonAltText, '',viewButtonAltText));
            	}
            }           
             objResponse.put('wrapper', wrapper);
           
            /** 2.5	Security Role Matrix and Program Access. */
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.MEDICARE_COVERAGE_SUMMARY_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.MEDICARE_COVERAGE_DETAILS_SCREENID, null));
            /** */
            
            return objResponse;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageSummary', 'getMedicalCoverageSummary', e.getMessage(), true);
        }
        return null;
    }
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   removeBenefit
* @description  This methods is used to remove SSP Benefit
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static void removeBenefit(String wrapper ,String memberId , String applicationId){
        try{
            SSP_Utility.isAuthenticatedUser();
            MedicareCoverageSummaryWrapper response = (MedicareCoverageSummaryWrapper)JSON.deserialize(wrapper, MedicareCoverageSummaryWrapper.class);
            List<String> lstTrackDeletionFields = new List<String>{'SSP_Application__c','DCId__c','EndDate__c','EndReason__c','SSP_Member__c','OtherReason__c','ParentDCId__c','SalesforceId__c','Source__c', 'SFObject__c'};
            Boolean bViewTrackDeletionFields = ESAPI.accessController().isAuthorizedToView(SSP_TrackDeletion__c.getSObjectType(), lstTrackDeletionFields);
           // create track deletion record added as part of 372394
             List<SSP_TrackDeletion__c> trackDelRecList = new List<SSP_TrackDeletion__c>();
            SSP_Benefits__c benefitDetails = [select id , DCId__c  from SSP_Benefits__c where id= :response.benefit.id ];
           if(benefitDetails.DCId__c!=null){
               SSP_TrackDeletion__c trackDelRec = new  SSP_TrackDeletion__c();
               trackDelRec.DCId__c= benefitDetails.DCId__c;
               trackDelRec.Source__c='MedicareCoverage';
               trackDelRec.SSP_Application__c=applicationId;
               trackDelRec.SSP_Member__c= response.benefit.SSP_Member__c;
               trackDelRec.SalesforceId__c=  response.benefit.Id;
               trackDelRec.SFObject__c='SSP_Benefits__c';                        
               trackDelRecList.add(trackDelRec);
               if(null!=trackDelRecList && trackDelRecList.size()>0)
                   ESAPI.accessController().insertAsUser(trackDelRecList, lstTrackDeletionFields);            
               response.benefit.IsDeleted__c = true;
               update response.benefit;
           }
            else {
            delete response.benefit;
            }            
            Set<String> membersSet = new  Set<String>{memberId};
            List<SSP_Member__c> members = SSP_MedicareCoverageService.getMember(membersSet);
            List<SSP_Benefits__c> benefitsForMember =SSP_MedicareCoverageService.getBenefit(membersSet);
            if(benefitsForMember.size() == 0){
                if(members!=null && members.size()>0){
                   members[0].IsReceivingMedicareBenefitToggle__c= SSP_GlobalConstants.NO;
                    update members[0];
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageSummary', 'removeBenefit', e.getMessage(), true);
        }
    }
    public class MedicareCoverageSummaryWrapper{
        @AuraEnabled public SSP_Benefits__c benefit;
        @AuraEnabled public Boolean removeBenefit;
        @AuraEnabled public Boolean displayEdit;
        @AuraEnabled public String memberName;
        @AuraEnabled public String medicareType;
        @AuraEnabled public String editButtonAltText;
        @AuraEnabled public String removeButtonAltText;
        @AuraEnabled public String formattedBeginDate;
        @AuraEnabled public String viewButtonAltText;
        public MedicareCoverageSummaryWrapper(SSP_Benefits__c benefit, Boolean removeBenefit, Boolean displayEdit, String memberName, String medicareType, String editButtonAltText, String removeButtonAltText, String formattedBeginDate,String viewButtonAltText){
            this.benefit = benefit;
            this.removeBenefit = removeBenefit;
            this.displayEdit = displayEdit;
            this.memberName = memberName;
            this.medicareType = medicareType;
            this.editButtonAltText = editButtonAltText;
            this.removeButtonAltText = removeButtonAltText;
            this.formattedBeginDate = formattedBeginDate;
            this.viewButtonAltText=viewButtonAltText;
        }
    }
}