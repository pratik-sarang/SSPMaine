({
	 navigateToReportAConcern : function(){
        var urlEvent = $A.get("e.force:navigateToURL");
        /*var backurl=window.location.href;*/
        var backurl=document.URL;
        
        urlEvent.setParams({
            // added by Prashant for US - 137
            "url": '/report-concern?&backURL='+btoa(backurl)
        }); 
        urlEvent.fire();
    },
    openPrivacyPolicy: function(){
        var url="privacy-policy";
        window.open(url,'_blank');
    },
   openFaceBook: function(){
      window.open($A.get("$Label.c.facebook_link"));
   },
   openTwitter: function(){
       window.open($A.get("$Label.c.twitter_link"));
   },
   openKynect: function(){
   window.open($A.get("$Label.c.kynectgov_link"));
   },
    openTerms: function(){
        var url="terms-of-use";
        window.open(url,'_blank');
    },
    changeToLanguage : function(component, event, helper) {
       var spanishLang = $A.get("$Label.c.Spanish");
  	   var selLangOption = event.currentTarget.id;
       component.set("v.currentLang", selLangOption)               
       var selLang = (selLangOption === spanishLang ? "es_US" : "en_US");
       helper.switchLanguage(component, event, selLang);
    },
    navigateToGetStarted : function(component) {          
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/get-started"
        });
        urlEvent.fire();
    }    
})