import ballerina/http;
import ballerina/lang.runtime;
import ballerina/log;

service on new http:Listener(9090, timeout = 300, httpVersion = "1.1") {
    isolated resource function post code(http:Caller caller) {
        ServerResponseGen resp = new ServerResponseGen();
        stream<http:SseEvent, error?> streamResult = new stream<http:SseEvent, error?>(resp);
        http:Response res = new;
        res.setSseEventStream(streamResult);
        res.addHeader("Cache-Control", "no-cache");
        res.addHeader("X-Accel-Buffering", "no");
        http:ListenerError? respond = caller->respond(res);
        if respond is http:ListenerError {
            log:printInfo("fuck.");
        }
    }
}

isolated class ServerResponseGen {
    private int[] waitTimes = [120, 40, 10];

    public isolated function next() returns record {|http:SseEvent value;|}|error? {
        lock {
            int|error val = trap self.waitTimes.pop();
            if val is error {
                return ();
            }
            runtime:sleep(<decimal>val);
            return {
                value: {
                    data: val.toString()
                }
            };
        }
    }
}
