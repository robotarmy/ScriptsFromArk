 #!/usr/bin/env ruby
 require 'rubygems'
 require "graphviz"
 graph = GraphViz::new('ZenSalesForce')
 
  map = {}; # used as a memo to keep lookup nodes created already
  files = Dir['*.cls'];
  files.map!{|f|f.split('.')[0]} # chop off extention
  files.each {|f| 
   map[f] ||= graph.add_node(f); 
   IO.readlines("#{f}.cls").each_with_index{|l,i| 
                                   files.each {|token| 
                                                if l =~ /#{token}/
                                                 map[token] ||= graph.add_node(token)
                                                 unless 1 == map[f+token] 
                                                  graph.add_edge(map[f],map[token])
                                                  map[f+token] = 1
                                                 end
                                                end
                                              } 
                                  }
            }
graph.output( :file => "code.png" ,:output => 'png',:use => 'twopi')


