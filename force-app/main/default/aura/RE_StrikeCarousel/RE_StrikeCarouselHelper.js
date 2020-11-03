({
    displayCards: function(component) {
        var body = component.get('v.body')[0];
        var pageCount;
        var cardCount = component.get('v.cards').length;
        var isPhone = $A.get("$Browser.isPhone");
        var phoneWidth = document.documentElement.clientWidth;
        var phoneHeight = document.documentElement.clientHeight;

        if(!$A.util.isEmpty(body)) {
            /* Conditional Check for Phone */
            if (isPhone && phoneWidth < phoneHeight){
                pageCount = Math.ceil(cardCount / 1);
            }else{
                pageCount = Math.ceil(cardCount / 3);
            }
            pageCount = Math.ceil(cardCount / 3);
            var spacerCount = pageCount % cardCount || 0;
            component.set('v.pages', new Array(pageCount));
            component.set('v.spacers', new Array(spacerCount));
        }
    }, 
    scrollToPage: function(component, event, helper, pageNumber) {
            var carouselBody = component.find('carousel-body').getElement();
            var carouselBodyWidth = carouselBody.getBoundingClientRect().width;
            var currentPage = component.get('v.currentPage');
            var increment = (carouselBodyWidth * (pageNumber - currentPage)) / 60;
            var speed = 250; // Milliseconds
            var frameCount = 0;
            
            var slideInterval = setInterval(function() {
                frameCount+=1;
                window.requestAnimationFrame(function() {
                    carouselBody.scrollLeft += increment;
                });
                
                if (frameCount === 60) {
                    clearInterval(slideInterval);
                    currentPage = pageNumber;
                    window.requestAnimationFrame(function() {
                        carouselBody.scrollLeft = carouselBodyWidth * currentPage;
                    });
                }
            }, speed * 0.01667);
            
            component.set('v.currentPage', pageNumber);
            helper.updateDots(component);
    },
    updateDots: function(component) {
        var dots = component.find('dot');
        var currentPage = component.get('v.currentPage');
        
        dots.forEach(function(self, index) {
            if (index === currentPage) {
                self.getElement().classList.add('sc-pagination__dot_selected');
            } else {
                self.getElement().classList.remove('sc-pagination__dot_selected');
            }
        });
    },
    setContainerWidth: function(component) {
        if (component.getElement() !== null) {
            var containerWidth = Math.ceil(component.getElement().getBoundingClientRect().width);
            component.set('v.containerWidth', containerWidth);
        }
    }
})