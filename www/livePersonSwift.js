var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'livepersonswift', 'coolMethod', [arg0]);
};


exports.add = function (arg0, arg1, success, error) {
    exec(success, error, 'livepersonswift', 'add', [arg0, arg1]);
    };
