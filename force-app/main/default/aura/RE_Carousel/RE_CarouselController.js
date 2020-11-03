({
    doInit: function(component, event, helper){
        helper.getArchetypeDetails(component);
    },
    
     goToLink : function(component, event, helper){
         var link = event.getSource().get("v.name");
         helper.navigateToUrl(component, event, link);         
    },
    
    changeParams : function(component, event, helper){
        helper.changeLinkAndText(component, event);
    },
    
    changeImage : function(component, event, helper){
        helper.changeImageOnClick(component, event);
    },
    
    showHideCarousel: function(component, event, helper){
        helper.showCarouselOnView(component, event);
    }
})