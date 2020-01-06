"use strict";

module.exports = async function (context, req) {

    try {
        const TextLintEngine = require('textlint').TextLintEngine; 
        const path = require('path');

        context.log('JavaScript HTTP trigger function processed a request.');

        context.log(req.body);

        const engine = new TextLintEngine({
            configFile: path.join(__dirname, '../textlint/.textlintrc')
        });

        let result = await engine.executeOnText(req.body.body)

        context.log(result[0].messages)
        
        context.res = {
            // status: 200, /* Defaults to 200 */
            body: result[0].messages
        };

    } catch (err){
        context.log(err.name + ': ' + err.message);
    }
};