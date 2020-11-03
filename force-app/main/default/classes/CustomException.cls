/**
 * Custom exception for the application. Supports various exception types including validations.
 * CustomExceptions are handled gracefully to avoid VF page/Apex crash
 *
 * @author Rahman A
 * @date 08/20/2014
 * 
 */
public with sharing virtual class CustomException extends Exception {

	/** Exeption type enumeration values */
	public enum EXCEPTION_TYP { SYS, QL, DML, VALID, WS, TEST }

	/** Exception type */
	public EXCEPTION_TYP typ {get; set;}

	/** Exception code */
	public String code {get; set;}

	/** Exception message */
	public String message {get; set;}

	/** List of ValidationMessage. Applicable for EXCEPTION_TYP.VALID exceptions only. */
	public List<ValidationMessage> validationMessages {get; set;}

    
	/**
	 * Constructor.
	 * 
	 * @param typ CustomException.EXCEPTION_TYP 
	 * @param message String
	 */
	public CustomException(CustomException.EXCEPTION_TYP typ, String message){
		this(typ, message, null);	
	}

	/**
	 * Constructor.
	 * 
	 * @param typ CustomException.EXCEPTION_TYP 
	 * @param message String
	 * @param code String
	 */
	public CustomException(CustomException.EXCEPTION_TYP typ, String message, String code){
		this.typ = typ;
		this.message = message;
		this.code = code;
		if(EXCEPTION_TYP.VALID == this.typ){
			if(null == this.validationMessages){
				this.validationMessages = new List<ValidationMessage>();
			}
			this.validationMessages.add(new ValidationMessage(this.message, this.code));
		}
	}

	/**
	 * Constructor.
	 * 
	 * @param message String
	 * @param code String
	 * @param ex Exception
	 */
	public CustomException(String message, String code, Exception ex){
		this(EXCEPTION_TYP.SYS, message + ex.getMessage(), code);
	}

	/**
	 * Constructor.
	 * 
	 * @param validationMessages List of ValidationMessage
	 */
	public CustomException(List<ValidationMessage> validationMessages){
		this.typ = EXCEPTION_TYP.VALID;
		this.validationMessages = validationMessages;
	}

	/**
	 * Constructor.
	 * 
	 * @param validationMessage ValidationMessage
	 */
	public CustomException(ValidationMessage validationMessage){
		this(new ValidationMessage[] {validationMessage});
	}
	
	public String toString() {
		return toString(this);
	}

	/**
	 * Returns exception details in string format.
	 * 
	 * @param ex Exception to convert.
	 */
	public static String toString(Exception ex){
		String msg = '';
		if(ex instanceof CustomException){
			CustomException ce = (CustomException) ex;
			msg += ' Exception Type : ' + ce.typ;
			msg += '\nException Code : ' + (ce.code == null ? '' : ce.code);
			msg += '\nException Message : ' + ce.message;
		}
		msg += '\n' + ex.getMessage();
		msg += '\nException Cause : ' + ex.getCause();
		msg += '\nStack Trace : ' + ex.getStackTraceString();
		return msg;
	}

	/**
	 * Validates CustomException. Used for test methods only.
	 * 
	 * @param ce CustomException to check
	 * @param typ CustomException.EXCEPTION_TYP. Expected type in the CustomException.
	 * @param code String. Expected code in the CustomException.
	 */
	public static void assertValidException(CustomException ce, CustomException.EXCEPTION_TYP typ, String code){
		if(null != typ){
			System.assertEquals(typ, ce.typ, 'Exception type does not match');
			if(EXCEPTION_TYP.VALID == ce.typ && CommonUtil.isEmpty(ce.validationMessages)){
				System.assert(CommonUtil.isNotEmpty(ce.validationMessages), 'Validation Message is empty');
			}
		}
		if(null != code){
			System.assertEquals(code, ce.code, 'Exception code does not match');
		}
	}
}