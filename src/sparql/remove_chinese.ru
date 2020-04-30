prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

DELETE {
  ?class rdfs:label ?display_name
}
WHERE {
  ?class rdf:type owl:Class.
  ?class rdfs:label ?display_name
  FILTER(lang(?display_name) = "zh")
}