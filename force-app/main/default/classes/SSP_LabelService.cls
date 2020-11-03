public class SSP_LabelService {
    List<String> names;
    private static final String SEPARATOR = ';';
    
    public SSP_LabelService () {
        String namesString = ApexPages.currentPage().getParameters().get('names');
        if(String.isBlank(namesString)) {
           	names = new List<String>();
        }
        else {
            names = namesString.split(SEPARATOR);
        }
    }
    
    public String getLabelString() {
        Map<String, String> labelNameValueMap = new Map<String, String>();
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        for(String name: names) {
            try {
                if(String.isNotBlank(name)) {
                    output.expressions.value = '{!$Label.' + name + '}';
                    labelNameValueMap.put(name, String.valueOf(output.value));
                }
            }
            catch(Exception e) {
                //Suppress errors.
            }
        }
        return JSON.serialize(labelNameValueMap);
    }
    
    public static Map<String, String> getValues(List<String> names) {
        String namesList = String.join(names, SEPARATOR);
        PageReference page = new PageReference('/apex/SSP_LabelService?names=' + namesList);
        String responseString = page.getContent().toString();
        Map<String, Object> nameObjectMap = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        Map<String, String> nameValueMap = new Map<String, String>();
        for(String name: nameObjectMap.keySet()) {
            nameValueMap.put(name, (String)nameObjectMap.get(name));
        }
        return nameValueMap;
    }
}