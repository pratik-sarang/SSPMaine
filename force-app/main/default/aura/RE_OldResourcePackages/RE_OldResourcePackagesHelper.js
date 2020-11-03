({
    fireCarouselEvent : function(component, event, showCarousel) {
        var carouselEvent = $A.get("e.c:RE_ShowHideCarousel");
        carouselEvent.setParams({ "showCarousel" : showCarousel });
        carouselEvent.fire();
    }
})