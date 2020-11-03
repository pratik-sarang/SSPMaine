({
    doInit : function(component, event, helper) {
        //To Load Spinner
        component.set("v.isLoading",true);
        var clientDetails = component.get("v.clientDetails");
        if(clientDetails && clientDetails.IEESId && clientDetails.IEESId !== null){
            component.set("v.isIEESClient", true);
            component.set("v.hasConsentToView",false);
            component.set("v.bOptOutComm",true);
            helper.getSDOHPicklistValues(component,helper);
            component.set("v.isLoading",false);
        }else{
            component.set("v.isIEESClient", false);  
        }
        if(clientDetails && clientDetails.BirthDate){
            //RE_Release 1.2 – Bug 365735- Payal Dubela– Commented as it changes bithdate in wrong format
            /*if(clientDetails.BirthDate.indexOf("-",1) === 2){
                clientDetails.BirthDate = clientDetails.BirthDate.split('-').reverse().join('-');
            }*/
            clientDetails.BirthDate= $A.localizationService.formatDate(clientDetails.BirthDate, "MM/dd/yyyy");
            if(helper.calculateAge(component,clientDetails.BirthDate)>=18){
              component.set("v.isAnAdult",true);
            }    
            component.set("v.clientDetails",clientDetails);
        }
        
            helper.getParam(component);
                helper.checkConsent(component,event,helper); 
        helper.doInitHandler(component,event,helper);

    },
    moveFocusToTop: function(component, event) {
        if(event.keyCode === 9) {
            setTimeout(function(){
                document.getElementsByClassName("modal-lg-heading")[0].focus(); 
                },100)
            }
    },
    backToDataTable: function(component) {
        location.hash = "";
        sessionStorage.setItem('isFromOneView', true);
        component.set('v.bShowClientTable',true);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/clients"
        });
        urlEvent.fire();
    },
    hideNote:function (component) {
        //On cancel on note
        component.set("v.showNotesModal",false);
        component.set("v.noteSubject",'');
        component.set("v.noteDescription",'');
    },
    addNote:function (component) {
        //Open add note popup
        component.set("v.showNotesModal",true);
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },500);
    },
    createReferral:function(component){
        //Open create referral page 
        component.set('v.showClientDetail',false);
        component.set('v.showreferral',true);
        $A.util.toggleClass(component.find('headingContainer'),'slds-hide');
        
    },
    onSave:function(component, event, helper){
        //On save of Note 
        if($A.util.isEmpty(component.get("v.noteSubject"))||
           $A.util.isEmpty(component.get("v.noteDescription"))){
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            var errMsg = $A.get("$Label.c.NotesRequiredField") ;
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
        }else{
            var noteButton=component.find('submitNote');
            noteButton.set("v.disabled",true);
            helper.saveNote(component,event,helper);
        }  
    },
    handleSort : function(component,event,helper){
        //Handle sort on datatable
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    },
    handleRowClick:function (cmp, event) {
        //view of single note
        var row = event.getParam('row');
        $A.createComponent(
            "c:RE_NotesView",{ "noteDetails" : row},
            function(newcomponent){
                if (cmp.isValid()) {
                    var body = cmp.get("v.body");
                    body.push(newcomponent);
                    cmp.set("v.body", body);             
                }
            }            
        );
    },
    handleViewAllHHComp :function (component) {
        //View All on Household composition
        component.set('v.sTableHeading',$A.get("$Label.c.Full_Household"));
        component.set('v.bShowHHCompo',true);
        component.set('v.showClientDetail',false);
        component.set('v.bShowEnrollProgs',false);
        component.set('v.bShowNotes',false);
        component.set('v.bShowRiskFactors',false);
    },
    
    handleViewAllEnrollPrograms :function (component) {
        //View All on EnrolledPrograms
        component.set('v.sTableHeading',$A.get("$Label.c.Enrolled_Programs"));
        component.set('v.bShowHHCompo',false);
        component.set('v.showClientDetail',false);
        component.set('v.bShowEnrollProgs',true);
        component.set('v.bShowNotes',false);
        component.set('v.bShowRiskFactors',false);
    },
    handleViewAllNotes :function (component) {
        //View All on Notes
        component.set('v.sTableHeading',$A.get("$Label.c.All_Notes"));
        component.set('v.bShowHHCompo',false);
        component.set('v.showClientDetail',false);
        component.set('v.bShowEnrollProgs',false);
        component.set('v.bShowNotes',true);
        component.set('v.bShowRiskFactors',false);
    },
    
    handleViewAllRiskFactors : function(component){
        //View all Risk Factors
        component.set('v.sTableHeading',$A.get("$Label.c.Needs"));
        component.set('v.bShowHHCompo',false);
        component.set('v.showClientDetail',false);
        component.set('v.bShowEnrollProgs',false);
        component.set('v.bShowNotes',false);
        component.set('v.bShowRiskFactors',true);
    },
    
    backToClientDetails : function (component) {	
        //Click of back to client from View all
        component.set('v.bShowHHCompo',false);
        component.set('v.showClientDetail',true);
        component.set('v.bShowEnrollProgs',false);
        component.set('v.bShowNotes',false);
        component.set('v.bShowAssesssmentResponse',false);        
    },
    handlerefresh:  function(component,event,helper){
        //On addition of new note refresh note table
        helper.refreshNotesList(component,event,helper);
    },
    navigateToMyPlan: function(component){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            // added by Pankaj for defect#1179
           "url": '/my-plan?sContactId='+btoa(component.get("v.clientId"))+'&client='+btoa(component.get("v.clientDetails.clientName"))
        });
        urlEvent.fire();
    },
    requestConsent: function(component){
        var clientDetails=component.get("v.clientDetails");
        component.set("v.clientWrapper",component.get("v.clientDetails"));
        if(clientDetails && clientDetails.BirthDate){
        var BirthDate=$A.localizationService.formatDate((clientDetails.BirthDate),"yyyy-MM-dd"); 
        component.set("v.clientWrapper.BirthDate",BirthDate);
        }
        component.set("v.showRequestConsent",true);
    },
    openSendEmailModal : function(component) {
        //opens modal for send email
        var clientDetails = component.get("v.clientDetails");
        if(component.get("v.isIEESClient")===true){
            component.set("v.sendEmailWrapper.clientEmail",clientDetails.Email);
        }else{
            component.set("v.sendEmailWrapper.clientEmail",clientDetails.clientEmail);
        }
        
        component.set("v.showEmailResidentModal",true);
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },500);
    },
    closeEmailResident : function(component) {
        //closes modal for send email
        component.set("v.sendEmailWrapper.message",'');  
        component.set("v.showEmailResidentModal",false);
    },
    onSend : function(component, event, helper){
        //validates email and message fields before sending email
        helper.validateInputs(component,event,helper);
    },
    openSelectAssesment: function(component,event,helper){
       // helper.getAssessmentRecords(component,event);
		helper.startAssessementHelper(component,event);
        //For sdoh list
        component.set('v.bShowRiskFactors', false);
        component.set("v.bisAssesmentOpen",true);
        component.set('v.showClientDetail',false);
        $A.util.toggleClass(component.find('headingContainer'),'slds-hide');
        
    },
    closeSelectAssesment: function(component){
        component.set("v.selectedRadioAssessmentObj",null);
        component.set("v.bisAssesmentOpen",false);
        
    },
    startAssessment:function(component,event,helper){
        helper.startAssessementHelper(component,event);
    },
    handleViewAssesssmentResponse :function (component) {
        //View All on EnrolledPrograms
        component.set('v.sTableHeading',$A.get("$Label.c.assessments"));
        component.set('v.bShowHHCompo',false);
        component.set('v.showClientDetail',false);
        component.set('v.bShowEnrollProgs',false);
        component.set('v.bShowNotes',false);
        component.set('v.bShowRiskFactors',false);
        component.set('v.bShowAssesssmentResponse',true);
    },
    selectAssessment:function(component,event){
        var selectedAssessmentIndex=event.getSource().get("v.value");
        component.set("v.selectedRadioAssessmentObj",component.get("v.lstAssessment")[selectedAssessmentIndex]);
    },
    handleModalclose:function(component,event){
        var CloseModal = event.getParam("closed");        
        if(CloseModal){
            component.set('v.showRequestConsent',false);
        }
        var Doinit = event.getParam("callDoInit");        
        var ClientId = event.getParam("ClientId");        
        if(Doinit){
            component.set("v.clientId",ClientId);
            component.set("v.clientDetails",null);
            var a = component.get('c.doInit');
            $A.enqueueAction(a);
            //this.doInit(component,event,helper);
        }
        
    },
    //Nandita: 03/26/2020: new function to add client to Favorite :357475
     addToMyClients: function(component,event,helper){
		helper.addToMyClientsHelper(component,event);
        
    },
    //Nandita: 03/26/2020: new function to remove client from Favorite :357475
    removeFromMyClients: function(component,event,helper){
		helper.removeFromMyClientsHelper(component,event);
	}
})