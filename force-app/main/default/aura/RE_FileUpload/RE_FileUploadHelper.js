({
    getDocTypesOptions: function(component) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper");
                
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getDocTypesValues', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var picklistValues = response.objectData.lstDocumentType;
                    var options = [];
                    for(var i in picklistValues){
                    // options.push(picklistValues[i].label); commented by Ram
                       options.push(picklistValues[i]);
                    }
                    //component.set("v.lstDoctypes",response.objectData.lstDocumentType);
                    component.set("v.lstDoctypes",options);
                }
                else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"),$A.get("$Label.c.errorstatus"), component_failure);
                }
            },null,false);
        }
        catch(e){
            }
    },

    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,//750000, 

    uploadHelper: function(component) {
        this.showSpinner(component);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fuploader").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > $A.get("$Label.c.Max_FileSize")) {
            
              var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": $A.get("$Label.c.RE_Fileuploadsize") + file.size/(1024*1024) + " MB",
                "type"   : "error" 
            });
                    
            toastEvent.fire();
            
            component.set("v.fileName","");
    		component.find('fuploader').set('v.files', null);
    		component.set("v.bShowFileUpload",true);
    		component.set("v.isOpen", false);
                
           // component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            $A.get('e.force:refreshView').fire();
            return;
        }

        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        var self = this;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + self.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        self.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    uploadInChunk: function(component, file, fileContents, startPositionP, endPositionP, attachIdP) {
        var startPosition =startPositionP;
        var endPosition = endPositionP;
        var attachId =attachIdP
        var component_failure = $A.get('$Label.c.component_failure');
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');

            //reference to inherited super component
            var bSuper = component.find("bSuper");
        // call the apex method 'SaveFile'
        var self = this;
        var getchunk = fileContents.substring(startPosition, endPosition);
            
            //var action = component.get("c.saveChunk");
        var fileExtention;
        if(component.get("v.fileNameModified").indexOf('.')> -1){
        	 fileExtention = component.get("v.fileNameModified").split('.')[1];
           // component.set("v.fileName", component.get("v.fileNameModified").split('.')[0]);
            //(fileExtention);
        }
        var validExt= component.get("v.allowedExtensions");
        if(!validExt.includes(fileExtention)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            "title": $A.get("$Label.c.errorstatus"),
            "message": $A.get("$Label.c.RE_FileExtentionError"),
            "type"   : "error" 
        }); 
        toastEvent.fire();
                  
        component.set("v.fileName","");
        component.find('fuploader').set('v.files', null);
        component.set("v.bShowFileUpload",true);
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        return;

        }
        
        if(component.get("v.fileName").indexOf('.')> -1){
           component.set("v.fileName", component.get("v.fileName").split('.')[0]); 
        }
        var newfilename = component.get("v.fileName") + '.' +fileExtention;
        
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.saveChunk', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
            // store the response / Attachment Id   
                    attachId = response.objectData.fileId;
                // update the start position with end postion
                startPosition = endPosition;
                    endPosition = Math.min(fileContents.length, startPosition + self.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                        self.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    component.find('fuploader').set('v.files', []);
                    component.set("v.bShowFileUpload", true);
                    component.set("v.isOpen", false);
                        self.hideSpinner(component);
                        self.fireComponentEvent(component);
                    component.set("v.fileName","");
    			    component.find('fuploader').set('v.files', null);
                }
                    }
                else{
                    bSuper.showToast('Error', 'Error', component_failure);
                }
            },
            {
            	'parentId': component.get("v.parentId"),
                'strFileName': newfilename,
                'strBase64Data': encodeURIComponent(getchunk),
                'strContentType': file.type,
                'strFileId': attachId,
                'strDocType': component.find("fltype").get("v.value")
            },false);
                }
        catch(e){
            }
    },
    fireComponentEvent: function(component) {

        var cmpEvent = component.getEvent("FileUploadSuccess");
        cmpEvent.setParams({
            "isSuccess": "true"
        });
        cmpEvent.fire();

    },
    
    showSpinner : function(component){
        component.set("v.Spinner",true);
        
    },
    hideSpinner : function(component){
        component.set("v.Spinner",false);
        
    },
    getValidExtension: function(component){
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var component_failure = $A.get('$Label.c.component_failure');
                
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getValidExtensions', function(response){
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var picklistValues = response.objectData.lstValidExt;
                    component.set("v.allowedExtensions",picklistValues);
                }
                else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"),$A.get("$Label.c.errorstatus"), component_failure);
                }
            },null,false);
        }
        catch(e){
            }

    }
})