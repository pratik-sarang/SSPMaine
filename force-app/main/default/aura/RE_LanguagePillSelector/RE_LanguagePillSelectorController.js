({
    //  onfocus : function(component, event) {
          onfocus : function(component) {
          try{
              //show spinner when request sent
              component.set('v.isSpinnerActive',true);
              
              var emptyObj = null;
              
              //reference to inherited super component
              var bSuper = component.find("bSuper");
              component.set("v.Message","");
              
              //override the method in super class and write your own logic with the response received
              bSuper.callServer(component, 'c.getAllLanguageOptions', function(response){
                  
                  //hide spinner when server response received
                  component.set('v.isSpinnerActive',false);
                  //to do
                  if(response.isSuccessful){
                      component.set("v.lstAllLanguages",response.objectData.lstLanguages);
                  }
                  else{
                      bSuper.showToast('ERROR', 'ERROR', 'Component failure , please contact your adminstrator');
                  }
              },emptyObj,false);
          }
          catch(e){
              //console.log('exception - '+e.stack);
              bSuper.consoleLog(e.stack, true);
          }
      },
      
      handleRemove: function(component, event) {
          /*var selectedLanguages = component.get("v.lstLanguages");
           var unSelectedLanguages = component.get("v.lstUnselectedLanguages");
           var selectedLanguage = component.get("v.lstUnselectedLanguages")[index];
           selectedLanguages.push(selectedLanguage);*/
          var bReadOnly = component.get("v.bMakeReadOnly");
          if(!bReadOnly){
              var selectedLanguages = component.get("v.lstLanguages");
              var sRemovedLanguage = event.getSource().get('v.label');
              
              var index2 = selectedLanguages.indexOf(sRemovedLanguage);
              selectedLanguages.splice(index2,1);
              component.set('v.lstLanguages',selectedLanguages);
              var cmpEvent = component.getEvent("LanguagesUpdateEvent"); 
              cmpEvent.setParams({"listSelectedLangs" : selectedLanguages}); 
              cmpEvent.fire(); 
          }
          
      },
    //  addLanguage: function(component, event) {
    addLanguage: function() {
         // component.set("v.bAddLanguageInput", true);
          //component.set("v.SearchKeyWord", "");
           var plusIcon = document.getElementById("plus-icon");
          var searchValue = document.getElementById("search-value");
          var searchOptions = document.getElementById("search-options");
          if (plusIcon) {
              plusIcon.classList.toggle("slds-hide");
          }
          if (searchOptions) {
              searchOptions.classList.toggle("slds-hide");
          }
          if (searchValue) {
              searchValue.classList.toggle("slds-hide");
              searchValue.focus();
          }
          //component.set("v.bAddValueInput", true);
          searchValue.value = "";
          
      },
      
      //keyPressController: function(component, event) {
      keyPressController: function(component) {
         var AllLanguages = [];
          AllLanguages = component.get("v.lstAllLanguages");
          var selectedLanguages =  component.get("v.lstLanguages");
          
          for (var i=0; i<selectedLanguages.length; i +=1) {
              var index = AllLanguages.indexOf(selectedLanguages[i]);
              if (index > -1) {
                  AllLanguages.splice(index, 1);
              }
          }
          
          component.set("v.lstUnselectedLanguages",AllLanguages);
          
          //var sSearchKeyword = component.get("v.SearchKeyWord").toUpperCase();
          var sSearchKeyword = document.getElementById("search-value").value.toUpperCase();
          
          if(sSearchKeyword.length !== 0){
              var searchResults = [];
            //  for(i=0 ; i<=AllLanguages.length; i++){
                  for(i=0 ; i<=AllLanguages.length; i +=1){
                  
                  var sLanguage  = AllLanguages[i];
                  
                  if(sLanguage !== undefined && sLanguage.toUpperCase().indexOf(sSearchKeyword) > -1){
                      searchResults.push(sLanguage);
                  }
                  
              }
              if((searchResults.length === 0)){
                  component.set("v.Message","No results found");
              }
              else{
                  component.set("v.Message","");
              }
              
              component.set('v.lstUnselectedLanguages',searchResults);
              
              //alert(component.get("v.lstUnselectedLanguages"));
          }
      },
      selectRecord: function(component, event) {
         
        // alert("hello select record");
          var selectedLanguages = component.get("v.lstLanguages");
          var unSelectedLanguages = component.get("v.lstUnselectedLanguages");
          var index = event.target.dataset.index;
          var selectedLanguage = component.get("v.lstUnselectedLanguages")[index];
          selectedLanguages.push(selectedLanguage);
          var index2 = unSelectedLanguages.indexOf(selectedLanguage);
          unSelectedLanguages.splice(index2,1);
          component.set('v.lstUnselectedLanguages',unSelectedLanguages); 
          component.set('v.lstLanguages',selectedLanguages); 
          
          var cmpEvent = component.getEvent("LanguagesUpdateEvent"); 
          cmpEvent.setParams({"listSelectedLangs" : selectedLanguages}); 
          cmpEvent.fire();
          
          //component.set("v.bAddLanguageInput", false); 
          
      },
       removeBox: function (component) {
          var plusIcon = document.getElementById("plus-icon");
          var searchValue = document.getElementById("search-value");
          var searchOptions = document.getElementById("search-options");
  
          if (plusIcon) {
              plusIcon.classList.toggle("slds-hide");
          }
          if (searchValue) {
              searchValue.classList.toggle("slds-hide");
          }
          if (searchOptions) {
              searchOptions.classList.toggle("slds-hide");
          }
          component.set("v.lstUnselectedLanguages", "");
      }
  })