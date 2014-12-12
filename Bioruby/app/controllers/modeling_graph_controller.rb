require 'graphviz'
require 'bio/db/pdb'


class ModelingGraphController < ApplicationController

  def modeling_graph

    @results = false
    @x_array = []
    @y_array = []
    @z_array = []
    @atomas1 = []
    @atomas2 = []
    @residue_id = []
    @e_d = []
    @sheet_data_init = []
    @sheet_data_end = []
    @helix_data_init = []
    @helix_data_end = []
    @sheet_chain_init = []
    @sheet_chain_end = []
    @helix_chain_init = []
    @helix_chain_end = []
    @vertices = []
    @x = []
    @y = []
    @z = []
    index3=0
    index4=0

    input = params[:input]
    @kmin = 200
    if params[:input] != nil
      @results = true
 
    string = IO.read(input)
      
    @structure = Bio::PDB.new(string)
    #Saugomos pradzios ir pabaigos pozicijos
    @structure.sheet.each do |sheet|
      sheet.each do |data|
        @sheet_data_init[index3] = data.initSeqNum
        @sheet_data_end[index3] = data.endSeqNum
        index3 = index3+1
      end
    end

    @structure.helix.each do |data|
      @helix_data_init[index4] = data.initSeqNum
      @helix_data_end[index4] = data.endSeqNum
      index4 = index4 +1
    end

    @pozicijos = []
    @pozicijos = @sheet_data_init.dup
    @pozicijos.push(@helix_data_init)
    @pozicijos.flatten!
    @pozicijos.sort!
    
    @pozicijos_end = []
    @pozicijos_end = @sheet_data_end.dup
    @pozicijos_end.push(@helix_data_end)
    @pozicijos_end.flatten!
    @pozicijos_end.sort!
    
    #Viršūnės
    @pozicijos.size.times do |p|
      @sheet_data_init.size.times do |s|
        if @pozicijos[p] == @sheet_data_init[s]
          @vertices[p] = 'B'+ (s+1).to_s
        end
      end
      @helix_data_init.size.times do |h|
        if @pozicijos[p] == @helix_data_init[h]
          @vertices[p] = 'A'+(h+1).to_s
        end
      end
    end

    @counter_edge = []

    #nusiskaitom atitinkamas koordinates

    @vertices.size.times do |t|
      @x[t] ||= []
      @y[t] ||= []
      @z[t] ||= []
     
      @structure.each{ |model|
       
        model.each{ |chain|
           index=0
          chain.each{ |residue|          
            residue.each{ |atom|
              if atom.resSeq >=  @pozicijos[t].to_i and atom.resSeq <= @pozicijos_end[t].to_i and atom.name.first == "C"
                @x[t][index] = atom.x
                @y[t][index] = atom.y
                @z[t][index] = atom.z
                index=index+1
              end
     
            }
            
          }
        }
      }
    end

    @konstanta = 0
    @W = []
    @S = 0
    @S_k = 0

    @vertices.size.times do |i|
      @e_d[i] ||= []
      @counter_edge[i] ||= []
      @vertices.size.times do |j|
        if i<j
          count_edges(@x[i],@x[j],@y[i],@y[j],@z[i],@z[j],i,j)
        end
      end
    end


    @konstanta = @S_k/@S


    @vertices.size.times do |i|
      @counter_edge[i] ||= []
      @W[i] ||= []
      @vertices.size.times do |j|
        if i == j-1
          @b=1
        else
          @b =0
        end
        @W[i][j] = @konstanta*@b + @counter_edge[i][j].to_i

      end
    end
    
    #paduodami  virsunes array ir dvimatis edge array
    grafas(@vertices ,@vertices, @W, 'pdb')
    end
  end

  def count_edges(x1,x2,y1,y2,z1,z2,num,num2)
    @counter = 0
    x1.size.times do |first|      
      x2.size.times do |second|
        temp = euclidean_distance(x1[first],x2[second],y1[first],y2[second],z1[first],z2[second])
        min_angstrom = 7
        if temp <= min_angstrom
    
          @counter = @counter + 1        
        end
      end
    end
  
    if @counter > @kmin
      @counter_edge[num][num2] = @counter   
      @S = @S+1
      @S_k = @S_k +@counter
     
    end
  end

  #Euklido atstumes
  def euclidean_distance(x1,x2,y1,y2,z1,z2)
    Math.sqrt(((x1-x2)**2+(y1-y2)**2+(z1-z2)**2))
  end

  #Grafas


  def grafas(vertices,vertices2,edges,name)
    g = GraphViz.new( :G, :type => :graph )
    gr = Graph.new

    vertices.size.times do |i|
      vertices2.size.times do |n|
        if edges[i][n] != nil and n > i and edges[i][n] != 0
          vertice_one = vertices[i].to_s 
          vertice_two = vertices2[n].to_s
          edge_label = edges[i][n]
          gr.add_edge(vertice_one, vertice_two, edge_label)
          first = g.add_node(vertice_one )
          second = g.add_node(vertice_two)
          g.add_edge( first, second, :label=> edge_label)
        end
      end
    end
    gr.simple_unfold
    g.output( :png => "#{RAILS_ROOT}/public/images/graphs/#{name}.png" )
  end


end



