/*
* classname     : SFDCStringValidationRuleTest
* @description  : This class is use to cover class of SFDCStringValidationRule
* @author       : Payal Dubela
* @date         : 08/23/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SFDCStringValidationRuleTest {
    @isTest
    public static void testMethod1(){
       SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
       SFDCStringValidationRule stvr1= new SFDCStringValidationRule('Date',SFDCPatterns.Date1);
        try{
            SFDCStringValidationRule stvr2= new SFDCStringValidationRule('Date',null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Pattern cannot be null'),true);
        }
    }
    @isTest
    public static void testMethod2(){
        Pattern p = Pattern.compile(SFDCPatterns.URL);
         try{
            SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date','^([123]0|[01');
            stvr.addWhitelistPattern(p);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Validation misconfiguration, problem with specified pattern'),true);
        }   
    }
     @isTest
    public static void testMethod3(){
        Pattern p = Pattern.compile(SFDCPatterns.URL);
         try{
            SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
            stvr.addWhitelistPattern(p);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Validation misconfiguration, problem with specified pattern'),true);
        } 
    }
    @isTest
    public static void testMethod4(){
        String pattern=null;
         try{
            SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
            stvr.addBlacklistPattern(pattern);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Pattern cannot be null'),true);
        } 
        try{
            SFDCStringValidationRule stvr1= new SFDCStringValidationRule('Date');
            stvr1.addBlacklistPattern(SFDCPatterns.URL);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Validation misconfiguration, problem with specified pattern'),true);
        } 
         
    }
     @isTest
    public static void testMethod5(){
         Pattern p = Pattern.compile(SFDCPatterns.URL);
         Pattern p1;
        SFDCStringValidationRule stvr2= new SFDCStringValidationRule('Date');
         stvr2.addBlacklistPattern(p);
        try{
            SFDCStringValidationRule stvr3= new SFDCStringValidationRule('Date');
            stvr3.addBlacklistPattern(p1);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Pattern cannot be null'),true);
        }
        try{
            SFDCStringValidationRule stvr4= new SFDCStringValidationRule('Date');
            stvr4.addBlacklistPattern(p1);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Pattern cannot be null'),true);
        }
    }
    @isTest
    public static void testMethod6(){
        SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
        stvr.setMinimumLength(1);
        stvr.setMaximumLength(100);
        stvr.setAllowNull(true);
        try{
          stvr.assertValid(null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('SFDCStringValidationRule - Input required'),true);
        }

        
    }
     @isTest
    public static void testMethod7(){
        SFDCValidator SFDCdate = new SFDCValidator();
         SFDCdate.SFDC_getValidDate('01/02/90', SFDCPatterns.Date1, false); 
    }
     @isTest
    public static void testMethod8(){
        SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
        stvr.setMinimumLength(10);
        stvr.setMaximumLength(100);
        try{
        stvr.assertValid('01/02/90');
        }catch(Exception e){
            System.assert(e.getMessage().contains('SFDCStringValidationRule - Input is too short'),true);
        }  
    }
    @isTest
    public static void testMethod9(){
        SFDCStringValidationRule stvr= new SFDCStringValidationRule('Date');
        stvr.setMinimumLength(1);
        stvr.setMaximumLength(5);
        try{
         stvr.assertValid('01/02/90');
        }catch(Exception e){
            System.assert(e.getMessage().contains('SFDCStringValidationRule - Input is too long'),true);
        }  
    }
     @isTest
    public static void testMethod10(){
        SFDCStringValidationRule stvr1= new SFDCStringValidationRule('Date',SFDCPatterns.Date1);
        stvr1.setMinimumLength(1);
        stvr1.setMaximumLength(100);
        try{
         stvr1.assertValid('01/02/190');
        }catch(Exception e){
            System.assert(e.getMessage().contains('SFDCStringValidationRule - Invalid input, please conform to pattern.'),true);
        }  
    }
    @isTest
    public static void testMethod11(){
        SFDCStringValidationRule stvr1= new SFDCStringValidationRule('Date');
        stvr1.addBlacklistPattern(SFDCPatterns.URL);
        stvr1.setMinimumLength(1);
        stvr1.setMaximumLength(100);
        try{
         stvr1.assertValid('www.test.com');
        }catch(Exception e){
            System.assert(e.getMessage().contains('SFDCStringValidationRule - Invalid input, dangerous input matching detected.'),true);
        }  
    }
        
  }