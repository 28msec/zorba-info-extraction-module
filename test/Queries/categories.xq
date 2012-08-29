import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

import schema namespace schema = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:categories("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")

let $validated := for $e in $result return validate { $e }

return count ( $validated ) > 0
    
(:

<?xml version="1.0" encoding="UTF-8"?>
<!-- The ex:categories function should return the following list of results for the input provided in the example -->
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Politics &amp; Government</ex:category>
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Budget, Tax &amp; Economy</ex:category>
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Government</ex:category>

:)
