({
    onLoadHelper : function(component) {
        var bSuper = component.find("bSuper");
        var self = this;
        try{
            component.set('v.isSpinnerActive',true);
            bSuper.callServer(component, 'c.getLineChartMap', function(response){
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){  
                    var objectData = response.objectData;
                   
                    var referralSentData = JSON.parse(objectData.ReferralSent);
                    var referralClosedData = JSON.parse(objectData.ReferralClosed);
                 
                    var sentData = self.populateMissingValues(component,referralSentData);
                    var closedData = self.populateMissingValues(component,referralClosedData);
                                     
                    
                    component.set("v.referralsSent",sentData.reverse());
                    component.set("v.referralsClosed",closedData.reverse());
                    component.set("v.showGraph",true);
                }
                
            },null,false);
        }catch(e){
            bSuper.consoleLog(e.stack, true);
        }
        
    },
    
    populateMissingValues : function(component,objdata){
        
        var todaysDate = new Date();
        var todaysMonth = todaysDate.getMonth()+1;
        var dateVar;
        var yearVar;
        var obj = objdata.reverse();
        
        for(var x = 0; x<6; x+=1) {
            dateVar = new Date(todaysDate.getFullYear(),todaysDate.getMonth()-x,todaysDate.getDate());
            var currentMonth = dateVar.getMonth() + 1;
            
            if(todaysMonth - currentMonth < 0){
                yearVar = todaysDate.getFullYear() -1;
            }else{
                yearVar = todaysDate.getFullYear();
            }
            if(obj[x] === undefined || obj[x].mon !== currentMonth) {
                var data = {
                    "year": yearVar,
                    "refSent": 0,
                    "mon": currentMonth
                }
              
                obj.splice(x,0, data);
                
            }  
            
            
        }
        return obj;
        
        
    }
    
    
})