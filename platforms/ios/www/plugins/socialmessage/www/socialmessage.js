cordova.define("socialmessage.SocialMessage", function(require, exports, module) {
var exec = require("cordova/exec");

var SocialMessage = function () {
    this.name = "SocialMessage";
};

var allActivityTypes = ["PostToFacebook", "PostToTwitter", "PostToWeibo", "Message", "Mail", "Print", "CopyToPasteboard", "AssignToContact", "SaveToCameraRoll"];

SocialMessage.prototype.send = function (message) {
    if (!message) {
        return;
    }
    if (typeof (message.activityTypes) === "undefined" || message.activityTypes === null || message.activityTypes.length === 0) {
        message.activityTypes = allActivityTypes;
    }
    message.activityTypes = message.activityTypes.join(",");
    exec(null, null, "SocialMessage", "send", [message]);
};

module.exports = new SocialMessage();
});
