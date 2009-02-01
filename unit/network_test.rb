require 'test/unit'
require 'network'

class TestNetwork < Test::Unit::TestCase
  
  def setup
    @nn = NeuralNetwork.new("test")
    @l = NetworkLayer.new(2)
  end
  
  def test_push_input_layer
    assert_raise ArgumentError do
      @nn.pushInputLayer
    end
    assert(true, @nn.pushInputLayer(@l))
  end

  def test_push_output_layer
    assert_raise ArgumentError do
      @nn.pushOutputLayer
    end
    assert(true, @nn.pushOutputLayer(@l))
  end

  def test_push_hidden_layer
    assert_raise ArgumentError do
      @nn.pushHiddenLayer
    end
    assert(true, @nn.pushHiddenLayer(@l))
  end

  def test_network_run
    assert_nil(@nn.run)
    @nn.pushInputLayer(@l)
    @nn.pushHiddenLayer(@l)
    @nn.pushOutputLayer(@l)

    assert(true, @nn.run)
    assert(true, @nn.run(@l))
  end

  def test_network_output
    @nn.pushInputLayer(@l)
    @nn.pushHiddenLayer(@l)
    @nn.pushOutputLayer(@l)
    
    assert_kind_of(NetworkLayer, @nn.run)
    @nn.return_vector = true
    assert_kind_of(Array, @nn.run)
  end
  
end