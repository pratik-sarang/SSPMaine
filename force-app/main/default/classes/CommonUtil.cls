/**
 * Contains common utility methods... 
 *
 * @author Rahman A
 * @date 10/04/2013
 */
public with sharing class CommonUtil {

	/**
	 * Returns true if the list is null or empty. Else, returns false.
	 * @param values List of objects to test.
	 *
	 * @return Boolean 
	 */
	public static boolean isEmpty(List<Object> values){
		return (values == null || values.size() < 1) ? true : false;
	}

	/**
	 * Returns true if the list has at least one element. Else, returns false.
	 * @param values List of objects to test.
	 *
	 * @return Boolean 
	 */
	public static boolean isNotEmpty(List<Object> values){
		return !isEmpty(values);
	}

	/**
	 * Replaces given string's idx value with new value.
	 *
	 * @param input String Original string value.
	 * @param idx Integer Index position where the new value needs to be set.
	 * @param newVal String new value.
	 * 
	 * @return String modified string value.
	 */
	public static String replaceString(String input, Integer idx, String newVal){
		if(idx < 0 || idx >= input.length()){
			return input;
		}
		String left = '';
		String right = '';
		if(idx > 0){
			left = input.subString(0, idx);
		}
		if(idx < input.length()){
			right = input.subString(idx+1);
		}
		return left + newVal + right;
	}

	/**
	 * Returns Apex Class Type for the given class name.
	 *
	 * @param clsName String Class name
	 * 
	 * @return Type Apex Class type.
	 * @deprecated Use CommonFactory.getClassType method.
	 */
	public static Type getType(String clsName){
		Type typ = null;
		if(null != clsName){
			typ = Type.forName(clsName);
			if(null == typ){
				//throw new CustomException(CustomException.EXCEPTION_TYP.SYS, 'Could not find Apex class [' + clsName + '] in the org. \n', 'ERR_CLS_NOT_FOUND');
			}
		}
		return typ;
	}

	/**
	 * Returns the text value inside an element.
	 *
	 * @param xmlReader XMLStreamReader containing the XML node.
	 *
	 * @return String Node value.
	 */
	public static String getElementValue(XMLStreamReader xmlReader){
		String value = null;
		while(xmlReader.hasNext()){
			if(xmlReader.getEventType() == XmlTag.CHARACTERS) {
				value = xmlReader.getText();
				if(String.isNotBlank(value)){
					value = value.trim();
				}
				else{
					value = null;
				}
				break;
			}
			xmlReader.next();
		}
		return value;
	}

	/**
	 * Returns the request parameter value from the current visualforce page.
	 *
	 * @param paramName Page parameter name to get.
	 *
	 * @return String Parameter value.
	 */	
	public static String getPageParam(String paramName){
		if(ApexPages.currentPage() != null){  
			return ApexPages.currentPage().getParameters().get(paramName);  
		} 
		return null;
	}

	/**
	 * Returns true if the valueToCheck is available in allValues array. Else, returns false.
	 *
	 * @param allValues array of all values 
	 * @param valueToCheck value that needs to be checked.
	 *
	 * @return Boolean
	 */
	public static boolean collectionContains(List<String> allValues, String valueToCheck){
		return indexOf(allValues, valueToCheck) > -1;
	}

	/**
	 * Returns index of the value within the collection. If the value does not exist then a negative value returned.
	 *
	 * @param allValues array of all values 
	 * @param valueToCheck value that needs to be checked.
	 *
	 * @return Integer
	 */
	public static Integer indexOf(List<String> allValues, String valueToCheck){
		Integer idx = -1;
		for(Integer i=0; i< allValues.size(); i ++ ){
			if(allValues[i].equals(valueToCheck)){
				idx = i;
				break;
			}
		}
		return idx;
	}

	/**
	 * Returns true if the valueToCheck is available in allValues array.
	 *
	 * @param allValues array of all values 
	 * @param valueToCheck value that needs to be checked.
	 *
	 * @return Boolean
	 */
	public static boolean collectionContains(List<Object> allValues, Object valueToCheck){
		return indexOf(allValues, valueToCheck) > -1;
	}

	/**
	 * Returns index of the value within the collection. If the value does not exist then a negative value returned.
	 *
	 * @param allValues array of all values 
	 * @param valueToCheck value that needs to be checked.
	 *
	 * @return Integer
	 */
	public static Integer indexOf(List<Object> allValues, Object valueToCheck){
		Integer idx = -1;
		for(Integer i=0; i< allValues.size(); i ++ ){
			if(allValues[i] == valueToCheck){
				idx = i;
				break;
			}
		}
		return idx;
	}

	/**
	 * Formats the given Date into string format. Default language (English-US) is used to format.
	 *
	 * @param dte Date to format
	 *
	 * @return String formatted date.
	 */
	public static String formatDate(Date dte){ 
		return formatDate(dte, 'en');//GlobalConstants.DEFAULT_LANG);
	}

	/**
	 * Formats the given Date into string format using the language code.
	 *
	 * @param dte Date to format
	 * @param lang String language code
	 *
	 * @return String formatted date.
	 */
	public static String formatDate(Date dte, String lang){
		if(null != dte){
			String pattern = 'es'.equalsIgnoreCase(lang) ? 'dd/MM/yyyy' : 'MM/dd/yyyy';
			Datetime dt = Datetime.newInstance(dte, Time.newInstance(0, 0, 0, 0));
			return dt.format(pattern, 'America/Denver');
		}
		return null;
	}

	/**
	 * Merges list of String values into a single String separated by semi colon(;). This is useful for storing
	 * multi-select picklist values.
	 *
	 * @param values List of String to merge.
	 *
	 * @return String Merged string value.
	 */
	public static String mergeMultiValue(List<String> values){
		return mergeMultiValue(values, ';', false);
	}

	/**
	 * Merges list of String values into a single String separated by given delimiter. This is useful for storing
	 * multi-select picklist values.
	 *
	 * @param values List of String to merge.
	 * @param delimiter String Delimiter to be used for concatenating the string values.
	 *
	 * @return String Merged string value.
	 */
	public static String mergeMultiValue(List<String> values, String delimiter){
		return mergeMultiValue(values, delimiter, false);
	}

	/**
	 * Merges list of String values into a single String separated by given delimiter.
	 *
	 * @param values List of String to merge.
	 * @param delimiter String Delimiter to be used for concatenating the string values.
	 * @param withQuotesFlag Boolean to indicate if the string needs to be escaped with single quotes.
	 *
	 * @return String Merged string value.
	 */
	public static String mergeMultiValue(List<String> values, String delimiter, boolean withQuotesFlag){
		String val = '';
		if(isNotEmpty(values)){
			for(String value : values){
				val += (withQuotesFlag ? '\'' : '') + value + (withQuotesFlag ? '\'' : '') + delimiter;
			}
			val = val.subString(0, (val.length() - delimiter.length()));
		}
		return val;
	}

	/**
	 * Splits given string using semi colon(;) and returns list of split values.
	 *
	 * @param value String to split.
	 *
	 * @return List<String> List of String values.
	 */
	public static List<String> splitMultiValue(String value){
		List<String> values = null;
		if(String.isNotBlank(value)){
			values = value.split(';');
		}
		return values;
	}

	/**
	 * Returns Integer object for the given string.
	 *
	 * @param str String to convert.
	 *
	 * @return Integer value.
	 */
	public static Integer toInteger(String str){
		Integer intgr = null;
		if(String.isNotBlank(str)){
			intgr = Integer.valueOf(str);
		}
		return intgr;
	}

	/**
	 * Returns Integer object for the given string.
	 *
	 * @param str String to convert.
	 *
	 * @return Integer value.
	 */
	public static Integer toNumber(String str){
		return toInteger(str);
	}

	/**
	 * Returns Decimal object for the given string.
	 *
	 * @param str String to convert.
	 *
	 * @return Decimal value.
	 */
	public static Decimal toDecimal(String str){
		Decimal decml = null;
		if(String.isNotBlank(str)){
			decml = Decimal.valueOf(str);
		}
		return decml;
	}

	/**
	 * Returns Double object for the given string.
	 *
	 * @param str String to convert.
	 *
	 * @return Double value.
	 */
	public static Double toDouble(String str){
		Double dbl = null;
		if(String.isNotBlank(str)){
			dbl = Double.valueOf(str);
		}
		return dbl;
	}

	/**
	 * Returns boolean equivalent of the passed string.
	 * <p>
	  	NOTE: If the string value is null or not of boolean representation then
	 	null will be returned.
	 *
	 * @param str String to test.
	 *
	 * @return Boolean value.
	 */
	public static Boolean toBoolean(String str){
		Boolean bool = null;
		if(String.isNotBlank(str)){
			str = str.toLowerCase();
			if('true'.equals(str) || 'yes'.equals(str) || 'y'.equals(str)){
				bool = true;
			}

			else if('false'.equals(str) || 'no'.equals(str) || 'n'.equals(str)){
				bool = false;
			}

		}
		return bool;
	}

	/**
	 * Returns true if the string equates to boolean "true". Else, returns false.
	 *
	 * @param str String to test.
	 *
	 * @return Boolean value.
	 */
	public static Boolean isTrue(String str){
		Boolean bool = toBoolean(str); 
		return (bool == null) ? false : bool;
	}

	/**
	 * Returns true if the string equates to boolean "false". Else, returns false.
	 *
	 * @param str String to convert.
	 *
	 * @return Boolean test.
	 */
	public static Boolean isFalse(String str){
		Boolean bool = toBoolean(str); 
		return (bool == null) ? false : !bool;
	}

	/**
	 * Returns Date object for the given string. String should be of MM/dd/yyyy format.
	 *
	 * @param str String to convert.
	 *
	 * @return Integer value.
	 */
	public static Date toDate(String str){
		Date dte = null;
		if(String.isNotBlank(str)){
			dte = Date.parse(str);
		}
		return dte;
	}

	/**
	 * Formats the date & time to UTC format.
	 *
	 * @param dteTime DateTime to format.
	 *
	 * @return String formatted datetime.
	 */
	public static String formatToUTCTimeZone(DateTime dteTime) {
		return dteTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
	}

	/**
	 * Formats the date & time to MST format.
	 *
	 * @param dteTime DateTime to format.
	 *
	 * @return String formatted datetime.
	 */
	public static String formatToMST(DateTime dteTime) {
		return dteTime.format('MM/dd/yyyy hh:mm:ss', 'America/Denver');
	}

	/**
	 * Returns a cleaned up & camelcased string. This is useful for 
	 * deriving Apex field names using the sObject names.
	 *
	 * @param sfName String sObject/field name.
	 *
	 * @return String cleaned up name.
	 */
	public static String deriveFieldName(String sfName){
		return cleanSFName(sfName).uncapitalize();
	}

	/**
	 * Returns a cleaned up & camelcased string. This is useful for 
	 * deriving Apex field names using the sObject names.
	 *
	 * @param name String sObject/field name.
	 *
	 * @return String cleaned up name.
	 */
	public static String cleanName(String name){
		// TODO find special char and replace using regex
		name = name.replaceAll('__c', '').replaceAll('__C', '').replaceAll(' ', '');
		name = toCamelCase(name);
		return name;
	}

	/**
	 * Returns a cleaned up & camelcased string. This is useful for 
	 * deriving Apex field names using the sObject names.
	 *
	 * @param name String sObject/field name.
	 *
	 * @return String cleaned up name.
	 */
	public static String cleanSFName(String name){
		name = name.replaceAll('__c', '').replaceAll('__C', '');
		name = toCamelCase(name);
		return name;
	}

	/**
	 * Returns camelcased string. This is useful for 
	 * deriving Apex field names using the sObject names.
	 *
	 * @param str String to convert.
	 *
	 * @return String in camelcase format.
	 */
	public static String toCamelCase(String str){
		String camelCaseString = '';
		String[] parts = str.split('_');
		for(String part : parts){
			String[] subParts = part.splitByCharacterTypeCamelCase();
			for(String subPart : subParts){
				camelCaseString += subPart.toLowerCase().capitalize();	
			}
		}
		return camelCaseString;
	}

	/**
	 * Returns datatype cast type for the given Schema.DisplayType.  
	 *
	 * @param dataType String Schema.DisplayType name.
	 *
	 * @return String.
	 */
	public static String getCastType(String dataType){
		Schema.DisplayType typ = null;
		for(Schema.DisplayType tempTyp : Schema.DisplayType.values()){
			if(tempTyp.name().equalsIgnoreCase(dataType)){
				typ = tempTyp;
				break;
			}
		}
		return getCastType(typ); 
	}

	/**
	 * Returns datatype cast type for the given Schema.DisplayType.  
	 *
	 * @param dataType Schema.DisplayType.
	 *
	 * @return String.
	 */
	public static String getCastType(Schema.DisplayType dataType){
		String typ = 'String';
		if(Schema.DisplayType.base64 == dataType){
			typ = 'Blob';
		}
		else if(Schema.DisplayType.Percent == dataType || Schema.DisplayType.Currency == dataType){
			typ = 'Double';
		}
		else if(CollectionContains(new Schema.DisplayType[] {Schema.DisplayType.Combobox, Schema.DisplayType.DataCategoryGroupReference,
				Schema.DisplayType.Email, Schema.DisplayType.EncryptedString, Schema.DisplayType.ID, Schema.DisplayType.ID, Schema.DisplayType.MultiPicklist, Schema.DisplayType.Phone,
				Schema.DisplayType.Picklist, Schema.DisplayType.Reference, Schema.DisplayType.TextArea, Schema.DisplayType.URL}, dataType)){
			typ = 'String';
		}
		else {
			typ = dataType.name();
		}
		return typ;
	}

	/**
	 * Converts given object value into string using the data type format.  
	 *
	 * @param ctx Context object.
	 * @param value Object to be converted.
	 * @param dataType Schema.DisplayType data type.
	 *
	 * @return String.
	 */
	public static String toString(Context ctx, Object value, Schema.DisplayType dataType){
		if(null == value){
			return null;
		}
		// TODO add more data types like phone  etc
		String str = null;
		if(CollectionContains(new Schema.DisplayType[] {Schema.DisplayType.anytype, Schema.DisplayType.Boolean, Schema.DisplayType.Double, Schema.DisplayType.Email,
				Schema.DisplayType.ID, Schema.DisplayType.Integer, Schema.DisplayType.Percent, Schema.DisplayType.Reference, Schema.DisplayType.String, Schema.DisplayType.TextArea}, dataType)){
			// just convert to string
			str = String.valueOf(value);	
		}
		else if(Schema.DisplayType.Date == dataType){
			str = formatDate((Date) value, ctx.lang);
		}
		else if(Schema.DisplayType.DateTime == dataType){
			str = formatToMST((DateTime) value);
		}
		else{
			str = String.valueOf(value);
		}
		return str;
	}

	/**
	 * Converts given string value into respective object type using the data type format.  
	 *
	 * @param ctx Context object.
	 * @param str String to be converted.
	 * @param dataType Schema.DisplayType data type.
	 *
	 * @return Object.
	 */
	public static Object fromString(Context ctx, String str, Schema.DisplayType dataType){
		// TODO add more data types like phone etc
		Object value = null;
		if(Schema.DisplayType.Boolean == dataType){
			value = CommonUtil.isTrue(str);
		}
		else if(Schema.DisplayType.Date == dataType){
			// TODO need to use lang to parse date properly
			value = toDate(str);
		}
		else if(Schema.DisplayType.Double == dataType || Schema.DisplayType.Percent == dataType || Schema.DisplayType.Currency == dataType){
			value = toDouble(str);
		}
		else if(Schema.DisplayType.Integer == dataType){
			value = toInteger(str);
		}
		else{
			value = str;
		}
		return value;
	}

	/**
	 * Replaces tokens in the passed in text with the token values. By default, anything that is inside a curyly brace {} is considered a token.
	 * <p>
	 * Example text : More Infomation About {0}
	  <p>
	 * Token vlaue : John
	 <p>
	 * Replaced text will be :  More Infomation About John
	 */
	public static String replaceTokens(String text, String[] tokenValues){
		Pattern regex = Pattern.compile('\\{(.*?)\\}');
		Matcher regexMatcher = regex.matcher(text);
		String[] tokens = new String[]{};
		while (regexMatcher.find()) {
			tokens.add(regexMatcher.group());
		}
		return replaceTokens(text, tokens, tokenValues);
	}

	/**
	 * Replaces tokens in the passed in text with the token values. Tokens can be anything like {0}, [0] "0".
	 * Recommended token format is {0}. Use replaceTokens(String text, String[] tokenValues) method.
	 * <p>
	 * Example text : More Infomation About [0]
	 <p>
	 * Token : [0]
	 <p>
	 * Token vlaue : John
	 <p>
	 * Replaced text will be :  More Infomation About John
	 */
	public static String replaceTokens(String text, String[] tokens, String[] tokenValues){
		for(Integer i=0; i<tokens.size() && i < tokenValues.size(); i++){
			text = text.replace(tokens[i], tokenValues[i]);
		}
		return text;
	}

	/**
	 * Returns a random number of noOfDigits length.
	 *
	 * @param noOfDigits Number of digits to be created.
	 *
	 * @return Integer value.
	 */
	public static Integer random(Integer noOfDigits){
		if(noOfDigits > 0){
			String lLimit = '';
			String uLimit = '';
			for(Integer i = 0; i < noOfDigits; i++){
				lLimit += '1';
				uLimit += '9';
			}
			Integer upper = Integer.valueOf(uLimit);
			Integer lower = Integer.valueOf(lLimit);
			return Math.round( (Math.random() * (upper - lower) )) + lower;
		}
		return null;
	}
	
	/**
	 * Returns the class name from the class instance.
	 * 
	 * @param obj Object 
	 * 
	 * @return String Class name of the object.
	 */
	public static String getClassName(Object obj){
		return obj == null ? 'null' : String.valueOf(obj).split(':')[0];
	}
	
	public static String stringQueryValue(String value){
		return String.escapeSingleQuotes(value);
	}
}