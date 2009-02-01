require 'test/unit'
require 'network'

class TestNetworkLoader < Test::Unit::TestCase
  
  def setup
    @nn = NeuralNetwork.new("unit_test")
    @nl = NetworkLoader.new
  end
  
  def teardown
    File.delete("./data/unit_test.network")
  end
  
  def test_save_network
    assert(true, @nl.saveNetwork(@nn))
    assert(true, File.exists?("./data/unit_test.network"))
  end
  
  def test_load_network
    @nl.saveNetwork(@nn)
    assert(true, @nl.loadNetwork("unit_test"))
  end
  
end