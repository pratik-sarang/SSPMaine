/*
* classname     : SFDCIntegerValidationRuleTest
* @description  : This class is use to cover class of SFDCIntegerValidationRule
* @author       : Payal Dubela
* @date         : 08/23/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SFDCIntegerValidationRuleTest {
    @isTest
    public static void testMethod1(){
       SFDCValidator stvr= new SFDCValidator();
       stvr.getValidInteger('200',  0, 50000, false);
    }
    @isTest
    public static void testMethod2(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidInteger('200',5000,500, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('maxValue must be larger than minValue'),true);
        }
       
    }
     @isTest
    public static void testMethod3(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidInteger(null,500,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Input integer required'),true);
        }
        try{
            stvr.getValidInteger(null,500,5000, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Input integer required'),true);
        }
       
    }
    @isTest
    public static void testMethod4(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidInteger('200',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid integer input must be between'),true);
        }
       
    }
    @isTest
    public static void testMethod5(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidInteger('20000',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid integer input must be between'),true);
        }
       
    }
    @isTest
    public static void testMethod6(){
       SFDCValidator stvr= new SFDCValidator();
        try{
            stvr.getValidInteger('str',1000,5000, false);
            stvr.getValidInteger('1231244533',1000,5000, false);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid integer input'),true);
        }
       
    }

}