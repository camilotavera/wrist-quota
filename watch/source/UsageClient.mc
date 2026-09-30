import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;

class UsageClient {
    private var _callback;

    function initialize() {
        _callback = null;
    }

    function fetch(callback) {
        if (_callback != null) {
            return;
        }
        _callback = callback;

        if (Application.Properties.getValue("demoMode") == true) {
            complete(FixtureData.make(), null);
            return;
        }

        var endpoint = Application.Properties.getValue("usageEndpoint");
        if (!(endpoint instanceof Lang.String) || endpoint.find("https://") != 0) {
            complete(null, "Configure HTTPS endpoint");
            return;
        }

        var headers = {
            "Accept" => "application/json"
        };
        var token = Application.Properties.getValue("accessToken");
        if (token instanceof Lang.String && token.length() > 0) {
            headers["Authorization"] = "Bearer " + token;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(endpoint, null, options, method(:onResponse));
    }

    function onResponse(responseCode as Number, data as Dictionary or String or Null) as Void {
        if (_callback == null) {
            return;
        }
        if (responseCode == 200) {
            if (UsageData.isValid(data)) {
                complete(data, null);
            } else {
                complete(null, "Invalid usage data");
            }
            return;
        }

        complete(null, "Request failed " + responseCode.format("%d"));
    }

    private function complete(data, error) {
        var callback = _callback;
        _callback = null;
        callback.invoke(data, error);
    }
}
