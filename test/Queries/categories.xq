import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:categories("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")
return if(count($result) >= 1)
    then 'Categories Found'
    else ()
    
(: Possible Result
<?xml version="1.0" encoding="UTF-8"?>
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Politics &amp; Government</ex:category>
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Budget, Tax &amp; Economy</ex:category>
<ex:category xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">Government</ex:category>
:)
