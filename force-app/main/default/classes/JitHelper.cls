public class JitHelper {

    public static User parseSamlAttribute(Map<String, String> attributes){
        
        User usr = new User();
        for(KOG_SAML_Attributes__c config : KOG_SAML_Attributes__c.getAll().values()){
            if(config.User_Field__c != null && attributes.containsKey(config.SAML_Attribute__c)){
                usr.put(config.User_Field__c , formatData(config.Data_Type__c, config.SAML_Attribute__c, attributes));
            }
        }
        return usr;
    }

    public static User sanitiseUser(User usr){
        usr.Username += '.kynect';
		if(usr.Username.length() > 80) {
            usr.Username = usr.Username.substring(0, 80);
        }
        return usr;
    }
    private static Object formatData(String dataType , String samlAttribute, Map<String, String> attributesMap ){
        
        if('Text'.equalsIgnoreCase(dataType)){
            return attributesMap.get(samlAttribute);
            }
        if('Boolean'.equalsIgnoreCase(dataType)){
            return Boolean.valueOf(attributesMap.get(samlAttribute));
            }
        if('Date'.equalsIgnoreCase(dataType)){
            return Date.valueOf(attributesMap.get(samlAttribute));
            }
        return attributesMap.get(samlAttribute);
    }
}