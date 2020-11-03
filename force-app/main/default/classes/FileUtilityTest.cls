@isTest
public class FileUtilityTest {
    
    static testmethod void ContentVersionTest(){
        List<File_Extension_Setting__c> lstExt= new List<File_Extension_Setting__c>();
        File_Extension_Setting__c fileExt1 = new File_Extension_Setting__c();
        fileExt1.Is_Allowed__c=true;
        fileExt1.Name='docx';
        fileExt1.Value__c='docx';
        lstExt.add(fileExt1);
        
        File_Extension_Setting__c fileExt2 = new File_Extension_Setting__c();
        fileExt2.Is_Allowed__c=true;
        fileExt2.Name='jpg';
        fileExt2.Value__c='jpg';
        lstExt.add(fileExt2);
        insert lstExt;
        test.startTest();
        FileUtility fl = new FileUtility();
        
        ContentVersion content=new ContentVersion();
        content.Title = 'test';
        content.VersionData=blob.valueof('New Bitmap Image.jpg');
        content.PathOnClient='/' + content.Title + '.exe';
        try{
        insert content;
        }
        catch(DMLException e){
            System.assertEquals(e.getDmlMessage(0),System.Label.RE_FileExtentionError) ;
        }
        test.stopTest();     
    }
}