require 'matrix'
require 'set'
require 'thread'
require 'vertex'
require 'edge'
require 'rubygems'
require 'graphviz'

class Graph
  attr_accessor :vertices, :edges, :adj_list, :vlabels, :directed
  #Create new [un]directed graph using given vertices and edges between them
  def initialize(v, g, directed = false)
    @vertices, @edges, @adj_list, @verticeslabels, @directed = v.to_set, g.to_set, {}, {}, directed
    convert_to_adj_list
  end

  #Convert all vertices and edges into adjacency list
  def convert_to_adj_list
    @edges.map {|edge| add_edge(edge)}
    @vertices.map {|vertex| add_vertex(vertex)}
  end

  #Show graph in adjacency list form
  def show_adj_list
    @adj_list.keys.inject("") {|sum,v| sum += "#{v}: {#{@adj_list[v].to_a.join(',') if @adj_list[v]}}\n"}
  end  

  #Breadth First Search subroutine
  def bfs_sub(to_vis,visited)
    #If there is no vertex to visit then we're done
    return visited if to_vis.empty?
    #get next vertex to visit
    vis = to_vis.deq
    #if next vertex to visit is already visited then we can just skip it      
    if visited.include?(vis)
      bfs_sub(to_vis,visited)
    else
      #add all neighbours to vertices to visit
      @adj_list[vis].map {|vertex| to_vis.enq(vertex)}
      #add currect vertex to visit to visited vertices list
      visited << vis
      bfs_sub(to_vis,visited)
    end
  end

  #Breadth First Search procedure
  def bfs
    #Queue for visited vertices
    to_vis = Queue.new
    #Select the 'first' vertex
    first = @vertices.sort.first
    #Put it into queue for visited vertices
    to_vis.enq(first)
    #Run the subroutine
    bfs_sub(to_vis,[])
  end

  #Check wheather graph contains cycles
  def contain_cycle(vertex)
    @marking = Hash.new
    if @marking[x] == 'in Bearbeitung'
      return true
    elsif @marking[x] == 'noch nicht begonnen'
      @marking[x] = 'in Bearbeitung'
      for n in @adj_list[x] do
        contain_cycle(n)
      end
      @marking[x] = 'abgeschlossen'
    end
  end

  #Add vertex to adjacency list
  def add_vertex(vertex)
    @adj_list[vertex] = Set.new unless @adj_list[vertex]
  end

  #Add edge to adjacency list
  def add_edge(edge)
    @adj_list[edge.v1] << edge.v2 if @adj_list[edge.v1]
    @adj_list[edge.v1] = Set.new [edge.v2] unless @adj_list[edge.v1]
    unless directed
      @adj_list[edge.v2] << edge.v1 if @adj_list[edge.v2]
      @adj_list[edge.v2] = Set.new [edge.v1] unless @adj_list[edge.v2]
    end
  end

  #Returns the degree of the given vertex
  def deg(vertex)
    res = 0
    @edges.each {|edge| res += 1 if edge.v1 == vertex}
    res
  end

  #Returns cartesian product of this and given graphs
  def cartesian_product(graph)
    verts = []
    edges = []
    @vertices.each do |u|
      graph.v.each do |v|
        verts << [u,v]
      end
    end

    verts.each do |elem|
      verts.each do |elem2|
        edge1 = Edge.new(elem[0],elem2[0])
        edge2 = Edge.new(elem[1],elem2[1])
        edges << [elem,elem2] if (@edges.include?(edge1) && elem[1] == elem2[1]) || (@edges.include?(edge2) && elem[0] == elem2[0])
      end
    end

    grVerts = verts.map {|v| v.inject {|rv,v| rv.mult v}}
    grEdges = []
    edges.each do |edge|
      e1,e2 = edge
      v1 = e1[0].mult(e1[1])
      v2 = e2[0].mult(e1[1])
      grEdges << Edge.new(v1,v2)
    end

    Graph.new(grVerts,grEdges)
  end
    
  def to_s
    "V = {#{@vertices.join(', ')}} G = {#{@edges.join(', ')}}"
  end
  
  #Render current graph into file using given format (uses graphviz lib)
  def render_to(params = {:format => 'png', :file => "graph.#{params[:format]}"})
    graph = GraphViz.new('somegraph', :output => params[:format], :file => params[:file], :type => 'graph')
    hash = {}
    @vertices.each do |v|
      hash[v] = graph.add_node(v.to_s)
    end
    @edges.each do |e|
      graph.add_edge(hash[e.v1],hash[e.v2])
    end
    graph.output
  end
end
