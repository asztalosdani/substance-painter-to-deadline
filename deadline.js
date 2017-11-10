
function getPools(readyCallback) {
    sendRequest("/api/pools", readyCallback)
}

function getGroups(readyCallback) {
    sendRequest("/api/groups", readyCallback)
}

function submitJob(jobInfo, pluginInfo, readyCallback) {
    var body = {JobInfo: jobInfo, PluginInfo: pluginInfo, AuxFiles: []}
    alg.log.info(body)
    sendRequest("/api/jobs", readyCallback, "POST", body)
}

function sendRequest(path, readyCallback, method, body) {
    if (method === undefined) {
        method = "GET"
    }
    if (body == undefined) {
        body = null
    }
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4) {
            if (xhttp.status == 200) {
                var data = JSON.parse(xhttp.responseText);
                readyCallback(data)
            } else {
                alg.log.error(xhttp.status)
                alg.log.error(xhttp.responseText)
            }
        }
    };

    var host = alg.settings.value("Host")
    var port = alg.settings.value("Port")
    alg.log.info(host)
    alg.log.info(typeof host)
    if (host.indexOf("http://") != 0) {
        host = "http://" + host
    }
    var url = host + ":" + port + path
    alg.log.info(url)
    xhttp.open(method, url, true);
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify(body));
}