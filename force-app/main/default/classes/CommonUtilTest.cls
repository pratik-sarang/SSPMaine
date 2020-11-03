@istest
public class CommonUtilTest {
    
    @testsetup
    public static void createTestData(){
        
        String profileName='System Administrator';
        TimeZone mtz = Timezone.getTimeZone('America/Los_Angeles'); 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile commUserProfile = [Select Id from Profile where name= :profileName limit 1];
        Long randomNumber = Math.mod (Math.mod (System.currentTimeMillis(), 1000000) , 989898989);
        User userTimeZone = new User(Alias = 'assis', Email='test@gmail.com', LastName='Testing1', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = commUserProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='unittestuser'+randomNumber+'@testorg.com',
                                     IsActive = true,userRoleId = portalRole.Id );
        insert userTimeZone;
        
    }
    @istest
    Public static void isEmptytest(){
        
        system.assertEquals(CommonUtil.isEmpty(new List<Object>{1,2,3}),false);
    }
    @istest
    Public static void isNotEmptytest(){
        
        system.assertEquals(CommonUtil.isNotEmpty(new List<Object>{1,2,3}),true);
    }
    @istest
    public static void replaceStringtest(){
        system.assertEquals(CommonUtil.replaceString('abc',5,'s'),'abc');
        system.assertEquals(CommonUtil.replaceString('abcd',2,'s'),'absd');    
    } 
    @istest
    public static void getTypetest(){
        system.debug(CommonUtil.getType('Context'));
    }
    
    @istest
    public static void collectionContainstest(){
        system.assertEquals(CommonUtil.collectionContains(new List<String>{'abc','def','ghi'},'def'),true);
        system.assertEquals(CommonUtil.collectionContains(new List<Object>{'abc','def','ghi'},'def'),true);
    }
    
    @istest
    public static void formatDate(){
        User adminUser =[Select id from User where email=:'test@gmail.com' AND isActive = TRUE Limit 1];
    
        system.runAs(adminUser){
        system.assertEquals(CommonUtil.formatDate(date.newInstance(2020, 02, 24)), '02/24/2020');
        system.assertEquals(CommonUtil.formatDate(null),null);
        }
    }
    
    @istest
    public static void mergeMultiValuetest(){
        system.assertEquals(CommonUtil.mergeMultiValue(new List<String>{'abc','def','ghi'}),'abc;def;ghi');
        system.assertEquals(CommonUtil.mergeMultiValue(new List<String>{'abc','def','ghi'},';'),'abc;def;ghi');   
    }
    @istest
    public static void splitMultiValuetest(){
        system.assertEquals(CommonUtil.splitMultiValue('abc;def;ghi'),new List<String>{'abc','def','ghi'});
    }
    @istest
    public static void toIntegertest(){
        system.assertEquals(CommonUtil.toInteger('1'),1);
    }
    @istest
    public static void toNumbertest(){
        system.assertEquals(CommonUtil.toNumber('1'),1);
    }
    @istest
    public static void toDecimaltest(){
        system.assertEquals(CommonUtil.toDecimal('10'),10);
    }
    @istest
    public static void toDoubletest(){
        system.assertEquals(CommonUtil.toDouble('10'),10);
    }
    @istest
    public static void toBooleantest(){
        system.assertEquals(CommonUtil.toBoolean('true'),true);      
        system.assertEquals(CommonUtil.toBoolean('false'),false);        
    }
    @istest
    public static void isTruetest(){
        system.assertEquals(CommonUtil.isTrue('true'),true);    
        system.assertEquals(CommonUtil.isTrue('false'),false);     
    }
    @istest
    public static void isFalsetest(){
        system.assertEquals(CommonUtil.isFalse('false'),true);    
        system.assertEquals(CommonUtil.isFalse('true'),false);     
    }
    @istest
    public static void toDatetest(){
        system.assertEquals(CommonUtil.toDate('12/28/2009'),date.newInstance(2009, 12, 28));
    }
    @istest
    public static void formatToUTCTimeZonetest(){
        User adminUser =[Select id from User where email=:'test@gmail.com' AND isActive = TRUE Limit 1];
        system.runAs(adminUser){
            DateTime dt = DateTime.newInstance(2017,2,3,21,20,30);
            system.debug('## timezone '+CommonUtil.formatToUTCTimeZone(dt));        
            system.assertEquals(CommonUtil.formatToUTCTimeZone(dt),'2017-02-04T05:20:30Z');
        }
    }
    @istest
    public static void formatToMSTtest(){
        User adminUser =[Select id from User where email=:'test@gmail.com' AND isActive = TRUE Limit 1];
        system.runAs(adminUser){
            DateTime dt = DateTime.newInstance(2017,2,3,14,20,30);
            system.debug('timeValue '+CommonUtil.formatToMST(dt));
            system.assertEquals(CommonUtil.formatToMST(dt),'02/03/2017 03:20:30');
        }
    }
    
    @istest
    public static void deriveFieldNametest(){
        system.assertEquals(CommonUtil.deriveFieldName('testfield'),'testfield');
    }
    @istest
    public static void cleanNametest(){
        system.assertEquals(CommonUtil.cleanName('testfield__c'),'Testfield');
    }
    @istest
    public static void getCastTypetest(){
        CommonUtil.getCastType('String');
        CommonUtil.getCastType('base64');
        CommonUtil.getCastType('Percent');
        CommonUtil.getCastType('Email');
    }
    
    @istest
    public static void getClassNametest(){
        Account A=new Account();
        A.Name='Test';
        system.assertEquals(CommonUtil.getClassName(A),'Account');
    }
    @istest
    public static void stringQueryValuetest(){
        
        system.assertEquals(CommonUtil.stringQueryValue('AB\'C'),'AB\\\'C');
    }
    @istest
    public static void randomTest(){
        system.assertEquals(Math.floor(Math.log10(CommonUtil.random(2))+1),2);
        system.assertEquals(CommonUtil.random(0),null);
        
    }
    @istest
    public static void replaceTokenstest(){
        String[] tokens = new String[]{};
            tokens.add('random');
        String result = CommonUtil.replaceTokens('More Information About {0}', tokens);
        System.assertEquals(result,'More Information About random');
    }
    @istest
    public static void toStringtest(){
        context ctx=new context();
        ctx.lang='EN';
        Case ob=new Case();
        String objType='Case';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Set<String> setFieldMap = fieldMap.keySet();
        List<String> lstFieldMap = new List<String>();
        lstFieldMap.addAll(setFieldMap);        
        Schema.DisplayType fielddataType = fieldMap.get(lstFieldMap[0]).getDescribe().getType();
        CommonUtil.toString(ctx,ob,fielddataType);
        fielddataType = fieldMap.get('ClosedDate').getDescribe().getType();
        CommonUtil.toString(ctx,system.now(),fielddataType);
        //application date - 
        String appObjType='SSP_Application__c';
        Map<String, Schema.SObjectType> schemaMap1 = Schema.getGlobalDescribe();
        Schema.SObjectType appSchema = schemaMap1.get(appObjType);
        Map<String, Schema.SObjectField> appfieldMap = appSchema.getDescribe().fields.getMap();
        Set<String> setAppFieldMap = appfieldMap.keySet();
        List<String> lstAppFieldMap = new List<String>();
        lstAppFieldMap.addAll(setAppFieldMap);        
        Schema.DisplayType appfielddataType = appfieldMap.get(lstAppFieldMap[0]).getDescribe().getType();
        CommonUtil.toString(ctx,ob,appfielddataType);
        fielddataType = appfieldMap.get('ApplicationCreationInSSP__c').getDescribe().getType();
        CommonUtil.toString(ctx,system.today(),fielddataType);
        
        /*fielddataType = fieldMap.get('DueDate__c').getDescribe().getType();
        CommonUtil.toString(ctx,system.today(),fielddataType);*/
        
    }
    @istest
    public static void fromStringtest(){
        context ctx=new context();
        Account ob=new Account();
        String objType='Account';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Set<String> setFieldMap = fieldMap.keySet();
        List<String> lstFieldMap = new List<String>();
        lstFieldMap.addAll(setFieldMap);
        Schema.DisplayType fielddataType = fieldMap.get(lstFieldMap[0]).getDescribe().getType();
        CommonUtil.fromString(ctx,objType,fielddataType);
    }
    
    @istest
    public static void getPageParamtest(){
        //  system.assertEquals(CommonUtil.getPageParam('testfield'),'testfield');
        system.assertEquals(CommonUtil.getPageParam(null),null);
        
    }
}