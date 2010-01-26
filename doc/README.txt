= Example ~/.spiderviz.yaml =

skip_patterns:
 - '.zip$'
 - '.pdf$'

ignore_patterns:
 - '^#'
 - '#\w+$'

dot_header: >
 digraph G {
 rankdir="LR"; 
 mclimit=64.0; 
 concentrate="true";
 center="true"; 
 overlap=false; 
 splines=true; 
 node[height=.5,width=5.0];

= Example site.yaml =

base:
    - "http://www.example.com"
    - "http://example.com"
depth_factor: 2

= Usage =

spiderviz.pl site.yaml > site.dot
dot -Tpdf -osite.pdf site.dot

(or, instead of dot: neato, twopi, circo)

