({
	//Venkat: 03/04/2020: Spanish Translation
    getColumnsData:function(component){
        var myColumnData=[];
        var agencyColumnData=[]; //RE_Release 1.1 - Agency User Capture - Siri
        myColumnData.push({ label: $A.get("$Label.c.RE_FirstName"), fieldName: 'FirstName', type: 'text',sortable : true},
            { label: $A.get("$Label.c.RE_LastName"), fieldName: 'LastName', type: 'text',sortable : true},
            { label: $A.get("$Label.c.primarylocation"), fieldName: 'PrimaryLocation', type: 'text',sortable:'true'},
            { label: $A.get("$Label.c.RE_ArchRole"), fieldName: 'PermissionsLevel', type: 'text',sortable:'true'},
            { label: $A.get("$Label.c.trainingcomplete"), fieldName: 'TrainingLevel', type: 'text',sortable:'true'},
			{ label: $A.get("$Label.c.RE_PhoneNo"), fieldName: 'Phone', type: 'Phone',sortable:'true'},
            { label: $A.get("$Label.c.RE_Status"), fieldName: 'Status', type: 'text',sortable:'true'},
            { label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_EditLabel"), name:'edit'}]}});
            component.set("v.mycolumns",myColumnData);
        
        agencyColumnData.push({ label: $A.get("$Label.c.RE_FirstName"), fieldName: 'FirstName', type: 'text',sortable : true},
            { label: $A.get("$Label.c.RE_LastName"), fieldName: 'LastName', type: 'text',sortable : true},
            { label: $A.get("$Label.c.primarylocation"), fieldName: 'PrimaryLocation', type: 'text',sortable:'true'},
            { label: $A.get("$Label.c.RE_ArchRole"), fieldName: 'PermissionsLevel', type: 'text',sortable:'true'},
            { label: $A.get("$Label.c.trainingcomplete"), fieldName: 'TrainingLevel', type: 'text',sortable:'true'},
			{ label: $A.get("$Label.c.RE_PhoneNo"), fieldName: 'Phone', type: 'Phone',sortable:'true'},
            { label: $A.get("$Label.c.RE_Status"), fieldName: 'Status', type: 'text',sortable:'true'});
            component.set("v.agencyColumns",agencyColumnData);
    },
    doInitHandler:function(component) {

        try{ 
             //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('Label.c.component_failure');
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getLoggedInUserRole', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);

                if(response.isSuccessful){
                  component.set("v.isAdmin", response.objectData.bIsAdminUser);
                  component.set("v.isAgencyAdmin", response.objectData.bIsAgencyAdminUser);  
                }else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), component_failure);
                }
                
            },null,false);
        }catch (e) {
        }        
    } //END
})