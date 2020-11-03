public class NavFlowStatJSONCLone {
    
    public static String createScreenStatusJSON(ContextData ctxData, NavFlowStatus__c navFlowStatus,
                                                NavFlowDetail__mdt navFlowDetail,
                                                Map<Integer,Boolean> ReviewRequiredMap, String oldStatus){
                                                    String screenStatus = '';                                                    
                                                    Map<Integer,String> intPageMap = new Map<Integer,String>();
                                                    Map<String,ParameterWrapper> screenStatusMap = new Map<String,ParameterWrapper>();
                                                    for(Integer i=0; i<navFlowDetail.Navigation_Flow_Page_Configuration__r.size(); i++){
                                                        intPageMap.put(i,navFlowDetail.Navigation_Flow_Page_Configuration__r[i].PageInfo__r.PageName__c);
                                                    }
                                                    set<String> lstReviewScreens = new   set<String>();
                                                    //Shikha
                                                    Set<String> reviewRequiredScreens = new Set<String>();
                                                    List<reviewRequiredWrapper> lstReviewRequired = new   List<reviewRequiredWrapper>();                                                    
                                                    if(String.isNotBlank(navFlowStatus.Screen_Status__c)){            
                                                        Map<String,Object> tempMap = (Map<String,Object>)JSON.deserializeUntyped(navFlowStatus.Screen_Status__c);
                                                        
                                                        for(String tempObj : tempMap.keySet()){                                                            
                                                            reviewRequiredWrapper objReview = (reviewRequiredWrapper)JSON.deserialize(JSON.serialize(tempMap.get(tempObj)),reviewRequiredWrapper.CLASS);
                                                            if(objReview.isReviewRequired){
                                                                lstReviewScreens.add(tempObj); 
                                                                reviewRequiredScreens.add(tempObj);
                                                            }
                                                            
                                                        }            
                                                    }              
                                                    String flowStatus = String.isNotBlank(navFlowStatus.FlowDupStatus__c) && String.isNotEmpty(navFlowStatus.FlowDupStatus__c) ? navFlowStatus.FlowDupStatus__c : '';
                                                    
                                                    Integer[] flowStatusChars = flowStatus.getChars(); 
                                                    
                                                    for(Integer i=0; i<flowStatusChars.size(); i++){
                                                        List<ParameterWrapper> lstParameter = new List<ParameterWrapper>(); 
                                                        
                                                        // if(screenStatusMap.ScreenName == intPageMap.get(i)){
                                                        String flowStat = (String.isNotBlank(flowStatus) && String.isNotEmpty(flowStatus))? String.fromCharArray(new List<Integer> {flowStatus.charAt(i)}) : '';
                                                        ParameterWrapper objParam = new ParameterWrapper();
                                                        objParam.Status = flowStat;
                                                        String oldStat = '';
                                                        oldStat = (String.isNotBlank(oldStatus) && String.isNotEmpty(oldStatus)) ? String.fromCharArray( new List<Integer> {oldStatus.charAt(i)}) : '';  
                                                        objParam.oldStatus = oldStat;
                                                    //Shikha -- start
                                                    if(ctxData.modeValue == 'RAC' && !reviewRequiredScreens.isEmpty() && reviewRequiredScreens.contains(intPageMap.get(i))){
                                                        objParam.isReviewRequired = (objParam != null ?
                                                                                 (objParam.oldStatus != null && objParam.Status != null) ?
                                                                                 ((objParam.oldStatus == 'R' || objParam.oldStatus == 'N') && objParam.Status == 'R') ? true : false : false : false);                                                        
                                                    }                                                                                                                
                                                    else if(ctxData.modeValue != 'RAC'){                                                     
                                                        objParam.isReviewRequired = (objParam != null ?
                                                                                 (objParam.oldStatus != null && objParam.Status != null) ?
                                                                                 ((objParam.oldStatus == 'R' || objParam.oldStatus == 'N') && objParam.Status == 'R') ? true : false : false : false);
                                                    }
                                                    else{
                                                        //else if(intPageMap.get(i) == 'SSP_APP_Details_Disability' || intPageMap.get(i) == 'SSP_APP_Details_Blindness' 
                                                          // || intPageMap.get(i) == 'SSP_APP_Details_HealthCondition'){
                                                        objParam.isReviewRequired = false;
                                                    //}
                                                    }
                                                    
                                                    //Shikha -- end 
                                                        if(lstReviewScreens.isEmpty()){
                                                            objParam.isReviewRequired  = false;
                                                        }
                                                        if((objParam != null && objParam.isReviewRequired != null && objParam.isReviewRequired == false)){                                                            
                                                            objParam.reviewReqScreens =  null;    
                                                            
                                                        }else  if((objParam != null && objParam.isReviewRequired != null && objParam.isReviewRequired == true && !lstReviewScreens.isEmpty())){                                                            
                                                             objParam.reviewReqScreens = String.join(new List<String>(lstReviewScreens),',');
                                                        }else  if(lstReviewScreens.isEmpty()){
                                                            objParam.isReviewRequired  = false;
                                                              objParam.reviewReqScreens =  null;    
                                                        }
                                                        
                                                        //  }
                                                        screenStatusMap.put(intPageMap.get(i),objParam);
                                                        
                                                    }
                                                    screenStatus = !screenStatusMap.isEmpty() ? JSON.serialize(screenStatusMap) : null;

                                                    
                                                    
                                                    return screenStatus;
                                                }
    
    public class reviewRequiredWrapper {
        public Boolean isReviewRequired;
        public String Status;   
        
    }
    public class ParameterWrapper{
        public String reviewReqScreens;
        public String oldStatus;
        public Boolean isReviewRequired;
        public String Status;
        
    }
    
}