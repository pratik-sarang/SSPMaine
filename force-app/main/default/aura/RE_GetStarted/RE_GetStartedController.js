({
    handleClick : function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/searchorganization"
        });
        urlEvent.fire();
    },
    openPopup:function(component){
        document.getElementById("iframe-container").classList.add("video-expanded");
        document.getElementById("iframe-container").classList.add("slds-backdrop");
        document.getElementById("iframe-container").classList.add("slds-backdrop_open");
        $A.util.removeClass(component.find("modal-close"),"slds-hide");
    },
    hidePopup:function(component){
        document.getElementById("iframe-container").classList.remove("video-expanded");
        document.getElementById("iframe-container").classList.remove("slds-backdrop");
        document.getElementById("iframe-container").classList.remove("slds-backdrop_open"); 
        $A.util.addClass(component.find("modal-close"),"slds-hide");
    },
})