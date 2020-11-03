({
    doInit : function(){
        var path = window.location.href;
        sessionStorage.setItem("retUrl", path);
        setTimeout(function(){//JAWS Fix
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },1000);
    },
    moveFocusToTop: function(component, event) {//JAWS Fix
        if(event.keyCode === 9) {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10);
        }else if(event.keyCode === 32 || event.keyCode === 13){
            document.getElementsByClassName("login-btn")[0].click();
        }
    },
    closeCartLogin : function(component) {
        component.set("v.cartLogin",false);
    },
    gotoLogin : function () {
        window.location = $A.get("$Label.c.loginurl");
    },
    navigateToRegistration : function(component, event, helper) {
        var navigate = 'Registration';
        helper.getKogURL(component, event, helper,navigate);
    }
})