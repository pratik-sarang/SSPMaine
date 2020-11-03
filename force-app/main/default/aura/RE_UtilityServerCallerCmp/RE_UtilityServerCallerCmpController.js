({
    /* Function for making server calls from a central place. All other components will inherit base super to call the server method. */
    callServer : function(component, event) {
        try {
            var args = event.getParam('arguments');
            var cmp=args.cmp;
            var method=args.method;
            var callback=args.callback;
            var params=args.params;
            var cacheable=args.cacheable;
            var background=args.background;

            var action = cmp.get(method);
            if (params) {
                action.setParams(params);
            }
            if(background){
                action.setBackground();
            }
            if (cacheable) {
                action.setStorable();
            }
            action.setCallback(this,function(response) {
                
                var state = response.getState();
                var lightningServerResponse = response.getReturnValue();
                
                if (state === "SUCCESS") { 
                    // pass returned value to callback function
                    callback.call(this, lightningServerResponse);
                    if(lightningServerResponse.isSuccessful){
                        cmp.set("v.isSpinnerActive", false);
                    } else {            
                        cmp.set("v.isSpinnerActive", false);
                    }
                } else if (state === "ERROR") {
                    cmp.set("v.isSpinnerActive", false);
                    var errMsg = $A.get("$Label.c.servererror");
                    var toastObj = {
                        'title':$A.get("$Label.c.errorstatus"),
                        'type':$A.get("$Label.c.errorstatus"),
                        'msg':errMsg
                    }
                    event.setParam('arguments',toastObj);
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            event.setParam('arguments',{
                'message':e.stack,
                'error':true
            });            
        }
    },
    
    /*Function to navigate to a new page*/
    /*Added newTab parameter so that URLs can be opened in a new tab when needed */
    navigateToPage: function(component, event) {
        try {  
            /*Parameters:
            page (string) --> the page to be navigated.
            redirect (boolean) --> value for the isredirect parameter of force:navigateToURL event
            newTab (boolean) --> if this is true, link will open in new tab. This will only work for URLs which start with '.' */
            var params = event.getParam('arguments');
            var page = params.page;            
            var redirect = params.redirect;            
            var newTab = params.newTab;            
            var useEvent = params.useEvent;       
            
            if (((page[0] === '.')  || newTab) && (useEvent === undefined || !useEvent)) {                
                /*if (page[0] === '.' || newTab) {*/
                if (newTab) {
                    try{
                        var newWindow = window.open(page, '_blank');
                        if (newWindow === null && page[0] === '.' ) {
                            var navObj = {
                                'page':page,
                                'redirect':redirect,
                                'newTab':false,
                                'useEvent':useEvent
                            }
                            event.setParam('arguments',navObj);
                            this.navigateToPage(component, event);
                        }
                    }
                    catch(e){
                        //known to throw error in edge
                        var consoleLogObj = {
                            'message':e.stack,
                            'error':true
                        }
                        event.setParam('arguments',consoleLogObj);
                    }
                } else {
                    var tempLink = document.createElement('a');
                    tempLink.href = page;
                    document.location = tempLink.href;       
                }
            }
            else {                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": (useEvent) ? page : '/' + page,
                    /*"url": '/' + page,*/
                    "isredirect" : redirect
                });
                urlEvent.fire();
                
            }
        } catch(e) { 
            event.setParam('arguments',{
                'message':e.stack,
                'error':true
            });
        }
        
    },
    
    
    showToast: function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        var params = event.getParam('arguments');
        var title = params.title;
        var type = params.type;
        var msg = params.message;
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
        
    }
    
    
})