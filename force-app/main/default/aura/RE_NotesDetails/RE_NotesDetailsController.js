({
    doInit : function(component, event, helper) {
		helper.checkEditPermission(component);
		setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },1000);
	},
    hideEditModal:function (cmp) {
        cmp.set("v.showEditModal",false);
    },
	saveNote: function(component, event, helper) {
		if($A.util.isEmpty(component.get("v.recId.Title"))||
		$A.util.isEmpty(component.get("v.recId.Description"))){
		  var errMsg = $A.get("$Label.c.RequiredField") ;
		  helper.showToast(component, event, helper, 'Error', errMsg);
	 }else{
		 component.set("v.isEditable",false);
		 helper.saveNote(component,event,helper);
	 }  
	},
    hideViewModal:function(component){
        component.set("v.showViewModal",false)
	},
	moveFocusToTop: function(component, event) {//JAWS FIXES
        if(event.keyCode === 9) {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10)
        }
    },
   
})