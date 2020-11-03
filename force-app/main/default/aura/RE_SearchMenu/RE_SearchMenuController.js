({
    init : function(component) {
        
       /* var categories = Object.keys(component.get("v.categories")[0]);
        component.set("v.categoriesList", categories);*/
        var categoryList = [];
        for(var i in component.get("v.categories")[0]){
            if(component.get("v.categories")[0][i] !== undefined && component.get("v.categories")[0][i] !== null && component.get("v.categories")[0][i] !== '')
            {
                var categorybyLabel=component.get("v.categoriesByLabel");           
                var subcat = {"label" : i , "value" : categorybyLabel[i]};
                categoryList.push(subcat);            
                
            }
        }
        component.set("v.categoriesList",categoryList);
    },
    handleNext: function(component, event) {
        if(event.keyCode === 13 || !event.keyCode){
            event.stopPropagation();
            event.preventDefault();        
            var data = component.get("v.categories")[0];
            var selectedCategory = event.currentTarget.getAttribute("data-value");
            var categorybyLabel=component.get("v.categoriesByLabel");
            component.set("v.selectedCategory",selectedCategory);
            var count = Number(event.currentTarget.getAttribute("data-level"))+1;
            var subCatSectionHeight=count*41+20;
            if(event.currentTarget.children[1].classList.contains('search-menu-ul-level-two')){
                event.currentTarget.children[1].style.minHeight=subCatSectionHeight.toString()+'px'; 
            }
            var subCategories = data[selectedCategory];
            var subCategoryItems = [];
            for(var i in subCategories){
                if(subCategories[i].picklistLabel!==undefined){
                    subCategoryItems.push({'name':subCategories[i].picklistLabel,'value':subCategories[i].picklistValue, 'parent':categorybyLabel[selectedCategory]});
                }    
            }
            component.set("v.subcategoryList", subCategoryItems);
            if($A.get("$Browser.isPhone")){
                if(document.getElementById('sidenav-level_2')){
                    document.getElementById('sidenav-level_2').classList.remove('slds-hide');
                }
                if(document.getElementById('sidenav-level_1')){
                    document.getElementById('sidenav-level_1').classList.add('slds-hide');
                } 
            }
        }
    },
    handleSubNext :function(component, event) {
        if(event.keyCode === 13 || !event.keyCode){
            var domain = component.get("v.category");
            var categorySelected = event.target.getAttribute("data-parent");
            var subcategorySelected = event.target.getAttribute("data-value");
            event.stopPropagation();
            var categoryArray=document.getElementsByClassName('category');
            for(var i=0;i<categoryArray.length;i+=1){
                if(categoryArray[i].classList.contains('category-active')){
                    categoryArray[i].classList.remove('category-active'); 
                }
            }
            if(document.getElementsByClassName('menu-container')[0]){
                document.getElementsByClassName('menu-container')[0].classList.add('slds-hide');
            }
            if($A.get("$Browser.isPhone")){
                if(document.getElementById("mobileSidenav")){
                    document.getElementById("mobileSidenav").style.width = "0";
                }
            }
            else{
                document.getElementById('category-search-container').classList.remove('dropdown-open');
                document.getElementsByClassName('search-overlay')[0].classList.remove('slds-backdrop');
                document.getElementsByClassName('search-overlay')[0].classList.remove('slds-backdrop_open');  
            }
            //Payal :Bug 396635 - Url Changes
            var baseUrl= decodeURIComponent(window.location.href);
            var optionSelected=baseUrl.split('/s/')[0];
            //var urlEvent = $A.get("e.force:navigateToURL");
            //urlEvent.setParams({
            // "url": "/s/search-results?domain="+domain+"&category="+encodeURIComponent(categorySelected)+"&subcategory="+encodeURIComponent(subcategorySelected)
            //});
            //urlEvent.fire();
            //Siri: Domain URL Changes -Task#389828
            window.open(optionSelected+"/s/search-results?domain="+domain+"&category="+encodeURIComponent(categorySelected)+"&subcategory="+encodeURIComponent(subcategorySelected),'_parent');
        }
    },
    handleCategoryBack:function() {
        if(document.getElementById('sidenav-level_1')){
            document.getElementById('sidenav-level_1').classList.add('slds-hide');
        }
        if(document.getElementById('sidenav-level_0')){
            document.getElementById('sidenav-level_0').classList.remove('slds-hide'); 
        }
        if(document.getElementById('mobile-search-category')){
            document.getElementById('mobile-search-category').classList.remove('slds-hide'); 
        }
        var categoryArray=document.getElementsByClassName('category');
        for(var i=0;i<categoryArray.length;i+=1){
            if(categoryArray[i].classList.contains('category-active')){
                categoryArray[i].classList.remove('category-active'); 
            }
        }
    },
    handleSubCategoryBack:function() {
        if(document.getElementById('sidenav-level_1')){
            document.getElementById('sidenav-level_1').classList.remove('slds-hide');
        }
        if(document.getElementById('sidenav-level_2')){
            document.getElementById('sidenav-level_2').classList.add('slds-hide');
        }
    }
})