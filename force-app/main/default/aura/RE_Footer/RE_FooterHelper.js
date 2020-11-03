({
   
	parseQueryString  : function (component,event,query) {
       var urlParams = {};
       if(undefined !== query){ 
        var match, pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g, decode = function(s) {
            return decodeURIComponent(s.replace(pl, " "));
        };
        //Do Not Replace this as part of LV issues -Payal Dubela (Search screen fails for spanish)
        while (match = search.exec(query)){
            urlParams[decode(match[1])] = decode(match[2]);
        }
       }
        return urlParams;
    },
    
    saveUserLanguageLocaleKey : function(component, selLang) {
        component.set("v.currentUser.LanguageLocaleKey", selLang);
        component.set("v.currentUser.LocaleSidKey", selLang);
        component.find("userRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                  window.location.reload();  
            } else if (saveResult.state === "INCOMPLETE") {
            } else if (saveResult.state === "ERROR") { 
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i+=1) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                  LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_FooterHelper', 'saveUserLanguageLocaleKey', errMsg, true);
            } else {
            }
        }));

    },

    switchLanguage : function(component, event, selLang) {
        try{
            
            var toUrl = '';
            var urlOnly = '';
            var paramStr = '';
            var params;
            var href =  document.URL;
            urlOnly = href.split('?')[0];
            paramStr = href.split('?')[1];
            params = this.parseQueryString(component, event,paramStr);
            if(undefined === params) {
                params = new Object();
            } 
            params.language = selLang;
            toUrl = urlOnly;
            Object.keys(params).forEach(function(key,index) {
                toUrl += (index === 0 ? '?' : '&') + encodeURI(key) + '=' + encodeURI(params[key]);  
            });
            if(! $A.util.isEmpty(toUrl)){
                if($A.util.isEmpty($A.get('$SObjectType.CurrentUser.Id'))){ 
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": toUrl
                    });
                    urlEvent.fire();
                    window.location.reload();  
                } else {
                    this.saveUserLanguageLocaleKey(component, selLang);
                }   
                 
            }
        }
        catch(e){
        }
    },
})