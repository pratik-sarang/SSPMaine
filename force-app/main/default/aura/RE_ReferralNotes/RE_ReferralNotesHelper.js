({
	//Venkat: 03/04/2020: Spanish Translation
    getNoteColumns:function(component){
        var noteColumnData=[];
        noteColumnData.push({ label: $A.get("$Label.c.Subject"), fieldName: 'Name', type: 'text'},
        					{ label: $A.get("$Label.c.description"), fieldName: 'Industry', type: 'text'},
        					{ label: $A.get("$Label.c.RE_EditLabel"), type: 'button', typeAttributes: {label: $A.get("$Label.c.RE_EditLabel")}})
        component.set("v.notecolumns",noteColumnData);
    }
})