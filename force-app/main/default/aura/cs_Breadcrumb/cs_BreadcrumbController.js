({
    doInit: function (component, event, helper) {
        helper.doGetSetting(component);


        // Dynamic pathname
        let pathname = window.location.pathname;
        pathname = pathname.split('/')[1];
        if (pathname === "s") {
            pathname = "";
        } else {
            pathname = "/" + pathname;
        }
        component.set("v.pathname", pathname);
    },
});