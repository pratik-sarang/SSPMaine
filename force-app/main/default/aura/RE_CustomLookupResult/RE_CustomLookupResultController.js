({
   selectRecord : function(component,event){ 
       if(event.keyCode === 13 || !event.keyCode){
           // get the selected record from list  
           var getSelectRecord = component.get("v.oRecord");
           // call the event   
           var compEvent = component.getEvent("oSelectedRecordEvent");
           // set the Selected sObject Record to the event attribute.  
           compEvent.setParams({"recordByEvent" : getSelectRecord,
                                "lookupObjName": component.get("v.ObjName")
                               });  
           // fire the event  
           compEvent.fire();
       }
   }
})