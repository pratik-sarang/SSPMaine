/**
 * Interface for workflow navigation rule. Contains methods to dynamically determine
 * if page needs to be queued or removed from the flow.
 *
 * @author Rahman A
 * @date 09/24/2014
 *
 * @see NavFlowRule
 * @see NavFlowRulesEngine
 *
 */
public virtual with sharing class BasicNavFlowRule implements NavFlowRule {

    /**
     * Invoked on workflow "next" action. If true is returned then the page will be marked as "required" in the
     * current flow and so it will be queued to be loaded on its turn. If false is returned then the page
     * will be marked as "not required" and hence will not be loaded in the flow.
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */
    public virtual boolean isRequired(Context ctx, ContextData ctxData){
        return true;
    }

    /**
     * Invoked on workflow "next" action. This method will be called for the current page from where "next" action is being invoked.
     * If true is returned then the page will be marked as "completed" in the
     * current flow. Else, the page status is retained as "required".
     * <p> 
     * This page can also be used in "multi-part" pages i.e., same page is loaded for different datasets.
     * <p>
     * Example : To capture a household member information, same page can be loaded mulitple times to capture different individual information.
     * For these type of pages, this method can be return false until all the individual are iterated. After capturing the final individual's information
     * the rule can return true and hence the next page can be loaded.
     * <p>
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */
    public virtual boolean isCompleted(Context ctx, ContextData ctxData){
        return true;
    }

    /**
     * Invoked on workflow "back" action. This method is useful for the page which is a "multi-part" i.e., same page is loaded for different datasets.
     * <p>
     * Example : To capture a household member information, same page can be loaded mulitple times to capture different individual information.
     * <p>
     * For these type of pages, this method can be used to determine if all the datasets are iterated and can be moved to next(previsous) page.
     * <p>
     * NOTE : Currenty, this method is not used. 
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */
    public virtual boolean isFirstRecord(Context ctx, ContextData ctxData){
        return true;
    }
}