({   
     doInit : function(component,event, helper) {
    	component.set("v.bShowFileUpload",true);
       helper.getDocTypesOptions(component); 
        helper.getValidExtension(component);
    },
    
   moveFocusToTop: function(component, event, helper) {
       if(event.keyCode === 9) {
           setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
           },10)
       }
   },
   
    handleSave: function(component,event, helper) {
    	
    	var toastEvent = $A.get("e.force:showToast");
        if ( component.find("fuploader").get("v.files") !== null && component.find("fuploader").get("v.files").length > 0) {
            var filename = component.get("v.fileName");
            filename = filename.trim();
            if( filename !== null && filename !== undefined && filename!== '' ){
            	//helper.uploadHelper(component, event);
            	helper.uploadHelper(component,event);
                
            }
            else{
                //var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": $A.get("$Label.c.RE_Fileupload"),
                "type"   : "error"
            });
            toastEvent.fire();
                }
        } else {
            //var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
            "title": $A.get("$Label.c.errorstatus"),
        	"message": $A.get("$Label.c.RE_Fileuploadname"),
            "type"   : "error"
    	});
    	toastEvent.fire();
           
        }
    },
     
    handleFilesChange: function(component, event) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            //fileName = event.getSource().get("v.files")[0]['name'];
            fileName = event.getSource().get("v.files")[0].name;
        }
        component.set("v.fileName", fileName);
        component.set("v.fileNameModified", fileName);
    },
     
   
    HideMe : function(component){
        component.set("v.fileName","");
    	component.find('fuploader').set('v.files', null);
    	component.set("v.bShowFileUpload",true);
    	component.set("v.isOpen", false);

	},
	onFillingDocName : function(component) {
		var sDocName = component.find("fileName").get("v.value");
		if(sDocName !== undefined && sDocName !== ''){
			component.set("v.bShowFileUpload",false);
    	}
    	else{
    		component.set("v.bShowFileUpload",true);
    	}
    
    },
})