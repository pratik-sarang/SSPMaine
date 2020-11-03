/*
 * Component Name: JsonFormRichText
 * Author: Narapa 
 * Description: Component to generate the field element of the type involving Lightning
 *              rich text
 * Date: 05/27/2020.
 */
import { track } from "lwc";
import { JsonFormField } from "c/jsonFormField";

export default class JsonFormRichText extends JsonFormField {
    @track eligResult;

    connectedCallback () {
        this.parentConnectedCallback();
        this.eligResult = this.fieldLayout.eligResult
            ? this.fieldLayout.eligResult
            : null;
        this.eligResult = this.formData[this.eligResult];
    }

    //To find if the field subType is noticeCard
    get isNoticeCard (){
        return "noticeCard" == this.subType;
    }

    //To find if the field subType is formattedText
    get isFormattedText () {
        return "formattedText" == this.subType;
    }

    //To find if the field subType is formattedText
    get isFormattedIconText () {
        return "formattedIconText" == this.subType;
    }

    //To find if the field subType is formattedText
    get isResultCard () {
        return "resultCard" == this.subType;
    }
}