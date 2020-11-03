({
    doinIt: function(component, event){
    	var notes = component.get("v.listNoteWrapper");
        if(notes.lstNotes){
            var lenNotes = notes.lstNotes.length;
            if(lenNotes>5) 
                component.set('v.showMore',lenNotes-1);
            var j=0;
            var myFirstFive=component.get("v.listNoteWrapper1"); 
            for(var i=lenNotes-1;i>=0;i=i-1){
                if(notes.lstNotes[i].Description.indexOf("\\&#39;") > -1){
                        notes.lstNotes[i].Description = notes.lstNotes[i].Description.split('\\&#39;').join("\'");
                }
                if(notes.lstNotes[i].Description.indexOf("\\") > -1){
                    notes.lstNotes[i].Description = notes.lstNotes[i].Description.split("\\").join("");
                }
                if(notes.lstNotes[i].Description.indexOf("\&quot;") > -1){
                    notes.lstNotes[i].Description = notes.lstNotes[i].Description.split("\&quot;").join("\"");
                }
                if(j<5){
                    myFirstFive.push(notes.lstNotes[i]);
                } 
                j++;
            }
            component.set("v.listNoteWrapper1",myFirstFive); 
            component.set("v.firstFivelst",myFirstFive);
        }
        
    },
    handleClick : function(component, event, helper) {
       helper.addNoteHandler(component, event, helper);
    },
    
    activateButton : function(component, event, helper){
        let inputText = component.find("notebody").get("v.value");
        if(inputText != null){
            component.set('v.bIsButtonClicked',false);
        }       
    },
    showMore : function(component, event, helper){
    component.set("v.showMore", false);
      component.set("v.showless", true);
    component.set("v.listNoteWrapper1",component.get("v.listNoteWrapper.lstNotes"));
    },
    showless : function(component, event, helper){
    component.set("v.showless", false);
    component.set("v.showMore", true);
    component.set("v.listNoteWrapper1",component.get("v.firstFivelst"));
    }
})