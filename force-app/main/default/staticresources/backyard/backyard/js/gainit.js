
///Invoking the the Cookie Alert Prompt
function initCookieAlert() {
    try {
        if (sessionStorage) {
            if (sessionStorage.getItem("userGaConsent") == null) {
                $(document).ready(function () {
                    setTimeout(function () {
                        showCookieMessage();
                    }, 3000);
                });
            }
            if (sessionStorage.getItem("userGaConsent") == "Accept") {
                initGA(); 
            }
        }
    } catch (error) {
        console.log('GA is not initialized...');
    }
}
// Display the Cookie pop message and Accept button
function showCookieMessage() {
     var GaText = "This website uses cookies. Read more with the privacy policy";
               var policylink = '<a href="privacy-policy?" target="_blank" style="font-weight:bold; border-bottom: 1px solid #ffffff; color: #ffffff;">here.</a>';
               var msg = GaText + policylink;
     var msgPos = $("span.dd-ga-cookie-message").data("gacustom-label");
               var accept = $("span.dd-ga-cookie-message").data("ga-cookie-accept");
    if (msgPos.length) {
        msg = msgPos;
     } 
        var htmlStr = '<div class="dd-cookie-message"> \
                        <div class="slds-notify_container slds-is-fixed" style="pointer-events:none;opacity:.90;background-color:#0075DB;top:auto;bottom:0;"> \
                            <div class="slds-notify slds-notify_alert" style="pointer-events:visible;min-width: 10rem;background-color:#0075DB;" role="status"> \
                                <div class="slds-notify__content"> \
                                                                                                         <div class="slds-text-heading_medium " style="padding-bottom:10px; padding-top:10px; background-color: #0075DB;"> '+msg+' <button class="slds-button  slds-button_neutral dd-cookie-btn-accept"  style="background-color: white; margin-left:30px" onclick="setUserGaConsent(\'Accept\');">'+accept+'</button>\
                                    </div> \
                                </div> \
                            </div> \
                        </div> \
                    </div> \
                    </div>';
        $(htmlStr).hide().appendTo("body").fadeIn(1000);
}

//capturing the user consent responds 
function setUserGaConsent(btnclicked) {
    if (btnclicked == "Accept") {
        initGA();
        sessionStorage.setItem("userGaConsent", btnclicked);
    } else if (btnclicked == "Decline") {
        sessionStorage.setItem("userGaConsent", btnclicked);
    }
    hideCookieMessage();
}
// Hide the Popup
function hideCookieMessage(){
    $(".dd-cookie-message").hide().fadeOut(1000);
}
//Init GA 
function initGA() {
    $(document).ready(function () {
        // attach Connect event
        $(document).on("click", "button.dd-ga-btn-resource-connect", function () {
            trackResourceGA($(this), 'connect');
        });
        // attach MycartConnect event
        $(document).on("click", "button.dd-ga-btn-resource-mycart-connect", function () {
            trackResourceGA($(this), 'mycart-connect');
        });

        // attach Frequently-Paired Connect event
        $(document).on("click", "button.dd-ga-btn-frequently-paired-connect", function () {
            trackResourceGA($(this), 'frequently-paired-connect');
        });
		
		// attach Assessment-results-connect event
        $(document).on("click", "button.dd-ga-btn-assessment-results-connect", function () {
            trackResourceGA($(this), 'assessment-results-connect');
        });
		
		// attach Related Services Connect event
        $(document).on("click", "button.dd-ga-btn-related-services-Connect", function () {
            trackResourceGA($(this), 'related-services-Connect');
        });
		
		 // attach Patner Releated Resource Refer event
        $(document).on("click", "button.dd-ga-btn-frequently-paired-refer", function () {
            trackResourceGA($(this), 'frequently-paired-refer');
        });
		
		 // attach Patner Releated Resource Refer event
        $(document).on("click", "button.dd-ga-btn-related-services-refer", function () {
            trackResourceGA($(this), 'related-services-refer');
        });
		
        // attach Share event
        $(document).on("click", "button.dd-ga-btn-resource-share", function () {
            trackResourceGA($(this), 'share');
        });

        // attach Expand event
        $(document).on("click", "div.dd-ga-btn-resource-expand-resource", function () {
            trackResourceGA($(this), 'expand-view');
        });

        // attach Remove event
        $(document).on("click", "button.dd-ga-btn-resource-remove", function () {
            trackResourceGA($(this), 'remove');
        });

        // attach Rate event
        $(document).on("click", "button.dd-ga-btn-resource-rate", function () {
            trackResourceGA($(this), 'rate');
        });

        // attach NoThanks event
        $(document).on("click", "button.dd-ga-btn-resource-no-thanks", function () {
            trackResourceGA($(this), 'suggested-no-thanks');
        });

        // attach Patner Refer event
        $(document).on("click", "button.dd-ga-btn-resource-refer", function () {
            trackResourceGA($(this), 'refer');
        });

       
        // attach Patner AddFavorite event
        $(document).on("click", "div.dd-ga-btn-resource-myfav", function () {
            trackResourceGA($(this), 'add-favorite');
        });

        // attach Resource Link event for search		
		$(document).on("click", "a.dd-ga-btn-resource-link-search", function () {
            trackResourceGA($(this), 'View-resource-link-search');
        });

		// attach Resource Link event for archetype	
		$(document).on("click", "a.dd-ga-btn-resource-link-archetype", function () {
            trackResourceGA($(this), 'View-resource-link-archetype');
        });
		
		// attach Resource Link event for My Plan	
		$(document).on("click", "a.dd-ga-btn-resource-link-my-plan", function () {
            trackResourceGA($(this), 'View-resource-link-my-Plan');
        });
		
		// attach Resource Link event for My Favorites	
		$(document).on("click", "a.dd-ga-btn-resource-link-my-favorites", function () {
            trackResourceGA($(this), 'View-resource-link-my-favorites');
        });
		
		// attach Resource Link event for Assessment Results	
		$(document).on("click", "a.dd-ga-btn-resource-link-assessment-results", function () {
            trackResourceGA($(this), 'View-resource-link-assessment-results');
        });
			
       // attach Resource Link event for Frequently Paired Together
		$(document).on("click", "a.dd-ga-btn-resource-link-frequently-paired", function () {
            trackResourceGA($(this), 'View-resource-link-frequently-paired');
        });	
       // attach Resource Link event for Related Services
		$(document).on("click", "a.dd-ga-btn-resource-link-related-services", function () {
            trackResourceGA($(this), 'View-resource-link-related-services');
        });	
		
        //Searchkey and Results
        var pageurl = document.location.href;
        if (pageurl.indexOf('searchkey') > 0) {
            $("#planCardSection search-results-cards").on("load", "div.dd-ga-p-search-results-count", setTimeout(function () {
                trackSearchkeyGA($(this), 'searchkey');
            }, 15000));
        }

        // attach sub Arche type event
        $(document).on("click", "button.dd-ga-btn-sub-archetype", function () {
            trackSearchCategoryGA($(this), 'sub-archetype');
        });

        //updated zipcode and Arche type
        $(document).on("keypress", "lightning-input.dd-ga-zipcode-arche-type", function (e) {
            if (e.which === 13) {
                trackResourceGA($(this), 'sub-archetype');
            }
        });

        //   attach Search-By-Category type event 
        $(document.body).on("mouseover","ul.dd-ga-ul-menu-subcatg-type li", function(){
         	 $(this).click(function(){
                 trackSearchCategoryGA($(this), 'Search-By-Category', $(this).data("value"),$(this).data("parent"),$(this).data("domain"));
             });
      });
	     // attach CLient ID event
	  onElementInserted('body', '.dd-ga-client-Id-container', function(element) {
        trackClientdetailsGA(element, 'view-Client-Id');
      });
	});	
}
//function to capture the data and push to GA using Data layer 
function trackResourceGA(src, axn) {
    var parentContainer = src.parents("div.dd-resource-list-item-container");
    var resName = parentContainer.data("resource-name");
    var subarchetype = parentContainer.data("sub-arche");
    var zipcode = parentContainer.data("zipcode");
    var resId = parentContainer.data("resource-id");
    var usertype = $("span.dd-ga-sf-usertype").data("sf-usertype");
    var sf_unique_userid = (usertype == ' Guest' ? generateGuestId() : $A.get("$SObjectType.CurrentUser.Id"));

    dataLayer.push(
        {
            'sf_unique_userid': sf_unique_userid,
            'tracking_category': 'resource',
            'resource_name': resName,
            'resource_id': resId,
            'subarchetype': subarchetype,
            'zipcode': zipcode,
            'user_action': axn,
            'sf_user_type': usertype,
            'event': 'BacKYard Resources Event'
        }
    );
}
//function to capture the data and push to GA using Data layer 
function trackClientdetailsGA(src, axn) {
    var clientid = $(src).data("clientid");
    var usertype = $("span.dd-ga-sf-usertype").data("sf-usertype");
    var sf_unique_userid = (usertype == ' Guest' ? generateGuestId() : $A.get("$SObjectType.CurrentUser.Id"));
    dataLayer.push(
        {
            'sf_unique_userid': sf_unique_userid,
            'tracking_category': 'ClientId',
            'client_Id': clientid,
            'user_action': axn,
            'sf_user_type': usertype,
            'event': 'BacKYard client Id Event'
        }
    );
}
function onElementInserted(containerSelector, elementSelector, callback) {
    var onMutationsObserved = function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.addedNodes.length) {
                var elements = $(mutation.addedNodes).find(elementSelector);
                for (var i = 0, len = elements.length; i < len; i++) {
                    callback(elements[i]);
                }
            }
        });
    };

    var target = $(containerSelector)[0];
    var config = { childList: true, subtree: true };
    var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
    var observer = new MutationObserver(onMutationsObserved);    
    observer.observe(target, config);

}

//function to capture the data and push to GA using Data layer 
function trackSearchkeyGA(src, axn) {
    var parentContainer = $("div.dd-ga-p-search-results-count");
    var resultsize = parentContainer.data("result-count");
    var searchkey = parentContainer.data("search-key");
    var usertype = $("span.dd-ga-sf-usertype").data("sf-usertype");
    var sf_unique_userid = (usertype == ' Guest' ? generateGuestId() : $A.get("$SObjectType.CurrentUser.Id"));
    dataLayer.push(
        {
            'sf_user_type': usertype,
            'sf_unique_userid': sf_unique_userid,
            'tracking_category': 'search',
            'searchkey': searchkey,
            'resultsize': resultsize,
            'user_action': axn,
            'event': 'BacKYard search Event'
        }
    );
}
//function to capture the data and push to GA using Data layer 
function trackSearchCategoryGA(src, axn, val, par, dom) {
    var parentContainer = $("div.dd-subarchtype-list-item-container");
    var subarchetype = parentContainer.data("sub-arche");
    var zipcode = parentContainer.data("zipcode");
    var usertype = $("span.dd-ga-sf-usertype").data("sf-usertype");
    var sf_unique_userid = (usertype == ' Guest' ? generateGuestId() : $A.get("$SObjectType.CurrentUser.Id"));
    var domain = dom;
    var parentcategory = par;
    var subcategory = val;
    dataLayer.push(
        {
            'sf_user_type': usertype,
            'sf_unique_userid': sf_unique_userid,
            'tracking_category': 'resource',
            'subarchetype': subarchetype,
            'zipcode': zipcode,
            'domain': domain,
            'parentcategory': parentcategory,
            'subcategory': subcategory,
            'user_action': axn,
            'event': 'BacKYard Resources Event'
        }
    );
}
//to generate the Guest unquie id 
function generateGuestId() {
    return "Guestuser";
}
