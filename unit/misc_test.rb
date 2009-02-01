require 'test/unit'
require 'network'

class TestMiscNetwork < Test::Unit::TestCase
  
  def setup
    @idgen = NetworkIdGenerator.new
  end
  
  def test_new_id
    currentval = @idgen.current
    @idgen.generateId("unit_text")
    nextval = @idgen.current
    assert_not_equal(currentval, nextval)
  end
  
end