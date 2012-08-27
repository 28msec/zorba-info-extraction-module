import module namespace ex = 'http://www.zorba-xquery.com/modules/info-extraction';

let $result := ex:entities("President Obama called Wednesday on Congress to extend a tax break for students included in last year's economic stimulus package, arguing that the policy provides more generous assistance.")
return if(count($result) >= 1)
    then 'Entities Found'
    else ()
    
(: Possible result 
<?xml version="1.0" encoding="UTF-8"?>
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="0" end="14">President Obama</ex:entity>
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="36" end="43">
  <ex:type>organization</ex:type>Congress</ex:entity>
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="57" end="65">tax break</ex:entity>
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="104" end="128">economic stimulus package</ex:entity>
<ex:entity xmlns:ex="http://www.zorba-xquery.com/modules/info-extraction" start="169" end="187">generous assistance</ex:entity>
:)

