import module namespace ex = 'http://zorba.io/modules/info-extraction';

import schema namespace schema = 'http://zorba.io/modules/info-extraction';

let $result := ex:categories("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")

return count ( for $c in $result return validate { $c } ) > 0
    
(:

<?xml version="1.0" encoding="UTF-8"?>
<!-- The ex:categories function should return the following list of results for the input provided in the example -->
<ex:category xmlns:ex="http://zorba.io/modules/info-extraction">Politics &amp; Government</ex:category>
<ex:category xmlns:ex="http://zorba.io/modules/info-extraction">Budget, Tax &amp; Economy</ex:category>
<ex:category xmlns:ex="http://zorba.io/modules/info-extraction">Government</ex:category>

:)
