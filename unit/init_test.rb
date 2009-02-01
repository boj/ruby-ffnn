require 'test/unit'
require 'network'

class TestInitialization < Test::Unit::TestCase
  
  def test_initialize_loader
    assert(true, NetworkLoader.new)
  end
  
  def test_initialize_network
    assert(true, NeuralNetwork.new("test"))
    assert_raise ArgumentError do
      nn = NeuralNetwork.new
    end
  end
  
  def test_initialize_layer
    assert(true, NetworkLayer.new(2))
    assert_raise ArgumentError do
      nn = NeuralNetwork.new
    end
  end
  
  def test_initialize_neuron
    assert(true, NetworkNeuron.new(1.0))
  end
  
  def test_initialize_id_generator
    assert(true, NetworkIdGenerator.new)
  end
  
end