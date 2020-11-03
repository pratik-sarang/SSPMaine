({
    init : function(component, event, helper) {       
        helper.initHandler(component);
    },
	handleSearchDropdown : function() {
        document.getElementById('category-search-container').classList.toggle('dropdown-open');
	},
    handleCategoryClick : function(component, event) {
        if(event.keyCode === 13 || !event.keyCode){
            if($A.get("$Browser.isPhone")){
                if(document.getElementById('sidenav-level_0')){
                    document.getElementById('sidenav-level_0').classList.add('slds-hide'); 
                }
                if(document.getElementById('mobile-search-category')){
                    document.getElementById('mobile-search-category').classList.add('slds-hide'); 
                }
            }
            component.set("v.displayCategories", false);
            var category = event.currentTarget.getAttribute("data-category");
            var data = component.get("v.lstSDOHCategory")[0][category];
            component.set("v.categoryName", category);
            component.set("v.lstCategory", data);
            component.set("v.isMenuVisible",true);
            var generalId=event.currentTarget.id.split('-')[1];
            var categoriesArray=document.getElementsByClassName('category'); 
            for(var i=0;i<categoriesArray.length;i+=1){
                if(categoriesArray[i].id.split('-')[1] !== generalId){
                    categoriesArray[i].classList.remove('category-active');
                }
            }
            component.set("v.displayCategories", true);
            document.getElementById('category-'+generalId).classList.add('category-active');
        }
    }
})