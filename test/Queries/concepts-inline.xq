import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:concepts-inline("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")

return count($result) > 0


(:

<?xml version="1.0" encoding="UTF-8"?>
<!-- The ex:concepts-inline function should return the following list of results for the input provided in the example -->
President Obama called Wednesday on <concept start="36" end="43" url="http://en.wikipedia.com/wiki/United_States_Congress">Congress</concept> to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.

:)
