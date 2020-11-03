({
    initHandler : function(component) {
        try{             
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getDomainCategories', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful === true){
                    component.set("v.lstSDOHCategory", response.objectData.mapDomainCategories);
                    component.set("v.lstCategoryByLabel",response.objectData.mapCatCategories);
                    var masterConfig = response.objectData.mapConfigMasterRecords;
                    var masterConfigKeys = Object.keys(response.objectData.mapConfigMasterRecords);
                    var allConfigData = [];
                    for(var i in masterConfigKeys){
                        if(masterConfigKeys[i]!==undefined){
                        if (masterConfigKeys.hasOwnProperty(i)) {
                            var key = masterConfigKeys[i];
                            var arr = masterConfig[key];
                            for(var k =0; k<arr.length; k +=1){
                                allConfigData.push(arr[k]);
                            }
                        }
                        component.set("v.allConfigData", allConfigData);
                    }
                }
                }
            },{
                "showByCategory" : true
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    }
})