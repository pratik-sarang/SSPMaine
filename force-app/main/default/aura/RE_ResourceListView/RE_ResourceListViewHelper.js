({
	doInitHandler : function(component) {
		try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
                
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getCheckToDisableButton', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){ 
                    component.set("v.enableAddResource", response.objectData.checkToDisable);
                }else{
                    var errMsg = '';
                    errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }                                
            }, null,false);
        }catch (e) {
        }	
	},
    createColumnData:function(component){
        var myColumnData=[];
        var myColumnData1=[];
        myColumnData.push({label: $A.get("$Label.c.name"), fieldName: 'Name', type: 'text',sortable : true},
            			  {label: $A.get("$Label.c.Domain"), fieldName: 'SdohDomain__c', type: 'text',sortable: true},
                          {label: $A.get("$Label.c.RE_EditLabel"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_EditLabel") , name:'edit'}]}} 
                          )
        component.set("v.mycolumns",myColumnData);
        myColumnData1.push({label: $A.get("$Label.c.name"), fieldName: 'Name', type: 'text',sortable : true},
        				   { label: $A.get("$Label.c.Domain"), fieldName: 'SdohDomain__c', type: 'text',sortable: true},
        				   { label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'edit'}]}}
                          )
        component.set("v.mycolumns1",myColumnData1);
    }
})