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

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of entities 
 : encountered in the xml or text supplied as input.
 :
 : @param $text XML entity or a string to be analyzed
 : @return XML document with a list of entities recognized
 : @example test/Queries/entities.xq
 :)
declare %ann:sequential function ex:entities($text as xs:string){
    let $uri := concat("http://query.yahooapis.com/v1/public/yql?q=", 
        encode-for-uri(concat("select * from contentanalysis.analyze where text=", concat('"', concat($text, '"')))))
    let $response := http:post($uri,"")[2]
    let $entities := $response/query/results/yahoo:entities/yahoo:entity
    return if($entities) then
        for $entity in $entities
        let $type := 
            for $type in $entity/yahoo:types/yahoo:type
            return substring($type, 2)
        order by xs:integer($entity/yahoo:text/@start)
        return if($entity/yahoo:types) then
            <ex:entity start="{$entity/yahoo:text/@start}" end="{$entity/yahoo:text/@end}" type="{$type}"> {$entity/yahoo:text/text()} </ex:entity>
            else <ex:entity start="{$entity/yahoo:text/@start}" end="{$entity/yahoo:text/@end}"> {$entity/yahoo:text/text()} </ex:entity>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of categories 
 : encountered in the xml or text supplied as input.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of categories recognized
 : @example test/Queries/categories.xq
 :)
declare %ann:sequential function ex:categories($text){
    let $uri := concat("http://query.yahooapis.com/v1/public/yql?q=", 
        encode-for-uri(concat("select * from contentanalysis.analyze where text=", concat('"', concat($text, '"')))))
    let $response := http:post($uri,"")[2]
    let $categories := $response/query/results/yahoo:yctCategories/yahoo:yctCategory
    return if ($categories) then 
        for $category in $categories
        return <ex:category> {$category/text()} </ex:category>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of relations 
 : between entities encountered in the xml or text supplied as input.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of relations recognized
 : @example test/Queries/relations.xq
 :)
declare %ann:sequential function ex:relations($text){
    let $uri := concat("http://query.yahooapis.com/v1/public/yql?q=", 
        encode-for-uri(concat("select * from contentanalysis.analyze where text=", concat('"', concat($text, '"')))))
    let $response := http:post($uri,"")[2]
    let $relations := $response/query/results/yahoo:entities/yahoo:entity/yahoo:related_entities
    return if ($relations) then
        for $relation in $relations
        return <ex:relation>{
            (let $type := 
                for $type in $relation/../yahoo:types/yahoo:type
                return substring($type, 2)
            return if($relation/../yahoo:types) then
                <ex:entity start="{$relation/../yahoo:text/@start}" end="{$relation/../yahoo:text/@end}" type="{$type}"> {$relation/../yahoo:text/text()} </ex:entity>
                else <ex:entity start="{$relation/../yahoo:text/@start}" end="{$relation/../yahoo:text/@end}"> {$relation/../yahoo:text/text()} </ex:entity>)
            union
            (for $link in $relation/yahoo:wikipedia/yahoo:wiki_url
            return <ex:wikipedia_url>{$link/text()}</ex:wikipedia_url>)
        }</ex:relation>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of concepts 
 : encountered in the xml or text supplied as input.
 :
 : @param $text XML document or string to be analyzed
 : @return XML document with a list of concepts recognized
 : @example test/Queries/concepts.xq
 :)
declare %ann:sequential function ex:concepts($text){
    let $uri := concat("http://query.yahooapis.com/v1/public/yql?q=", 
        encode-for-uri(concat("select * from contentanalysis.analyze where text=", concat('"', concat($text, '"')))))
    let $response := http:post($uri,"")[2]
    let $concepts := $response/query/results/yahoo:entities/yahoo:entity/yahoo:wiki_url
    return if ($concepts) then
        for $link in $concepts
        let $entity := $link/..
        let $type := 
            for $type in $entity/yahoo:types/yahoo:type
            return substring($type, 2)
        order by xs:integer($entity/yahoo:text/@start)
        return <ex:concept>{
            (if ($entity/yahoo:types) then <ex:entity start="{$entity/yahoo:text/@start}" end="{$entity/yahoo:text/@end}" type="{$type}"> {$entity/yahoo:text/text()} </ex:entity>
            else <ex:entity start="{$entity/yahoo:text/@start}" end="{$entity/yahoo:text/@end}"> {$entity/yahoo:text/text()} </ex:entity>) 
            union 
            (if ($link) then 
            <ex:wikipedia_url>{$link[1]/text()}</ex:wikipedia_url> else ())
        }</ex:concept>
    else ()
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of entities (as inline annotations)
 : encountered in the xml or text supplied as input.
 :
 : @param $text XML entity or a string to be analyzed
 : @return XML document with a list of entities recognized
 : @example test/Queries/entities-inline.xq
 :)
declare %ann:sequential function ex:entities-inline($text){
   ex:entity-inline-annotation($text , ex:entities($text), 0)
};

(:~
 : Uses Yahoo's Content Analysis webservice to return a list of concepts (as inline annotations) 
 : encountered in the xml or text supplied as input.
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
    else(substring($text, 0, ($entities/@start)[1] +1 -$size), 
        $entities[1],
        ex:entity-inline-annotation(substring($text, ($entities/@end)[1] +2 -$size), $entities[position() >1], ($entities/@end)[1] +1))
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
