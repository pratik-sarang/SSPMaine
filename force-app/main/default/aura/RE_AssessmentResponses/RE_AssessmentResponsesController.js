({
    backResults : function(component) {
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
    },
    backToOneView: function(component,event,helper){
        helper.backToOneView(component);
    }
})