({
	backToReportPicklist : function() {
		var optionSelected=window.location.pathname.split('/s/')[1].replace(/-/g, ' ');
        var splitOptionSelected=optionSelected.split("/");
        var url;
        var url_string = window.location.href;
        var wndurl = new URL(url_string);
        var isReport = wndurl.searchParams.get("isReport");

        if(isReport === 'true'){
            url='report';
        }
        if(isReport !== 'true'){
            url='referraldashboard';
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+url
        });
        urlEvent.fire();
       

	}
})