({
    /* get client from URL if present else load OurClient Table */
    doinIt : function(component, event, helper) {
        helper.optedOut(component);
        var retUrl = sessionStorage.getItem("retUrl");
        if(retUrl){
            window.location = retUrl;
            sessionStorage.removeItem("retUrl");
            return false;
        }
        if($A.get("$Browser.formFactor") === 'PHONE'){
            component.set('v.isInitialLoad',true);  
        }
        helper.getParamValue(component, event, helper); 
        if($A.get("$Browser.formFactor") !== 'PHONE'){
            component.set('v.isInitialLoad',true);  
        }
        var selectedItem=component.get("v.selectedItem");
        if(selectedItem !== 'Privacysettings'){
            helper.doinItHandler(component, event, helper);             
        }        
        else {
            component.set("v.displayLoader", false);                    
        }
        helper.doinItCountHandler(component); 
        setTimeout(function(){
                document.getElementById("testscreen").focus();
        },5000);
        return true;
    },
    /*Tab swithching andler */
    handleBeforeSelect: function(component, event, helper) {
        /* Mobile Desing */
        if($A.get("$Browser.formFactor") === 'PHONE'){
            component.set('v.selectedItem', event.getSource().get("v.name"));
            component.set('v.activeItem', event.getSource().get("v.name"));
        } else {
            /* Desktop, Tablet*/
            component.set('v.selectedItem', event.getParam('name'));
            component.set('v.activeItem', event.getParam('name'));
        }
        if(component.get('v.selectedItem')==='Privacysettings'){
            helper.handleBeforeSelectHelper(component, event, helper);
        }
        else if(component.get('v.selectedItem')==='Surveys'){
            helper.handleBeforeSelectHelper(component, event, helper);
        }
        else{      
            var selectedvalue = component.get('v.selectedItem');
            if((selectedvalue==='MyResources') && (component.get('v.initialLoadInProgress')===true)){
                if(component.get("v.disableScrollList").indexOf(selectedvalue)!==-1){
                    component.set("v.disableScroll",false);
                }
                else{
                    component.set("v.disableScroll",true);
                }
                helper.handleBeforeSelectHelper(component, event, helper);
            }      
            else if((selectedvalue==='Completed') && (component.get('v.initialLoadCompleted')===true)){
                if(component.get("v.disableScrollList").indexOf(selectedvalue)!==-1){
                    component.set("v.disableScroll",false);
                }
                else{
                    component.set("v.disableScroll",true);
                }
                helper.handleBeforeSelectHelper(component, event, helper);
            }
            else if((selectedvalue==='Suggested') && (component.get('v.initialLoadSuggestedForMe')===true)){
                if(component.get("v.disableScrollList").indexOf(selectedvalue)!==-1){
                    component.set("v.disableScroll",false);
                }
                else{
                    component.set("v.disableScroll",true);
                }
                helper.handleBeforeSelectHelper(component, event, helper);
            }
            else{
                component.set("v.displayLoader", true);
                helper.doinItHandler(component, event, helper);            
            }
            
        }
    },
    /* send myplan email */
    onSend : function(component, event, helper) {
        helper.processResourceDetails(component, event, helper);   
    },
    /* map display */
    handleApplicationEvent:function(component,event,helper){
        component.set("v.showSingleMarkerForCompleted",false);
        component.set('v.mapData',[]);
        var cardOpenCloseIndex=event.getParam("index");
        var clickedIndex=event.getParam("resourceClickedIndex");
        helper.showAllLoactionsMarker(component,event,clickedIndex,cardOpenCloseIndex);
    },
    /* navigation to oneview from Myplan*/
    backToOneView :function(component,event,helper){
        helper.backToOneView(component);
    },
    loadMore : function(component,event, helper){
        component.set("v.displayLoader", true);
        component.set("v.isLoadMore",true);
        helper.doinItHandler(component, event, helper);
    },
    
    onPrint : function(component,event){
        var decodedUrlParam = component.get("v.sContactId") ? atob(component.get("v.sContactId")) : "";
        var baseUrl= decodeURIComponent(window.location.href);
        var optionSelected=baseUrl.split('/s/')[0];
        var url = decodedUrlParam ? optionSelected+'/apex/PrintPlan?clientId='+decodedUrlParam : optionSelected+'/apex/PrintPlan';
        window.open(url);
    },
    ShowMeMore : function(component,event, helper){
        //helper.ShowMeMore(component, event, helper);
    }
    
})