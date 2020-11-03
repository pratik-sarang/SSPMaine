/**
 * Button information. Used mostly in flow based pages for navigation buttons list. 
 *
 * @author Rahman A
 * @date 10/04/2013
 */
public with sharing class Button { 

    /** Button label */
    public String label {get; set;}
    
    /** <i>action code</i> value to be assigned to <b>action</b> variable in <i>StandardApplicationController</i> */
    public String action {get; set;}
    
    /** Onclick Javascript function name. Optional. */ 
    public String onClick {get; set;}
    
    /** CSS style example primary, secondary */
    public String style {get {if(null == this.style) { this.style = 'btn btn-secondary';} return this.style;} set;}
    
    /**
     * Flag to indicate if the button should execute only the Javascript function. If set to true then
     * the Apex Controller Action method will not be invoked.
     */
    public Boolean isJsOnly { get {if(null == this.isJsOnly) { this.isJsOnly = false;} return this.isJsOnly;} set; }
    
    /**
     * Constructor.
     */
    public Button(){
        this(null, null);
    }
    
    /**
     * Constructor.
     * 
     * @param label String Button label
     * @param action String Button action code
     */
    public Button(String label, String action){
        this.label = label;
        this.action = action;
    }
}