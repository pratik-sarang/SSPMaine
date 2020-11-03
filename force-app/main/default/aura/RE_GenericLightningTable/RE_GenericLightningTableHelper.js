({
	sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.myData");
        var key = function(aVar2) { return aVar2[fieldName]; }
        var reverse = sortDirection === 'asc' ? 1: -1;
      
            data.sort(function(aVar2,bVar2){ 
                var aVar = aVar2;
                var bVar = bVar2;
                 aVar = key(aVar) ? key(aVar).toLowerCase() : '';
                 bVar = key(bVar) ? key(bVar).toLowerCase() : '';
                return reverse * ((aVar>bVar) - (bVar>aVar));
            });    
        
        component.set("v.myData",data);
    },
    showNotesView: function(cmp,event){
        var row = event.getParam('row');
            $A.createComponent(
                "c:RE_NotesView",{ "noteDetails" : row},
                function(newcomponent){
                    if (cmp.isValid()) {
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);             
                    }
                }            
            );
    }
})