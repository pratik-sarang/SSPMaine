({
    doInit : function(component) {   
        var categoryArr = [];
        var options = component.get("v.categoryOptions");
        for(var key in options){
            if(key!==null && key!==undefined){
            	categoryArr.push({value:options[key], key:key});
            }
        }
        component.set("v.categoryMap", categoryArr);        
    },    
    goToSearchPage: function(component, event) {
        var domain = event.target.getAttribute("data-domain");
        var categorySelected = event.target.getAttribute("data-category");
        var subcategorySelected = event.target.getAttribute("data-subcategory");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/search-results?domain="+domain+"&category="+encodeURIComponent(categorySelected)+"&subcategory="+encodeURIComponent(subcategorySelected)
        });
        urlEvent.fire();
    }
})