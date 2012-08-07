xquery version "3.0";

(:
 : Copyright 2006-2009 The FLWOR Foundation.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)
 
(:~
 : This library module provides data extraction functions that return a list  
 : of entities, relations, categories and concepts present in a given text.
 :
 : @author Pedro Antunes
 : @project information extraction
 :)

module namespace ex = "http://www.zorba-xquery.com/modules/info-extraction";

declare namespace ann = "http://www.zorba-xquery.com/annotations";

declare namespace yahoo = "urn:yahoo:cap";

import module namespace http = "http://www.zorba-xquery.com/modules/http-client";

import schema namespace h = "http://expath.org/ns/http-client";

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of entities 
 : encountered in the xml or text supplied as input.
 : See http://developer.yahoo.com/search/content/V2/contentAnalysis.html for more information.
 :
 : @param $text XML entity or a string to be analyzed
 : @return XML document with a list of entities recognized
 : @example test/Queries/entities.xq
 :)
declare %ann:sequential function ex:entities($text as xs:string) as element(ex:entity)*{
    let $response := ex:server-connection($text)
    let $entities := $response/query/results/yahoo:entities/yahoo:entity
    return if($entities) then
        for $entity in $entities            
        order by xs:integer($entity/yahoo:text/@start)
        return <ex:entity start="{$entity/yahoo:text/@start}" end="{$entity/yahoo:text/@end}">{
		if ($entity/yahoo:types) then
		for $type in $entity/yahoo:types/yahoo:type
		return <ex:type> {tokenize($type/text(), '^/|^[a-zA-Z]*:/')[2]} </ex:type>
		else ()
	} {$entity/yahoo:text/text()} </ex:entity>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of categories (topics) related
 : to the xml or text supplied as input.
 : See http://developer.yahoo.com/search/content/V2/contentAnalysis.html for more information.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of categories recognized
 : @example test/Queries/categories.xq
 :)
declare %ann:sequential function ex:categories($text) as element(ex:category)*{
    let $response := ex:server-connection($text)
    let $categories := $response/query/results/yahoo:yctCategories/yahoo:yctCategory
    return if ($categories) then 
        for $category in $categories
        return <ex:category> {$category/text()} </ex:category>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of relations (entities found and related wikipedia links)
 : encountered in the xml or text supplied as input.
 : See http://developer.yahoo.com/search/content/V2/contentAnalysis.html for more information.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of relations recognized
 : @example test/Queries/relations.xq
 :)
declare %ann:sequential function ex:relations($text) as element(ex:relation)*{
    let $response := ex:server-connection($text)
    let $relations := $response/query/results/yahoo:entities/yahoo:entity/yahoo:related_entities
    return if ($relations) then
        for $relation in $relations
        return <ex:relation>{
            <ex:entity start="{$relation/../yahoo:text/@start}" end="{$relation/../yahoo:text/@end}"> {
            	if($relation/../yahoo:types) then
            	for $type in $relation/../yahoo:types/yahoo:type
		return <ex:type> {tokenize($type/text(), '^/|^[a-zA-Z]*:/')[2]} </ex:type>
		else ()
            } {$relation/../yahoo:text/text()} </ex:entity>
            union
            (for $link in $relation/yahoo:wikipedia/yahoo:wiki_url
            return <ex:wikipedia_url>{$link/text()}</ex:wikipedia_url>)
        }</ex:relation>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of concepts (entity found and the corresponding wikipedia link) 
 : encountered in the xml or text supplied as input.
 : See http://developer.yahoo.com/search/content/V2/contentAnalysis.html for more information.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of concepts recognized
 : @example test/Queries/concepts.xq
 :)
declare %ann:sequential function ex:concepts($text) as element(ex:concept)*{
    let $response := ex:server-connection($text)
    let $concepts := $response/query/results/yahoo:entities/yahoo:entity/yahoo:wiki_url
    return if ($concepts) then
        for $link in $concepts
        order by xs:integer($link/../yahoo:text/@start)
        return <ex:concept>{
            <ex:entity start="{$link/../yahoo:text/@start}" end="{$link/../yahoo:text/@end}">{
            	if($link/../yahoo:types) then
            	for $type in $link/../yahoo:types/yahoo:type
            	return <ex:type> {tokenize($type/text(), '^/|^[a-zA-Z]*:/')[2]} </ex:type>
		else ()
            } {$link/../yahoo:text/text()} </ex:entity>
            union 
            (<ex:wikipedia_url>{$link[1]/text()}</ex:wikipedia_url>)
        }</ex:concept>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return the text supplied as input
 : together with entities recognized as xml elements as annotations in the text.
 :
 : @param $text XML entity or a string to be analyzed
 : @return XML document with a list of entities recognized
 : @example test/Queries/entities-inline.xq
 :)
declare %ann:sequential function ex:entities-inline($text){
   ex:entity-inline-annotation($text , ex:entities($text), 0)
};

(:~
 : Uses Yahoo's Content Analysis webservice to return the text supplied as input
 : together with concepts (entities with corresponding wikipedia link) recognized as xml elements as annotations in the text.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of concepts recognized
 : @example test/Queries/concepts-inline.xq
 :)
declare %ann:sequential function ex:concepts-inline($text){
   ex:concept-inline-annotation($text , ex:concepts($text), 0)
};

(:~
 : Creates entities inline annotations in a given string
 :
 : @param $text XML document or string to be analyzed
 : @param $entities list of entities found in the given string
 : @param $size size of the remaining string
 : @return XML document with a list of entities recognized
 :)
declare %private function ex:entity-inline-annotation($text, $entities, $size){
    if(count($entities)=0) then $text 
    else(substring($text, 0, ($entities[1]/@start) +1 -$size), 
        if($entities[1]/ex:type) then
        <ex:entity start="{$entities[1]/@start}" end="{$entities[1]/@end}" type="{$entities[1]/ex:type[1]}"> {$entities[1]/text()} </ex:entity>
        else $entities[1],
        ex:entity-inline-annotation(substring($text, ($entities[1]/@end)+2 -$size), $entities[position() >1], ($entities[1]/@end)+1))
};

(:~
 : Creates concepts inline annotations in a given string
 :
 : @param $text XML document or string to be analyzed
 : @param $concepts list of concepts found in the given string
 : @param $size size of the remaining string
 : @return XML document with a list of concepts recognized
 :)
declare %private function ex:concept-inline-annotation($text, $concepts, $size){
    if(count($concepts)=0) then $text 
    else(substring($text, 0, ($concepts[1]/ex:entity/@start) +1 -$size),
        if ($concepts[1]/ex:wikipedia_url) then
        <entity start="{$concepts[1]/ex:entity/@start}" end="{$concepts[1]/ex:entity/@end}" url="{$concepts[1]/ex:wikipedia_url/text()}">{$concepts[1]/ex:entity/text()}</entity>
        else $concepts[1]/ex:entity,
        ex:concept-inline-annotation(substring($text, ($concepts[1]/ex:entity/@end) +2 -$size), $concepts[position() >1], ($concepts[1]/ex:entity/@end) +1))
};

(:~
 : Establishes connection with the Yahoo Server
 :
 : @param $text XML document or string to be analyzed
 : @return XML document returned by the Yahoo Server
 :)
declare %private %ann:sequential function ex:server-connection($text as xs:string){
   let $uri := iri-to-uri(concat("q=select * from contentanalysis.analyze where text=", 
      concat("&quot;", concat(replace(normalize-space($text), "&quot;", "&apos;"), "&quot;"))))
   let $req := 
      <h:request method="POST" href="http://query.yahooapis.com/v1/public/yql">
         <h:header name="Connection" value="keep-alive"/>
         <h:body media-type="application/x-www-form-urlencoded">
         {$uri}
         </h:body>
      </h:request>
    let $response := http:send-request($req, (), ())
    return if ($response[1]/@status = 200)
    	then $response[2]
    	else ()
};
