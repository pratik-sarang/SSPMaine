({
	onChange : function(component) {
		var selected=component.get("v.archetypeSelected");
		component.set("v.archetypeSelected",selected===true?false:true);
	}
})