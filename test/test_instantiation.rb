require File.dirname(__FILE__) + '/test_helper.rb'
require 'pp'

class TestInstantiation < Test::Unit::TestCase

  #
  # Before each test, prepare a bunch of datasets in instance
  # variables.
  #
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
        '*@bk2'	=> '_bk2',
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

  #
  # TODO: Add tests for the :overwrite_values and :use_accessors options!
  #

  def test_001_empty
    o_test = nil
    o_test = TestClass.new
    assert(o_test.kind_of?(TestClass))
    assert(o_test.kind_of?(Instantiation))
  end

  def test_002_simple_hash_symbolic_keys
    o_test = nil
    ihash = @testdata_hash_symbolic_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_003_simple_hash_string_keys
    o_test = nil
    ihash = @testdata_hash_string_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_004_simple_hash_mixed_keys
    o_test = nil
    ihash = @testdata_hash_mixed_keys
    o_test = TestClass.new(ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_005_simple_hash_bogus_keys_raise_default
    o_test = nil
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      o_test = TestClass.new(ihash)
    end
  end

  def test_006_simple_hash_bogus_keys_raise_explicit
    o_test = nil
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      o_test = TestClass.new(ihash, :on_NameError => :raise)
    end
  end

  def test_007_simple_hash_bogus_keys_ignore
    o_test = nil
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      o_test = TestClass.new(ihash, :on_NameError => :ignore)
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

  def test_008_simple_hash_bogus_keys_convert
    o_test = nil
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      o_test = TestClass.new(ihash, :on_NameError => :convert)
    end
    ihash.each do |ivar,ival|
      ivar_name = '@' + ivar.to_s
      if (ihash[:bogokeys].include?(ivar))
        ivar_name = '@' + ihash[:bogokeys][ivar].to_s
      end
      ivar_sym = ivar_name.to_sym
      assert(o_test.instance_variables.include?(ivar_name),
             "Expecting '#{ivar_name}' to be '#{ivar_sym.inspect}'")
      assert_equal(ival, o_test.instance_variable_get(ivar_sym))
    end
  end

  #
  # Now test invoking the Instantiation.import_instance_variables class
  # method on empty instances that include the module.
  #
  def test_102_simple_hash_symbolic_keys
    o_test = TestClass.new
    ihash = @testdata_hash_symbolic_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_103_simple_hash_string_keys
    o_test = TestClass.new
    ihash = @testdata_hash_string_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_104_simple_hash_mixed_keys
    o_test = TestClass.new
    ihash = @testdata_hash_mixed_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_105_simple_hash_bogus_keys_raise_default
    o_test = TestClass.new
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      Instantiation.import_instance_variables(o_test, ihash)
    end
  end

  def test_105_simple_hash_bogus_keys_raise_explicit
    o_test = TestClass.new
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :raise)
    end
  end

  def test_107_simple_hash_bogus_keys_ignore
    o_test = TestClass.new
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :ignore)
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

  def test_108_simple_hash_bogus_keys_convert
    o_test = TestClass.new
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :convert)
    end
    ihash.each do |ivar,ival|
      ivar_name = '@' + ivar.to_s
      if (ihash[:bogokeys].include?(ivar))
        ivar_name = '@' + ihash[:bogokeys][ivar].to_s
      end
      ivar_sym = ivar_name.to_sym
      assert(o_test.instance_variables.include?(ivar_name),
             "Expecting '#{ivar_name}' to be '#{ivar_sym.inspect}'")
      assert_equal(ival, o_test.instance_variable_get(ivar_sym))
    end
  end

  #
  # Now try the Instantiation.import_instance_variables invocation on instances
  # of classes that *didn't* include the module.
  #
  def test_202_simple_hash_symbolic_keys
    o_test = Object.new
    ihash = @testdata_hash_symbolic_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_203_simple_hash_string_keys
    o_test = Object.new
    ihash = @testdata_hash_string_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_204_simple_hash_mixed_keys
    o_test = Object.new
    ihash = @testdata_hash_mixed_keys
    Instantiation.import_instance_variables(o_test, ihash)
    ihash.each do |ivar,ival|
      assert_equal(ival, o_test.instance_variable_get("@#{ivar.to_s}".to_sym))
    end
  end

  def test_205_simple_hash_bogus_keys_raise_default
    o_test = Object.new
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      Instantiation.import_instance_variables(o_test, ihash)
    end
  end

  def test_205_simple_hash_bogus_keys_raise_explicit
    o_test = Object.new
    ihash = @testdata_hash_bogus_keys
    assert_raise(NameError) do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :raise)
    end
  end

  def test_207_simple_hash_bogus_keys_ignore
    o_test = Object.new
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :ignore)
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

  def test_208_simple_hash_bogus_keys_convert
    o_test = Object.new
    ihash = @testdata_hash_bogus_keys
    assert_nothing_raised() do
      Instantiation.import_instance_variables(o_test, ihash, :on_NameError => :convert)
    end
    ihash.each do |ivar,ival|
      ivar_name = '@' + ivar.to_s
      if (ihash[:bogokeys].include?(ivar))
        ivar_name = '@' + ihash[:bogokeys][ivar].to_s
      end
      ivar_sym = ivar_name.to_sym
      assert(o_test.instance_variables.include?(ivar_name),
             "Expecting '#{ivar_name}' to be '#{ivar_sym.inspect}'")
      assert_equal(ival, o_test.instance_variable_get(ivar_sym))
    end
  end

  #
  # Now try all that with blocks.
  #
end
