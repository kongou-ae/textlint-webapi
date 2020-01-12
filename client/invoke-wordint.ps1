<#
.SYNOPSIS

This script validate your document by your Testlint REST API.

.DESCRIPTION

You need to configure your REST API of Textlint in $textLintEndpoint.
This script require the following response.

[
    {
        "type":  "lint",
        "ruleId":  "joyo-kanji",
        "message":  "「檸」は常用漢字ではありません。",
        "index":  0,
        "line":  1,
        "column":  1,
        "severity":  2
    },
    {
        "type":  "lint",
        "ruleId":  "ja-technical-writing/max-kanji-continuous-len",
        "message":  "漢字が7つ以上連続しています: 檸檬検証報告書",
        "index":  0,
        "line":  1,
        "column":  1,
        "severity":  2
    },
    {
        "type":  "lint",
        "ruleId":  "joyo-kanji",
        "message":  "「檬」は常用漢字ではありません。",
        "index":  1,
        "line":  1,
        "column":  2,
        "severity":  2
    }
]

.EXAMPLE

./invoke-wordlint.ps1 ./document.docx

#>

Param(
    [parameter(mandatory = $true)][String]$docx
)

$ErrorActionPreference = "stop"

#$textLintEndpoint = "http://localhost:7071/api/textlint"
$textLintEndpoint = "https://aimless-textlint.azurewebsites.net/api/textlint"

$html = @"
<html lang="ja"><head>
  <meta charset="utf-8">
  <title>The result of TextLint</title>
  <meta name="The result of TextLint" content="The HTML5 Herald">
  <link rel="stylesheet" href="report.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,300italic,700,700italic">
  <link rel="stylesheet" href="https://cdn.rawgit.com/necolas/normalize.css/master/normalize.css">
  <link rel="stylesheet" href="https://cdn.rawgit.com/milligram/milligram/master/dist/milligram.min.css">
  <style type="text/css">
  .row .column {
    border-left: thin solid gray;
    border-right: thin solid gray;
  }
</style>
</head>
<body>
<div class="container">
<h1>The result of TestLint</h1>
{result}
</div>
</body>
</html>
"@

function invoke-textlint {
    param (
        [parameter(mandatory = $true)][String]$sentence
    )

    $body = @{ body=$sentence} | ConvertTo-json
    $body = [System.Text.Encoding]::UTF8.GetBytes($body)

    $res = Invoke-RestMethod -Method POST -Uri $textLintEndpoint -Body $body

    return $res
}

function New-LintReport {

    $reports = get-content .\report.json | ConvertFrom-Json

    $reportHtml = ""
    $reports | ForEach-Object {

        if ($_.msg.length -gt 1){
            $reportHtml += "<div class='row'>`r`n"

            $msgHtml = ""
            $msg = $_.msg
            $msgHtml = "<div class='column'><div class='msg'><p>$msg</p></div></div>`r`n"
            $reportHtml += $msgHtml
    
            $resultHtml = "<div class='column'><div class='result'>`r`n"
            $results = $_.result
            if ($results.length -gt 1){
                $resultHtml += "<ul>`r`n"
                $results | ForEach-Object {
                    $result = $_
                    $resultHtml += "<li>$($result.column) : $($result.message)($($result.ruleId))</li>`r`n"
                }
                $resultHtml += "</ul>`r`n"
            }
    
            $resultHtml += "</div></div>`r`n"
            $reportHtml += $resultHtml
            $reportHtml += "</div>`r`n"
    
        }
    }

    $html.Replace("{result}",$reportHtml) | Out-File "report.html" -Force
    
}

$docPath = $(Get-ChildItem $docx).FullName
$pandoc = "$HOME" + "\AppData\Local\Pandoc\pandoc.exe" 
$argument = "$docPath -t markdown-raw_html-native_divs-native_spans --wrap=none -o tmp.md"

Invoke-Expression "$pandoc $argument"
$pandocResult = Get-content "tmp.md" -Encoding UTF8
Remove-item "tmp.md"

$report = New-Object System.Collections.ArrayList

$pandocResult | ForEach-Object {
    $count += 1
    $tmpReport = New-Object PSCustomObject
    [string]$sentence = $_
    $isSentence = $true
    $textlintResult = $Null

    # 文章が入っていない
    if ($sentence.Length -eq 0){
        $isSentence = $false
    }

    if ($isSentence -eq $true){
        $textlintResult = invoke-textlint $sentence
    }

    $tmpReport | Add-Member -NotePropertyMembers @{
        "msg" = $sentence
        "result" = $textlintResult
    }
    $report.Add($tmpReport) | Out-Null

    Write-Progress -Activity "Progress" -status "Linting..." -PercentComplete $([Math]::Ceiling($count / $pandocResult.Length * 100)) -CurrentOperation "$([Math]::Ceiling($count / $pandocResult.Length * 100)) %"
  
}

$report | ConvertTo-Json -Depth 100 | Out-File "report.json"
$report | ConvertTo-Html | out-file "report.html"

New-LintReport
Invoke-Item "report.html"