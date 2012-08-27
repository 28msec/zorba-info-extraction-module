import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:concepts("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")
return if(count($result) >= 1)
    then 'Concepts Found'
    else ()
    
(: Possible Result
<?xml version="1.0" encoding="UTF-8"?>
<ex:concept xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">
  <ex:entity start="0" end="14">President Obama</ex:entity>
  <ex:wikipedia_url>http://en.wikipedia.com/wiki/Barack_Obama</ex:wikipedia_url>
</ex:concept>
<ex:concept xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction">
  <ex:entity start="36" end="43">
    <ex:type>organization</ex:type>Congress</ex:entity>
  <ex:wikipedia_url>http://en.wikipedia.com/wiki/United_States_Congress</ex:wikipedia_url>
</ex:concept>
:)
