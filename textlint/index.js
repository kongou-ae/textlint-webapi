"use strict";

module.exports = async function (context, req) {

    try {

        const TextLintCore = require('textlint').TextLintCore;
        const joyokanji = require('textlint-rule-joyo-kanji');
        const droppingSa = require('@textlint-ja/textlint-rule-no-insert-dropping-sa');
        const hiraganaFukushi = require('textlint-rule-ja-hiragana-fukushi');
        const hiraganaHojodoshi = require('textlint-rule-ja-hiragana-hojodoushi');
        const hiraganaKeishikiMeishi = require('textlint-rule-ja-hiragana-keishikimeishi');
        const noAbusage = require('textlint-rule-ja-no-abusage');
        const noRedundantExpression = require('textlint-rule-ja-no-redundant-expression');
        const noWeakPhrase = require('textlint-rule-ja-no-weak-phrase');
        const noDoubleNegative = require('textlint-rule-no-double-negative-ja');
        const noDoubleConjunction = require('textlint-rule-no-doubled-conjunction');
        const noDoubleConjunctiveGa = require('textlint-rule-no-doubled-conjunctive-particle-ga');
        const noDoubledJoshi = require('textlint-rule-no-doubled-joshi');
        const noDroppingRa = require('textlint-rule-no-dropping-the-ra');
        const noMixDearuDesumasu = require('textlint-rule-no-mix-dearu-desumasu');
        const noRenyoChushi = require('textlint-rule-no-renyo-chushi');
        const preferTariTari = require('textlint-rule-prefer-tari-tari');
        const presetJtfStyle = require('textlint-rule-preset-jtf-style');
        const singleNado = require('textlint-rule-single-nado');
        const technicalWriting = require('textlint-rule-preset-ja-technical-writing');

        context.log('JavaScript HTTP trigger function processed a request.');

        context.log(req.body);

        const core = new TextLintCore()
        core.setupRules({
            "joyo-kanji" : joyokanji,
            //"no-insert-dropping-sa" : droppingSa,
            "ja-hiragana-fukushi" : hiraganaFukushi,
            "ja-hiragana-hojodoushi" : hiraganaHojodoshi,
            "ja-hiragana-keishikimeishi" : hiraganaKeishikiMeishi,
            "ja-no-abusage" : noAbusage,
            "ja-no-redundant-expression" : noRedundantExpression,
            "ja-no-weak-phrase" : noWeakPhrase,
            "no-double-negative-ja" : noDoubleNegative,
            "no-doubled-conjunction" : noDoubleConjunction,
            //"no-doubled-conjunctive-particle-ga" : noDoubleConjunctiveGa,
            //"no-doubled-joshi" : noDoubledJoshi,
            "no-dropping-the-ra" : noDroppingRa,
            "no-mix-dearu-desumasu" : noMixDearuDesumasu,
            "no-renyo-chushi" : noRenyoChushi,
            "prefer-tari-tari" : preferTariTari,
            "preset-jtf-style" : presetJtfStyle,
            "single-nado" : singleNado,
            //"textlint-rule-preset-ja-technical-writing" : technicalWriting
            
        })

        let result = await core.lintMarkdown(req.body.body);
        context.log(result)
        
        context.res = {
            // status: 200, /* Defaults to 200 */
            body: result
        };

    } catch (err){
        context.log(err.name + ': ' + err.message);
    }
};