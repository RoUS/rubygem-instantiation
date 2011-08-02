require File.dirname(__FILE__) + '/test_helper.rb'
require 'pp'

class TestPreInit < Test::Unit::TestCase

  def setup
    @testdata_hash_symbolic_keys = {
      :ivar1	=> 1,
      :ivar_1	=> '1',
      :ivar_one	=> :one,
    }
    @testdata_hash_string_keys = {
      'ivar1'	=> 1,
      'ivar_1'	=> '1',
      'ivar_one'=> :one,
    }
    @testdata_hash_mixed_keys = {
      :ivar1	=> 1,
      'ivar_1'	=> '1',
      :ivar_one	=> :one,
    }
    @testdata_hash_bogus_keys = {
      :bogokeys	=> {
        '=bk1='	=> '_bk1_',
        '@bk2'	=> '_bk2',
        'really--+-long&bogus*one' \
		=> 'really_long_bogus_one',
      },
      :ivar1	=> 1,
      'ivar_1'	=> '1',
      :ivar_one	=> :one,
    }
    @testdata_hash_bogus_keys[:bogokeys].each do |raw,edited|
      @testdata_hash_bogus_keys[raw] = edited
    end
  end
  
  def test_001_empty
    o_test = TestClass.new
    assert(o_test.kind_of?(TestClass))
    assert(o_test.kind_of?(PreInit))
  end

  def test_002_simple_hash_symbolic_keys
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_003_simple_hash_string_keys
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_004_simple_hash_mixed_keys
    ihash = @testdata_hash_mixed_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_005_simple_hash_bogus_keys_raise
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      o_test = TestClass.new(ihash)
    end
  end

  def test_102_postload_simple_hash_symbolic_keys
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new
    result = PreInit.import_instance_variables(o_test, ihash)
    assert(result.kind_of?(TestClass))
    assert_same(o_test, result)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_103_postload_simple_hash_string_keys
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new
    result = PreInit.import_instance_variables(o_test, ihash)
    assert(result.kind_of?(TestClass))
    assert_same(o_test, result)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_202_blockload_simple_hash_symbolic_keys
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new({}, ihash) { |o,*args|
      (ivar, ival) = args.first
      o.instance_variable_set("@#{ivar.to_s}".to_sym, ival)
    }
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_203_blockload_simple_hash_string_keys
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new({}, ihash) { |o,*args|
      (ivar, ival) = args.first
      o.instance_variable_set("@#{ivar.to_s}".to_sym, ival)
    }
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_302_postblockload_simple_hash_symbolic_keys
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new
    PreInit.import_instance_variables(o_test, ihash) { |o,*args|
      #
      # We can do this test now, because the object has *definitely*
      # already been created.
      #
      assert_same(o_test, o)
      (ivar, ival) = args.first
      o.instance_variable_set("@#{ivar.to_s}".to_sym, ival)
    }
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_303_postblockload_simple_hash_string_keys
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new
    PreInit.import_instance_variables(o_test, ihash) { |o,*args|
      #
      # We can do this test now, because the object has *definitely*
      # already been created.
      #
      assert_same(o_test, o)
      (ivar, ival) = args.first
      o.instance_variable_set("@#{ivar.to_s}".to_sym, ival)
    }
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

end
