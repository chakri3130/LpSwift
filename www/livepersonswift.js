var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'livepersonswift', 'coolMethod', [arg0]);
};


exports.add = function (arg0, arg1, success, error) {
    exec(success, error, 'livepersonswift', 'add', [arg0, arg1]);
    };

exports.instantiateLPMessagingSDK = function(arg0,success, error){
        exec(success,error,'livepersonswift', 'instantiateLPMessagingSDK', [arg0] )
    }

exports.ConnectToBot = function (entryPoint_Environment,entryPoint_language,entryPoint,entryPoint_Country,success, error) {
        exec(success, error, 'livepersonswift', 'ConnectToBot', [entryPoint_Environment,entryPoint_language,entryPoint,entryPoint_Country]);
    };

    