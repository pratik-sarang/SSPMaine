/*
* classname     : CustomExceptionTest
* @description  : This class is use to cover class of CustomException
* @author       : Payal Dubela
* @date         : 08/23/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest
public class CustomExceptionTest {
     @isTest
    public static void CustomExceptiontest(){
        CustomException ce=new CustomException(null,'test');
        ce.code='list';
        ce.message='abcd';
        ce.ValidationMessages=null;
       list<validationMessage> l=null;
         CustomException ec=new CustomException(l);
       // Exception a=new Exception();
         CustomException ec1= new CustomException('test','list',ec);
         validationMessage vm=new validationMessage('test');
        
        CustomException ec2= new CustomException(new List<ValidationMessage>{vm});
         CustomException ec3= new CustomException(vm);

          //CustomException ec4= new CustomException('snapshot');
        ce.toString();
        ce.typ=CustomException.EXCEPTION_TYP.SYS;
        CustomException.assertValidException(ce, CustomException.EXCEPTION_TYP.SYS, 'list');
        
    }
    @isTest
    public static void CustomExceptiontest1(){
        CustomException ce=new CustomException(CustomException.EXCEPTION_TYP.VALID,'test','codetest');
    }
}