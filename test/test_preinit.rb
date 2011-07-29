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

  def test_005_simple_hash_bogus_keys
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      o_test = TestClass.new(ihash)
    end
  end

  def test_006_simple_hash_bogus_keys
    ihash = @testdata_hash_bogus_keys
    o_test = TestClass.new
    o_test.preinit_options[:on_NameError] = :ignore
    assert_nothing_raised() do
      o_test.load_attrs(ihash)
    end
    ihash.each do |ivar,ival|
      ivar_sym = "@#{ivar.to_s}".to_sym
      if (ihash[:bogokeys].include?(ivar))
        assert_raise(NameError) do
          assert_nil(o_test.instance_variable_get(ivar_sym))
        end
      else
        assert_equal(ival, o_test.instance_variable_get(ivar_sym))
      end
    end
  end

  def test_007_simple_hash_bogus_keys
    ihash = @testdata_hash_bogus_keys
    o_test = TestClass.new
    o_test.preinit_options[:on_NameError] = :convert
    assert_nothing_raised() do
      o_test.load_attrs(ihash)
    end
    ihash.each do |ivar,ival|
      ivar_sym = "@#{ivar.to_s}".to_sym
      if (ihash[:bogokeys].include?(ivar))
        ivar_sym = "@#{ihash[:bogokeys][ivar]}".to_sym
      end
      assert_equal(ival, o_test.instance_variable_get(ivar_sym))
    end
  end

  def test_102_postload_simple_hash_symbolic_keys
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new
    result = o_test.load_attrs(ihash)
    assert(result.kind_of?(TestClass))
    assert_same(o_test, result)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_103_postload_simple_hash_string_keys
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new
    result = o_test.load_attrs(ihash)
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
    o_test.load_attrs(ihash) { |o,*args|
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
    o_test.load_attrs(ihash) { |o,*args|
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
