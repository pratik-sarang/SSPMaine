/**
 * Represents a validation message.
 *
 * @author Rahman A
 * @date 08/20/2014
 */
public with sharing class ValidationMessage {

	/** Message to be displayed in the page */
	public String message {get; set;}

	/** Message code. Optional. */
	public String code {get; set;}

	/** Field name. Optional. Used to highlight the field in the page. */
	public String fieldName {get; set;}

	/** Fields's row number in the tablegrid. Optional. Used to highlight the field in the page. */
	public String rowNum {get; set;}

	/**
	 * Constructor.
	 * 
	 * @param message String
	 */
	public ValidationMessage(String message){
		this(message, null, null);
	}

	/**
	 * Constructor.
	 * 
	 * @param message String
	 * @param code String
	 */
	public ValidationMessage(String message, String code){
		this(message, code, null);
	}

	/**
	 * Constructor.
	 * 
	 * @param message String
	 * @param code String
	 * @param fieldName String
	 */
	public ValidationMessage(String message, String code, String fieldName){
		this(message, code, fieldName, null);
	}

	/**
	 * Constructor.
	 * 
	 * @param message String
	 * @param code String
	 * @param fieldName String
	 * @param rowNum String
	 */
	public ValidationMessage(String message, String code, String fieldName, String rowNum){
		this.message = message;
		this.code = code;
		this.fieldName = fieldName;
		this.rowNum = rowNum;
	}
}