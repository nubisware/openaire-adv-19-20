module namespace hs = 'urn:dnet:demo:harvest';

declare namespace oai = "http://www.openarchives.org/OAI/2.0/";

declare function hs:call($line as xs:string){
  let $url := "http://10.17.217.17:8086/write?db=openaire"
  let $req := 
    <http:request href="{$url}" method="POST">
      <http:body media-type="application/octet-stream">{$line}</http:body>
    </http:request>
  let $resp := http:send-request($req)
  return ()  
};

declare function hs:trace-page($source as xs:string, $page as xs:integer, $operation as xs:string, $recordcount as xs:integer){
  let $line-tags := string-join(("page", "source=" || $source, "operation=" || $operation), ",")
  let $line-fields := string-join(("count=" || $recordcount, 'page="' || $page || '"'), ",")
  let $line := $line-tags || " " || $line-fields
  return hs:call($line)
};

declare function hs:trace-record($source as xs:string, $page as xs:integer, $operation, $localid as xs:string, $index as xs:integer){
  let $line-tags := string-join(("record", 'source=' || $source, 'page=' || $page), ",")
  let $line-fields := string-join(('record="' || $localid || '"', 'index=' || $index, 'operation="' || $operation || '"'), ",")
  let $line := $line-tags || " " || $line-fields
  return hs:call($line)
};

declare function hs:handle-records($source as xs:string, $page as xs:integer, $data as node()){
  let $records := $data//oai:record
  let $db := $source
  let $basecount := count(db:open($db))
  let $storedrecords := 
    for $r at $pos in $records
    let $localid := $r/oai:header/oai:identifier/string()
    let $l := hs:trace-record($source, $page, "fetchRawRecord", $localid, $basecount + $pos)
    let $out := db:replace($source, $localid || ".xml", $r)
    return hs:trace-record($source, $page, "storeNativeRecord", $localid, $basecount + $pos)
    
  return count($records)
};

declare function hs:handle-page($source, $page, $data){
  let $l := hs:trace-page($source, $page, "startpage", 0)
  let $recordcount := hs:handle-records($source, $page, $data)  
  let $l := hs:trace-page($source, $page, "endpage", $recordcount)
  return map{ "records" : $recordcount, "continuation" : $data//oai:resumptionToken/string()} 
};

declare
  %rest:POST("{$data}")
  %rest:path("harvest/{$source}/{$page}")
  %rest:consumes("application/xml")
  %output:method("json")
function hs:harvest($data as document-node(), $source as xs:string, $page as xs:integer){
  hs:handle-page($source, $page, $data)
};

declare
  %rest:GET
  %rest:path("harvest/metrics/grafana")
  %output:method("json")
function hs:test-grafana(){
  ()
};

declare
  %rest:POST("{$search-query}")
  %rest:path("harvest/metrics/grafana/search")
  %rest:consumes("application/json")
  %output:method("json")
function hs:search-grafana($search-query as node()){
  ["practitioners", "production-per-practitioner"]
};

declare
  %rest:POST("{$query}")
  %rest:path("harvest/metrics/grafana/query")
  %rest:consumes("application/json")
  %output:method("json")
function hs:query-grafana($query as node()){
  [
    map{
      "type" : "table",
      "columns" : [
        map{"text" : "Practitioner", "type" : "string"}
      ],
    "rows" : [
        ["Mario Rossi"],
        ["Marta Confaloni"]
      ] 
    }  
  ]
};