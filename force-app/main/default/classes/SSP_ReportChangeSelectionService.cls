public class SSP_ReportChangeSelectionService implements Queueable, Database.AllowsCallouts{
    private String applicationId;
    private String selectedScreens; 
    private String individualId ; 
    private Map<String, String> mapCaseVsIndividualId;
    
    public SSP_ReportChangeSelectionService(String applicationId, String selectedScreens, String individualId, Map<String,String> caseIndividualIdMap) {
        this.applicationId = applicationId;
        this.selectedScreens = selectedScreens;
        this.individualId = individualId;
        this.mapCaseVsIndividualId = caseIndividualIdMap;
    }
    
    public void execute (QueueableContext context ){
        SSP_ReportChangeSelectionCtrl.invokeReverseSSPService(applicationId,selectedScreens,individualId,mapCaseVsIndividualId);
    }
}