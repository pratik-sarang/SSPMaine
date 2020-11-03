({
    refsent : function(component,event,helper){
        var temp2 = component.get("v.graphData");
        helper.createLineGraph(component, temp2);
    },
    toggleExpanCollapse: function(component, event) {
        var id=event.currentTarget.id.split('_')[1];
        document.getElementById(id).classList.toggle("graph-expanded");
    }
})