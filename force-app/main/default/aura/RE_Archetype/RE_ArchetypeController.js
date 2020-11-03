({
	doinIt : function(component,event,helper){
        helper.doInitHandler(component, event, helper);   
        setTimeout(function(){//JAWS Fix
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },1000);  
    },
    navigateToLandingPage : function(component, event, helper){
        helper.navigateToUrl(component, event);
    },    
    handleZipCode : function(component){         
        var zipCode = component.get("v.zipCode");        
        //if(zipCode.length === 5){
        if(zipCode.length > 0){
        	var filterCmp = component.find('cmpFilter');
        	filterCmp.set('v.onFilterLoad',true);
            component.set("v.isDisabled",false);  
        }else{
            component.set("v.isDisabled",true);  
        }
    },
    validateZipCode : function(component, event, helper){
        component.set("v.isDisabled",true);
        var result = helper.validateZipCode(); 
        if(!result){
            component.set("v.isDisabled",false);
        }else{
            helper.showToast(component, event, $A.get("$Label.c.RE_ZipCode_Error"));
        }
    },
    submitZipCode : function(component, event, helper){ 
        helper.submitZipCode(component, event);
    },
    submit:function(component, event, helper){
        helper.submitHandler(component, event, helper);
    },
    updateResources : function(component,event,helper){        
        if((!component.get("v.onLoad")) || component.get("v.updateResources")){                       
        	helper.getResourceData(component);                        
        }        
    },
    handleApplicationEvent:function(component,event,helper){
        component.set("v.showSingleMarkerForCompleted",false);
        var cardOpenCloseIndex=event.getParam("index");
        var clickedIndex=event.getParam("resourceClickedIndex");
        var clickedData = event.getParam("mapMarkerSingleData");
        helper.mapDataHelper(component,clickedData, clickedIndex,cardOpenCloseIndex);
     },
	handleVeiwMapData :function(component,event){
        var mapOptions = event.getParam("mapOptions");
        var mapOptionsCenter = event.getParam("mapOptionsCenter");
        var mapData = event.getParam("mapData");
        var showmore = event.getParam("showmore");
        if(Array.isArray(mapData) && mapData.length===0){
             component.set("v.showMultiPleMarker",false);
           component.set("v.showMultiPleMarkerForCompleted", false);
           component.set("v.showSingleMarkerForCompleted",false);
        }else{
        /* store for all location button click*/
        component.set("v.onloadmapdata",mapData);
        component.set("v.onloadmapoption",mapOptions);
        component.set("v.onloadmapcenter",mapOptionsCenter);
        
        component.set("v.mapOptionsCenter",mapOptionsCenter);
        component.set('v.mapData', mapData);
        if(showmore === true && mapData.length === 1){
            component.set("v.showMultiPleMarker", false);
            component.set("v.showMultiPleMarkerForCompleted", false);
            component.set("v.showSingleMarkerForCompleted", true);
        }else if(showmore === true && mapData.length > 1){
            component.set("v.showMultiPleMarker", false);
            component.set("v.showMultiPleMarkerForCompleted", true);
            component.set("v.showSingleMarkerForCompleted", false);
        }
        if(component.set("v.showMultiPleMarker") === true){
            component.set("v.showMultiPleMarker", false);
            component.set("v.showMultiPleMarkerForCompleted", true);
        }else{
        	component.set("v.showMultiPleMarker", true);
            component.set("v.showMultiPleMarkerForCompleted", false);
        }
        component.set("v.showSingleMarkerForCompleted", false);
        }
    },
    actionfromResourceCards: function(component){
        component.set("v.isCreateRefferel",!component.get("v.isCreateRefferel")); 
    },
    handleMapClick : function(){
        if(document.getElementsByClassName('archetype-cards')[0]){
           document.getElementsByClassName('archetype-cards')[0].classList.add('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
           document.getElementsByClassName('archtype-map-section')[0].classList.remove('slds-hide');
        }
        if(document.getElementsByClassName('archetypeBanner')[0]){
            document.getElementsByClassName('archetypeBanner')[0].classList.add('slds-hide'); 
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.add('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-content')[0]){
           document.getElementsByClassName('archtype-content')[0].classList.add('slds-p-around_none'); 
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
           document.getElementsByClassName('archtype-map-section')[0].classList.add('slds-p-vertical_none'); 
        }
    },
    handleFilterClick : function(){
        if(document.getElementsByClassName('archetype-cards')[0]){
            document.getElementsByClassName('archetype-cards')[0].classList.add('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-filter-section')[0]){
            document.getElementsByClassName('archtype-filter-section')[0].classList.remove('slds-hide');
        }
        if(document.getElementsByClassName('archetypeBanner')[0]){
            document.getElementsByClassName('archetypeBanner')[0].classList.add('slds-hide'); 
        }
        if(document.getElementsByClassName('empty-div')[0]){
           document.getElementsByClassName('empty-div')[0].classList.add('slds-hide'); 
        }
    },
    moveFocusToTop: function() {//JAWS Fix  
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },10);
    }
})