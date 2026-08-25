import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

class UsageClient {
    private var _callback;

    function initialize() {
        _callback = null;
    }

    function fetch(callback) {
        _callback = callback;

        if (Application.Properties.getValue("demoMode") == true) {
            _callback.invoke(FixtureData.make(), null);
            return;
        }

        var endpoint = Application.Properties.getValue("usageEndpoint");
        if (!(endpoint instanceof Lang.String) || endpoint.size() == 0) {
            _callback.invoke(null, "Configure endpoint");
            return;
        }

        var headers = {
            "Accept" => "application/json"
        };
        var token = Application.Properties.getValue("accessToken");
        if (token instanceof Lang.String && token.size() > 0) {
            headers["Authorization"] = "Bearer " + token;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(endpoint, null, options, method(:onResponse));
    }

    function onResponse(responseCode, data) {
        if (responseCode == 200 && data instanceof Lang.Dictionary) {
            _callback.invoke(data, null);
            return;
        }

        _callback.invoke(null, "Request failed " + responseCode.format("%d"));
    }
}
