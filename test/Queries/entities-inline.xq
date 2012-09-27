import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:entities-inline("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")

return count($result) > 0

(:

<?xml version="1.0" encoding="UTF-8"?>
<!-- The ex:entities-inline function should return the following list of results for the input provided in the example -->
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="0" end="14">President Obama</ex:entity> called Wednesday on <ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="36" end="43" type="organization">Congress</ex:entity> to extend a <ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="57" end="65">tax break</ex:entity> for students included in last year's <ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="104" end="128">economic stimulus package</ex:entity>, arguing that the policy provides more <ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="169" end="187">generous assistance</ex:entity>.

:)
