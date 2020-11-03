({

    doInit : function(component, event, helper) {
		helper.getFavResources(component,helper);
    },
    
    handleAccordionClick : function(component, event) {
        if(event.keyCode === 13 || !event.keyCode){
            var generalId=event.target.id.split('-')[1];
            var cardArray=document.getElementsByClassName('my-plan-card');
            var toggleArray=document.getElementsByClassName('card-toggle-section');
            var collapsedArray=document.getElementsByClassName('collapsed-section');
            window.setTimeout(
                $A.getCallback(function() {
                    if(document.getElementById('desc-'+generalId)){
                        document.getElementById('desc-'+generalId).focus(); 
                    }
                }), 0
            );
            for(var i=0;i<toggleArray.length;i += 1){
                if(toggleArray[i].id.split('-')[1] !== generalId){
                    cardArray[i].classList.remove('card-opened');
                    toggleArray[i].classList.add('slds-hide');
                    collapsedArray[i].classList.add('myPlanCard-hover');
                }
            }
            document.getElementById('card-'+generalId).classList.toggle('card-opened');
            document.getElementById("toggle-" + generalId).classList.toggle('slds-hide');
            document.getElementById('collapsed-'+generalId).classList.toggle('myPlanCard-hover'); 
        }
    },
    removeFavorites : function(component, event,helper){
      //  var favorites = component.get("v.favorites");
        // var card= event.currentTarget.getElementsByTagName("img")[0].title;
        //var card = event.currentTarget().dataset
        if(event.keyCode === 13 || event.type === "click"){
            component.set("v.LocResourceId",event.currentTarget.dataset.locresid);
            component.set("v.sResourceName",event.currentTarget.dataset.resname);
            component.set("v.sOrganisationName",event.currentTarget.dataset.orgname);
        
            helper.deleteFavoritesHelper(component);
            helper.getFavResources(component,helper);
        }

    },
    
    navigateToUrl : function(component, event, helper){
        helper.navigateToResourceDetail(component, event);
    },
    
    createReferral:function(component,event){
        //Open create referral page 
        var eventValue = event.getSource().get("v.value");
       
      
        component.set("v.selectedResourceId", eventValue.sResourceId);
        component.set("v.selectedResourceAccountId",eventValue.sOrgId);
        component.set("v.selectedLocation", eventValue.sLocationId);
       
        component.set('v.myfavorites',false);
        
    },
    createReferrals: function(component) {
        
        
        var checkboxes = component.find("checkBox1");
        var checkboxesChecked = [];
        if(!$A.util.isUndefinedOrNull(checkboxes) && !Array.isArray(checkboxes)){
            if(checkboxes.get("v.value").bisSelected){
                checkboxesChecked.push(checkboxes.get("v.value"));
            }
        }
        
        for (var i=0; i<checkboxes.length; i+= 1) {
            var bCheck = checkboxes[i].get("v.value").bisSelected;
           
            // And stick the checked ones onto an array...
            if (bCheck) {
                checkboxesChecked.push(checkboxes[i].get("v.value"));
              
                
            }
        }
        
        
        component.set('v.bulfReferralTableData',checkboxesChecked);
        component.set('v.myfavorites',false);
    },
    
    onCheck: function(component, event,helper) {
        
         var val = event.getSource().get("v.value"); 
         if (event.getSource().get("v.checked")) {
           val.bisSelected = true;
         }
         else{
           val.bisSelected = false;
        }	
        
		helper.disableCreateButton(component,event);        

        
    },
    
    handleComponentEvent : function(component,event,helper){
        
        helper.getFavResources(component,helper);
        var bShowFavorites = event.getParam("bBacktoBulkReferral");
        component.set("v.myfavorites",bShowFavorites);
       
        var checkboxes = component.find("checkBox1");
        //var checkboxesChecked = [];
        for (var i=0; i<checkboxes.length; i+=1) {
            checkboxes[i].get("v.value").bisSelected = false;
        }
        component.set("v.bCreateRefrral",true);
       
    },
    openWebsite: function(component, event){
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank");
    },
    openDrivingDirectionMap:function(component,event){
        var resourceClickedIndex=event.target.getAttribute("data-attriVal");
        var wrapperData=component.get("v.favorites")[resourceClickedIndex];
        var latLong=wrapperData.sGeoLocation;
        var latLongReplaced=latLong.replace("##",",");
        var redirectUrl=$A.get("$Label.c.googlemapurl")+latLongReplaced;
        window.open(redirectUrl, "_blank");
    }
})