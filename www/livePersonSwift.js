var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'livePersonSwift', 'coolMethod', [arg0]);
};


exports.add = function (arg0, arg1, success, error) {
    exec(success, error, 'livePersonSwift', 'add', [arg0, arg1]);
    };
