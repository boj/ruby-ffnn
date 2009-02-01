# Ruby Neural Network Library
#
# Basic implementation of a (currently) feed forward neural network.
#
# = Basic Usage
#
#   nn = NeuralNetwork.new("unique_name")
#
#   # Assign number of randomly built neurons to layer
#   il = NetworkLayer.new(3)
#   hl = NetworkLayer.new(5)
#   ol = NetworkLayer.new(3)
#
#   nn.pushInputLayer(il)
#   nn.pushHiddenLayer(hl)
#   nn.pushOutputLayer(ol)
#
#   nn.run # Returns a NetworkLayer by default, override with nn.return_vector = true
#
# Author:: Brian Jones (mailto:mojobojo@gmail.com)
# Copyright:: Copyright (c) 2009 Brian Jones
# License:: The MIT License

include Math

# = Network Loader
#
# Saves and loads a serliazed neural network from disk.
# Networks are named with a unique id and a .network extension.

class NetworkLoader

  # The default path is set to the local ./data directory.
	@@path = "./data"
  # The extension with which to save a network.
  @@extension = "network"
  
  # Overrides the current @@path default.
  
  def setPath(path)
    @@path = path
  end
  
  # Overrides the current @@extension default.
  
  def setExtension(ext)
    @@extension = ext
  end
  
  # Writes a network out to disk.
  
	def saveNetwork(nn)
		data = Marshal.dump(nn)
		f = File.new("%s/%s.%s" % [@@path, nn.id, @@extension], "w")
		f.write(data)
		f.close
	end
	
	# Loads a network with the corresponding id from disk and returns it.

	def loadNetwork(id)
		f = File.open("%s/%s.%s" % [@@path, id, @@extension], "r")
		data = Marshal.load(f)
		f.close
		return data
	end

end

# = Neural Network
#
# Basic feed forward neural network.  Consists of
# an input layer, output layer, and 1..n hidden layers.
# Layers are derived from the NetworkLayer class.
#
# * If set to true, network.squash will condense values to a range of 0..1
# * If set to true, network.return_vector will return a vector instead of a layer

class NeuralNetwork

	attr_reader :id
	attr_writer :return_vector, :squash
	
	# Initializes the network with a given id.
	# This id determines how the network will be
	# both tracked, saved, and loaded.

	def initialize(id)
		@id				= id
		@layers			= Array.new

		# Track if layer was pushed onto layer stack
		@input_pushed	= nil
		@output_pushed	= nil

		# Return layer (default), or a vector
		@return_vector	= nil

		# Squash return values to 0, 1?
		@squash 		= nil
		
		# Default min/max values
		@MIN = 0.0
  	@MAX = 1.0
	end
	
	# Override the @MIN value.
	
	def setMin(value)
	  @MIN = value
	end
	
	# Override the @MAX value.
	
	def setMax(value)
	  @MAX = value
	end
	
	# Runs the network with given input.
	# Results are stored in the output layer.
	#
	# Input can be given in two forms:
	# * A vector of values.
	# * A NetworkLayer consisting of NetworkNeurons.

	def run(input=nil)

		# If input isn't nil, then a vector or layer is being passed in instead of a preinit'ed input layer
		if !input.nil?
			if input.kind_of?(NetworkLayer)
				last_layer = input
			elsif input.kind_of?(Array)
				last_layer = NetworkLayer.new(input.size)
				last_layer.getNeurons.each do |n|
					n.output = input.shift()
				end
			end
		else
			l = @layers # Copy the layers array
			last_layer = l.shift() # Pop input layer off copied stack
		end

    # Process the data
		@layers.each do |l|
			l.getNeurons.each do |n|
				sum = 0.0
				# Sum the weight of the neuron against the input values
				for neuron in last_layer.getNeurons
					sum = n.weight * neuron.output + sum
				end
				# Smooth the sum using the neurons activation function
				value = eval("%s(sum)" % n.activation_function)
				if !@squash.nil? # Squash the value
					if n.threshold < value
						n.output = @MIN
					else
						n.output = @MAX
					end
				else # Return the raw value
					n.output = value
				end
			end	
			last_layer = l
		end

		if @return_vector.nil?
			return last_layer # Last layer will be the output layer
		else
			d = Array.new
			last_layer.getNeurons.each do |n|
				d.push(n.output)
			end
			return d # Return back a vector instead of a layer
		end
	end

  # Push a new input layer into the stack.

	def pushInputLayer(layer)
		if @input_pushed.nil?
			if layer.kind_of?(NetworkLayer)
				@layers.unshift(layer)
			elsif layer.kind_of?(Fixnum)
				l = NetworkLayer.new(layer)
				@layers.unshift(layer)
			else
				raise "No valid input layer data pushed to method"
			end
		else
			raise "An input layer was already pushed onto the stack"
		end

		@input_pushed = true
	end
	
	# Push hidden layers onto the stack.

	def pushHiddenLayer(layer)
		if layer.kind_of?(NetworkLayer)
			l = layer
		elsif layer.kind_of?(Fixnum)
			l = NetworkLayer.new(layer)
		else
			raise "No valid layer data pushed to method"
		end
	
		if !@output_pushed.nil? # Output layer was pushed, insert before it
			ol = @layers.pop() # Pop the output layer
			@layers.push(l) # Push the new layer
			@layers.push(ol) # Push the output layer
		else
			@layers.push(l)
		end	
	end
	
	# Push the output layer onto the stack.

	def pushOutputLayer(layer)
		if @output_pushed.nil?
			if layer.kind_of?(NetworkLayer)
				l = layer
			elsif layer.kind_of?(Fixnum)
				l = NetworkLayer.new(layer)
			else
				raise "No valid output layer data pushed to method"
			end
		else
			raise "An output layer was already pushed onto stack"
		end	

		@layers.push(l)
		@output_pushed = true
	end
	
	# Render relevant data about the network.

	def printNetwork
		print "Network Name: %s\n" % @id
		print "----\n"
		count = 0
		@layers.each do |l|
			count = count + 1
			print "Layer: %i\n" % count
			print "Layer Id: %s\n" % l.id
			ncount = 0
			l.getNeurons.each do |n|
				ncount = ncount + 1
				print " - Neuron Id: %s\n" % n.id
				print " - Neuron: %i\n" % ncount
				print " -- Weight: %f\n" % n.weight
				print " -- Threshold: %f\n" % n.threshold
			end
		end
	end

end

# = Network Layer
# 
# Contains a set of NetworkNeurons.

class NetworkLayer

	@@type = "Layer"

	attr_reader :id
	
	# Either initializes with a vector of neurons,
	# or just a number of neurons to create.
	# Gets a unique id from NetworkIdGeneratorClass.

	def initialize(neurons)

		@id = NetworkIdGeneratorClass.generateId(@@type)

		@neurons = Array.new

		if neurons.kind_of?(Integer)
			buildLayer(neurons)
		else
			@neurons	= neurons
		end	
	end
	
	# If a numeric value was set during initialization,
	# build the layer with NetworkNeurons.

	def buildLayer(neurons)
		neurons.times do
			neuron = NetworkNeuron.new
			@neurons.push(neuron)
		end
	end
	
	# Return the neurons for this layer.

	def getNeurons
		return @neurons
	end

end

# = Network Neuron
#
# The neurons within a layer.
# Neurons are assigned a default activation function referenced by string,
# currently set to the sigmoid function.  This can be overridden.

class NetworkNeuron

	@@type 		    = "Neuron"
	@@default_af	= "sigmoid"

	attr_reader :id, :weight, :threshold, :activation_function, :output
	attr_writer :weight, :threshold, :activation_function, :output
	
	# Initializes a neuron with either a passed floating point value,
	# or will default to 0.0.
	#
	# * The threshold and weight values are set to a random value.
	# * The neuron is assigned a unique id.
	# * The weight, threshold, and activation function can be overridden.

	def initialize(input=nil)
		
		@id = NetworkIdGeneratorClass.generateId(@@type)

		if !input.nil?
			@output = input
		else
			@output = 0.0
		end
		
		@threshold	= rand(0)
		@weight		  = rand(0)
		@activation_function = @@default_af # Initializes to the default

	end
	
	# Randomize the neurons weight.

	def randWeight
		@weight = rand(0)
	end
	
	# Randomize the neurons threshold.

	def randThreshold
		@threshold = rand(0)
	end
	
	# Randomize both the weight and threshold.

	def randAll
		randWeight()
		randThreshold()
	end
	
	# Override the @weight value.
	
	def setWeight(value)
	  @weight = value
	end
	
	# Override the @threshold value.
	
	def setThreshold(value)
	  @threshold = value
	end

end

# = Network Id Generator
# 
# Generates a new id, starting from 100.

class NetworkIdGenerator

	@@counter = 100

	def generateId(type)
		@@counter = @@counter + 1
		return "%s-%i" % [type, @@counter]
	end
	
	# Returns the current value of @@counter.
	
	def current
	  return @@counter
	end

end

NetworkIdGeneratorClass = NetworkIdGenerator.new

# = Sigmoid activation function.

def sigmoid(x)
	return (1.0 / (1.0 + exp(-x)))
end