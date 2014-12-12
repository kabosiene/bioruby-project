require 'rubygems'
require 'graphviz'

class Hash
  def key(search)
    self.each_pair do |key, value|
      return key if value == search
    end
    
    return false
  end
end

class Array
  def sum_elements
    inject(:+)
  end
  
  def sum_keys  
    total = 0
    
    each do |e|
     total += e[0]
    end
    
    total      
  end
end


class Graph

  # Constructor

  def initialize
    @g = {}	 # the graph // {node => { edge1 => weight, edge2 => weight}, node2 => ...
    @nodes = Array.new
    @edges = {}
    @edges_weights = []
    @removed_edges = {}
    @INFINITY = 1 << 64
  end
  
  def dijkstra(s)
    @d = {}
    @prev = {}

    @nodes.each do |i|
      @d[i] = @INFINITY
      @prev[i] = -1
    end

    @d[s] = 0
    q = @nodes.compact
    while (q.size > 0)
      u = nil;
      q.each do |min|
        if (not u) or (@d[min] and @d[min] < @d[u])
          u = min
        end
      end
      if (@d[u] == @INFINITY)
        break
      end
      q = q - [u]
      @g[u].keys.each do |v|
        alt = @d[u] + @g[u][v]
        if (alt < @d[v])
          @d[v] = alt
          @prev[v]  = u
        end
      end
    end
  end

  # To print the full shortest route to a node

  def print_path(dest)
    if @prev[dest] != -1
      print_path @prev[dest]
    end
    print ">#{dest}"
  end

  # Gets all shortests paths using dijkstra

  def shortest_paths(s)
    @source = s
    dijkstra s
    puts "Source: #{@source}"
    @nodes.each do |dest|
      puts "\nTarget: #{dest}"
      print_path dest
      if @d[dest] != @INFINITY
        puts "\nDistance: #{@d[dest]}"
      else
        puts "\nNO PATH"
      end
    end
  end
  
  # Check if connected
  
  def connected?
    each_node do |dest|
      dijkstra(dest)
      return false if @d.values.any?{ |e| e == @INFINITY }
    end
    
    return true
  end
  
  
  def nodes
    @nodes
  end
  
  def each_node(&block)
    nodes.each do |n|
      yield(n)
    end
  end
  
  def edges_weights
    @edges_weights
  end

  def add_edge(s,t,w) 		# s= source, t= target, w= weight
    # add to edges
    index = @removed_edges.index([s, t])
    
    if index
      @edges_weights[index] = w
      @edges[index] = [s, t]
    else
      @edges_weights << w
      @edges[@edges_weights.size-1] = [s, t]
    end
        
    if (not @g.has_key?(s))
      @g[s] = {t=>w}
    else
      @g[s][t] = w
    end

    # Begin code for non directed graph (inserts the other edge too)

    if (not @g.has_key?(t))
      @g[t] = {s=>w}
    else
      @g[t][s] = w
    end

    # End code for non directed graph (ie. deleteme if you want it directed)

    if (not @nodes.include?(s))
      @nodes << s
    end
    if (not @nodes.include?(t))
      @nodes << t
    end
  end
  
  def remove_edge(s, t)
    @g[s].delete(t)
    @g[t].delete(s)
    
    @edges.values.each do |a, b|
      if (a == s and t == b) or (a == t and b == s)
        key = @edges.key([a, b]) || @edges.key([b, a])
        @edges.delete(key)
        @removed_edges[key] = [s, t]
      end
    end
  end
  
  def edges
    @edges
  end
  
  def cut_min
    total_edges = edges.keys.size + 1
    
    all_permutations = []
    weights = []
    edges_weights.each_with_index do |value, index|
      weights << [ value,  index ]
    end
    
    total_edges.times do |i|
      all_permutations << weights.permutation(i+1).to_a
    end
    
    permutations = all_permutations.flatten(1).map{ |e| [ e.sum_keys, e ] }.sort_by{ |p| p.first }
     
    permutations.each do |p|
      p = p.last
      # edge_to_cut - kuria briaunas bandyti kirsti formate [svoris, briaunos indeksas]
      p.each do |edge_to_cut|
        vertices = edges[edge_to_cut.last]
        
        remove_edge vertices.first, vertices.last
      end
        
      if connected?
        # go back, go back!
        @removed_edges.each_pair do |key, vertices|
          add_edge vertices.first, vertices.last, edges_weights[key]
        end
      else
        # wualla
        return p
      end
    end
  end
  
  def unfold
    cut_min
    
    node = @nodes.first
    dijkstra(node)
    
    new_graph_nodes1 = @d.find_all{ |key, value| value != @INFINITY }.map{ |e| e.first }
    new_graph_nodes2 = @d.find_all{ |key, value| value == @INFINITY }.map{ |e| e.first }
    
    graph1 = Graph.new
    if new_graph_nodes1.size == 1
      graph1.add_edge new_graph_nodes1.first, new_graph_nodes1.first, 0
    else
      edges.each_pair do |weight, vertices|
        graph1.add_edge vertices.first, vertices.last, edges_weights[weight] if vertices.all? { |e| new_graph_nodes1.include?(e) }
      end
    end
    
    graph2 = Graph.new
    if new_graph_nodes2.size == 1
      graph2.add_edge new_graph_nodes2.first, new_graph_nodes2.first, 0
    else
      edges.each_pair do |weight, vertices|
        graph2.add_edge vertices.first, vertices.last, edges_weights[weight] if vertices.all? { |e| new_graph_nodes2.include?(e) }
      end
    end
    
    return [graph1, graph2]
  end

  def run_unfold(tree, parent)
    graph1, graph2 = unfold
    
    if graph1.nodes.size == 1
      graph1_nodes = graph1.nodes.join
      node = tree.add_node(graph1_nodes)
      tree.add_edge(parent, node)
    else
      graph1_nodes = graph1.nodes.join("-")
      node = tree.add_node(graph1_nodes)
      tree.add_edge(parent, node)
      graph1.run_unfold(tree, node) 
    end
    
    if graph2.nodes.size == 1
      graph2_nodes = graph2.nodes.join
      node = tree.add_node(graph2_nodes)
      tree.add_edge(parent, node)
    else
      graph2_nodes = graph2.nodes.join("-")
      node = tree.add_node(graph2_nodes)
      tree.add_edge(parent, node)
      graph2.run_unfold(tree, node)
    end
 
    return tree
  end
  
  def simple_unfold(output_to = nil)
    g = GraphViz.new(:G, :type => :graph)
    parent = g.add_node(@nodes.join("-"))
    g = run_unfold g, parent
    g.output(:png => (output_to || "#{RAILS_ROOT}/public/images/graphs/unfold.png"))
  end
end


 
