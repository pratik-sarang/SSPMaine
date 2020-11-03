({
	createNotes : function(component) {
        var title= component.find("title").get("v.value");
        var decription =component.find("desc").get("v.value"); 
        var recid=component.get("v.recid");
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.createNote', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var successMsg = $A.get("$Label.c.notessuccessmessage");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                }else{
                    var errMsg = $A.get("$Label.c.noteserrormessage") ;
                    bSuper.showToast('Error', 'Error', errMsg);
                }                                
            },{
				"title" : title,
            	"description" : decription,
            	"recid" : recid,
              "isPublic" : false                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }        
    },
    showToast : function(component, event, helper, variant, msg){
        if(variant === 'Success'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.successstatus"),
                "message": msg,
                "variant": "success"
            });
        }else if(variant === 'Error'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },
    getNotes : function(component,helper) {
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString(); 
        var recid = component.get("v.recid");
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getNotes', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    //var responsedata = response.getReturnValue();
                	var objectData = response.objectData.records;
                    var lstrecords=JSON.parse(objectData); 
                    if(lstrecords.length < component.get("v.pageSize")){
                        component.set("v.isLastPage", true);
                    } else{
                        component.set("v.isLastPage", false);
                    }
                    component.set("v.dataSize", lstrecords.length);
                    var currentData = component.get('v.mydatanotes');
                    if($A.util.isUndefinedOrNull(currentData)){
                        component.set('v.mydatanotes',lstrecords);
                    }else{
                        component.set('v.mydatanotes',currentData.concat(lstrecords));
                    }
                    helper.sortData(component,component.get("v.sortBy"),component.get("v.sortDirection"));
                    component.set('v.allDatanotes',lstrecords);
                    
                }else{
                    var errMsg = $A.get("$Label.c.noteserrormessage") ;
                    bSuper.showToast('Error', 'Error',errMsg);
                }                                
            },{
				"recid": recid,
            	"pageSize" : pageSize,
            	"pageNumber" : pageNumber               
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }        
    },
    createColumnData:function(component){
        var myColumnData=[];
        myColumnData.push({ label: $A.get("$Label.c.Subject"), fieldName: 'Title', type: 'text',sortable : true},
                          { label: $A.get("$Label.c.description"), fieldName: 'Description', type: 'text',sortable : true},
                          { label: $A.get("$Label.c.Created_By"), fieldName: 'CreatedBy', type: 'text',sortable : true}, 
                          { label: $A.get("$Label.c.Created_Date"), fieldName: 'CreatedDate', type: 'date',sortable : true,typeAttributes: {day: 'numeric', month: 'numeric',year: 'numeric'}},
                          { label: $A.get("$Label.c.RE_ModifiedDate"), fieldName: 'ModifiedDate', type: 'date',sortable : true,typeAttributes: {day: 'numeric', month: 'numeric',year: 'numeric'}},
                          { label: '', type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View"), name:'edit'}]}})
        component.set("v.mycolumns",myColumnData);
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.mydatanotes");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection === 'asc' ? 1: -1;
      
            data.sort(function(a,b){ 
                var a1 = key(a) ? key(a).toLowerCase() : '';
                var b1 = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a1>b1) - (b1>a1));
            });    
        
        component.set("v.mydatanotes",data);
    }        
})