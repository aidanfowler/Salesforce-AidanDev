({
    doGetSetting: function (component) {
        if ($A.util.isEmpty(component.get('v.urlName'))) {
            return;
        }

        const action = component.get('c.doGetSetting');
        action.setParams({ url: component.get('v.urlName') });
        console.log('component.get(v.urlName) => ', JSON.parse(JSON.stringify(component.get('v.urlName'))));

        action.setCallback(this, (response) => {
            console.log('response.getReturnValue() => ', response.getReturnValue());
            console.log('response.getReturnValue() => ', JSON.parse(JSON.stringify(response.getReturnValue())));
            if (response.getState() === 'SUCCESS') {
                component.set('v.articleDetail', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
});