({
	getLoggedInUser : function(component) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            var defaultUrl; // 20Dec LV issue
            bSuper.callServer(component, 'c.fetchLoginInUser', function(response) {
                if(response.isSuccessful){
                    defaultUrl = "/";
                    if( response.objectData.isCpUser===true && response.objectData.isCPOnboardingTrainingDone===false){
                        defaultUrl='referral-inbox';
                    }else if(response.objectData.isUserFirstLogin===false){
                        var baseUrl= decodeURIComponent(window.location.href);
                        var optionSelected=baseUrl.split('/s/')[0];
                        defaultUrl=optionSelected;
                    }else if(response.objectData.isResidentUser===true){
                        defaultUrl='my-plan';
                    }else if( response.objectData.isCpUser===true || response.objectData.isAgencyUser===true){ // RE_Release 1.1 - Agency User Capture - Ram
                        defaultUrl='referral-inbox';
                    }else if(response.objectData.isAssisterUser===true){
                         defaultUrl='clients';
                    }
                    window.open(defaultUrl,'_top');
                }
                else{
                    defaultUrl = $A.get("$Label.c.RE_Community_Base_URL");
                    window.open(defaultUrl,'_top');
                }
            },{},false);
        }catch (e) {
        }
    }
})