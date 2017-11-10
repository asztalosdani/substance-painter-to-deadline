
function getPools(readyCallback, errorCallback) {
    sendRequest("/api/pools", readyCallback, errorCallback)
}

function getGroups(readyCallback, errorCallback) {
    sendRequest("/api/groups", readyCallback, errorCallback)
}

function getUser(username, readyCallback, errorCallback) {
    sendRequest("/api/users?Name=" + username, readyCallback, errorCallback)
}

function submitJob(jobInfo, pluginInfo, readyCallback, errorCallback) {
    var body = {JobInfo: jobInfo, PluginInfo: pluginInfo, AuxFiles: []}
    sendRequest("/api/jobs", readyCallback, errorCallback, "POST", body)
}

function sendRequest(path, readyCallback, errorCallback, method, body) {
    if (method === undefined) {
        method = "GET"
    }
    if (body == undefined) {
        body = null
    }
    if (errorCallback == undefined) {
        errorCallback = onError
    }
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4) {
            if (xhttp.status == 200) {
                var data = JSON.parse(xhttp.responseText);
                readyCallback(data)
            } else {
                errorCallback(xhttp.status, xhttp.responseText)
            }
        }
    };

    var host = alg.settings.value("Host")
    var port = alg.settings.value("Port")
    if (host.indexOf("http://") != 0) {
        host = "http://" + host
    }
    var url = host + ":" + port + path
    alg.log.info(url)
    xhttp.open(method, url, true);
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify(body));

    var timeout = setTimeout(onTimeout, 5000);
    function onTimeout() {
        xhttp.abort()
    }
}

function onError(status, response) {
    alg.log.error("Error occurred")
    alg.log.error("Status: " + status)
    alg.log.error("Response: " + response)
}