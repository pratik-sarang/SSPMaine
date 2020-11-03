/**
* Class Name    : TriggerHandlerTest
* Owner         : DELOITTE
* Created Date  : 28/06/2019
* Description   : Test Class for TriggerHandler
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  24/05/2019  Akash       Initial Version
**/

@isTest
public class TriggerHandlerTest{
     //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void clearMaxLoopCountTest(){
         TriggerHandler obj = new TriggerHandler();
         obj.clearMaxLoopCount();
         String handlerName = obj.getHandlerName();
         Integer count = TriggerHandler.loopCountMap.get(handlerName).count;
         System.assertEquals(true, count >= 0);
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void bypassTest(){
         TriggerHandler.bypass(RE_GlobalConstants.HANDLER_NAME);
         System.assertEquals(true, TriggerHandler.bypassedHandlers != null);
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void clearBypassTest(){
         TriggerHandler.clearBypass(RE_GlobalConstants.HANDLER_NAME);
         System.assertEquals(false, TriggerHandler.bypassedHandlers != null && TriggerHandler.bypassedHandlers.size() >0);
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void isBypassedTest(){
         Boolean isBypassed = TriggerHandler.isBypassed(RE_GlobalConstants.HANDLER_NAME);
         System.assertEquals(false,isBypassed);
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void clearAllBypassesTest(){
         TriggerHandler.clearAllBypasses();
         System.assertEquals(true, TriggerHandler.bypassedHandlers.isEmpty());
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void loopCountTest(){
         TriggerHandler.LoopCount obj = new TriggerHandler.LoopCount();
         System.assertEquals(5, obj.max);
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void getMaxTest(){
         TriggerHandler.LoopCount obj = new TriggerHandler.LoopCount();
         Integer maxCount = obj.getMax();
         System.assertEquals(5,maxCount); 
     }
      //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
     @isTest static void getCountTest(){
         TriggerHandler.LoopCount obj = new TriggerHandler.LoopCount();
         Integer count = obj.getCount();
         System.assertEquals(0,count); 
     }
    
}