({
	doInit : function(component, event, helper) {
		helper.checkEditPermission(component);
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },500);
	},
    moveFocusToTop: function(event) {
        if(event.keyCode === 9) {
            setTimeout(function(){
                document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },100)
        }
    },
	hideNote: function(component) {
		component.set("v.showEditModal",false);
	},
	saveNote: function(component, event, helper) {
		if($A.util.isEmpty(component.get("v.noteDetails.Title"))||
		$A.util.isEmpty(component.get("v.noteDetails.Description"))){
		  var errMsg = $A.get("$Label.c.RequiredField") ;
		 helper.showToast(component, event, helper, 'Error', errMsg);
	 }else{
		 component.set("v.isEditable",false);
		 helper.saveNote(component,event,helper);
	 }  
	}
})