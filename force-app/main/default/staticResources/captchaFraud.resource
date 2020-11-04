<html>
        <head>
        <title>reCAPTCHA demo: Explicit render after an onload callback</title>
		<style>
		.ssp-captchaContainer{
			position: absolute;
			right: 0;
        }
		.ssp-captchaContainer > div {
            width: 273px !important;
			height: 78px;
        }
        .ssp-captchaContainer > div >div >iframe {
            border-radius: 3px;
			transform: scale(0.9);
			transform-origin: 0 0;
        }
		
		@media only screen and (max-width: 768px){
			.ssp-captchaContainer{
				position: absolute;
				left: 0;
			}
		}
		</style>
        <script type="text/javascript">

            var verifyCallback = function(response) {
                parent.postMessage("Unlock",window.location.href);
                //document.getElementById("myBtn").disabled = false;
            };
            
            var handleCaptchaExpired = function(response){
                parent.postMessage("Expired",window.location.href);
            };
            
            var onloadCallback = function() {
                grecaptcha.render('html_element', {
                  'sitekey' : '6LdUMuEUAAAAAP6NP5ZyQr50l2EgtKsazJTp2qgs', //reCaptcha V2 Site Key
                  'callback' : verifyCallback,
                  'expired-callback' : handleCaptchaExpired
                });
                parent.postMessage("Loaded",window.location.href);
            };
            
            //function myFunction() {
            //    console.log("CLICKED!!!!" );
            //}
            
        </script>
      </head>
      <body style="background:rgba(228,228,228,0)">
        <form action="?" method="POST">
          <div id="html_element" class="ssp-captchaContainer"></div>
            <br/>
            <input type="submit" value="Submit" style="display:none"/>
            <!--<button id="myBtn" onclick="myFunction()" disabled="true" class="slds-button slds-button_brand" >My Button</button>-->
        </form>
        <script src="https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit" async="" defer="">
        </script>
      </body>
    </html>